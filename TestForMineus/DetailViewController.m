//
//  DetailViewController.m
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import "DetailViewController.h"
#import "Constants.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *ai;
@end

@implementation DetailViewController

- (void)configureView {
    
    if (self.detailItem) {
        
        self.contentWebView.hidden = YES;
        NSString *urlAddress = self.detailItem.link;
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.contentWebView loadRequest:requestObj];
        
        
        self.ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (!self.splitViewController.collapsed) {
           self.ai.center = CGPointMake(self.view.bounds.size.height/2 , self.view.bounds.size.height/2);
        } else {
            self.ai.center = self.splitViewController.view.center;
        }
        
    
        [self.ai startAnimating];
        [self.view addSubview:self.ai];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = BITTERSWEET_SHIMMER_COLOR;
    self.navigationController.navigationBar.tintColor = INDEPENDENCE_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : BONE_COLOR
                                                                    };
    self.view.backgroundColor = BONE_COLOR;
    self.contentWebView.hidden = YES;


    if ([self connected]) {
        [self configureView];
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
                                     [alert dismissViewControllerAnimated:YES completion:^{
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }];
                                    
                                 }];
            
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.contentWebView.hidden = NO;
    [self.ai stopAnimating];
    [self.ai removeFromSuperview];
}

#pragma mark - Additional methods

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}




@end
