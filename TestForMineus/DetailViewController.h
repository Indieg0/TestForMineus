//
//  DetailViewController.h
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) News *detailItem;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;


@end

