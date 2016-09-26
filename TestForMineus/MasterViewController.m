//
//  MasterViewController.m
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewsCell.h"
#import "News.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "Constants.h"



@interface MasterViewController ()

@property NSMutableArray *news;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureUI];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(getLatestNews) name:@"appDidEnterForeground" object:nil];
    
    News *news = [News new];
    self.news = [news loadCustomObjectWithKey:@"newsArray"];
    
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void) configureUI {
    self.navigationController.navigationBar.barTintColor = BITTERSWEET_SHIMMER_COLOR;
    self.navigationController.navigationBar.tintColor = INDEPENDENCE_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : BONE_COLOR
                                                                    };
    self.view.backgroundColor = BONE_COLOR;
    
    self.tableView.separatorColor = INDEPENDENCE_COLOR;
    self.tableView.estimatedRowHeight = 500.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

   }

- (void)viewWillAppear:(BOOL)animated {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = INDEPENDENCE_COLOR;
    self.refreshControl.tintColor = BONE_COLOR;
    
    [self.refreshControl addTarget:self
                            action:@selector(getLatestNews)
                  forControlEvents:UIControlEventValueChanged];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.refreshControl beginRefreshing];
                       [self.refreshControl endRefreshing];
                   });
    
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network connection

- (void)getLatestNews {
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:kLatestNewsURL] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       News *news = [[News alloc] init];
        if ([self connected]) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSArray *latestNews = [self fetchData:data];
            self.news = [NSMutableArray array];
            
            if (self.news) {
                for (NSDictionary *newsDic in latestNews) {
                    News *news = [[News alloc] init];
                    news.title = [newsDic objectForKey:@"title"];
                    news.link = [newsDic objectForKey:@"link"];
                    news.postDate = [newsDic objectForKey:@"publishedDate"];
                    news.snippet = [newsDic objectForKey:@"contentSnippet"];
                    
                    [self.news addObject:news];
                }
                [news saveCustomObject:self.news key:@"newsArray"];
                [self spotlightSearch];
            } else {
                self.news = [news loadCustomObjectWithKey:@"newsArray"];
            }
            
           [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
          
            
        } else {
            
            UIAlertController * alert =  [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"Check network connection"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self.refreshControl endRefreshing];
                                 }];
        
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}

- (NSArray *)fetchData:(NSData *)response
{
    NSError *error = nil;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    
    if (error != nil) {
        NSLog(@"Error: %@", error.description);
        return nil;
    }
    
    NSArray* latestNews = [[[parsedData objectForKey:@"responseData"]
                            objectForKey:@"feed"]
                           objectForKey:@"entries"];
    
    return latestNews;
}

-(void)spotlightSearch{
    
    if(IS_IOS9_OR_GREATER){

        NSMutableArray *searchableItems = [NSMutableArray array];
        int counter = 0;
        
        for (News *news in self.news) {
            
            
            CSSearchableItemAttributeSet *searchableItemAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"com.mineustest.news"];
            searchableItemAttributeSet.contentDescription = news.snippet;
            searchableItemAttributeSet.title = news.title;
            searchableItemAttributeSet.displayName = news.title;
            searchableItemAttributeSet.keywords = @[@"Latest News",@"News", news.title];
            UIImage *thumbnail = [UIImage imageNamed:@""];
            searchableItemAttributeSet.thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.7);
            
            NSString *identifier = [NSString stringWithFormat:@"com.mineustest%d.news", counter];
            
            CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier
                                                                                 domainIdentifier:identifier
                                                                                     attributeSet:searchableItemAttributeSet];
            
            [searchableItems addObject:searchableItem];
            counter++;
        }
        
        CSSearchableIndex *defaultSearchableIndex = [CSSearchableIndex defaultSearchableIndex];
        [defaultSearchableIndex indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
            
            if (error)
                NSLog(@"error accured: %@", error.description);
            else
                NSLog(@"indexed successfully");
        }];
    }
}

- (void)reloadData
{
    

    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm"];
        NSString *title = [NSString stringWithFormat:@"Updated: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        News *object = self.news[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController]
                                                                    topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.news) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
      
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = INDEPENDENCE_COLOR;
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
        if (self.news) {
            return self.news.count;
        }
    
    return 0;
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    News *news = [[News alloc] init];
    if (self.news) {
        news = [self.news objectAtIndex:indexPath.row];
    }
    
    cell.titleLabel.text = news.title;
    cell.publishDateLabel.text = news.postDate;
    cell.snippetLabel.text = news.snippet;
    
    return cell;
}

#pragma mark - Additional methods

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}



@end
