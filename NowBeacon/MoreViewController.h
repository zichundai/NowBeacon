//
//  MoreViewController.h
//  NowBeacon
//
//  Created by carvin on 15/5/28.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *menuArray;
    NSArray *imageArray;
}
@property (strong, nonatomic) IBOutlet UITableView *moreTableView;

@end
