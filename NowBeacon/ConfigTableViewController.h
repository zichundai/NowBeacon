//
//  ConfigTableViewController.h
//  NowBeacon
//
//  Created by carvin on 15/5/29.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigTableViewController : UITableViewController
{
    NSArray *imageArray;
}
@property (strong, nonatomic) IBOutlet UITableView *configTableView;

@end
