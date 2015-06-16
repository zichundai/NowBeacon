//
//  FirstViewController.h
//  NowBeacon
//
//  Created by carvin on 15/5/28.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHRadarView.h"

@interface FirstViewController : UIViewController <XHRadarViewDataSource, XHRadarViewDelegate>

@property (nonatomic, strong) XHRadarView *radarView;

@end

