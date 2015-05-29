//
//  XBeacon.h
//  xbeacon
//
//  Created by carvin on 15/4/9.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBeacon : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *major;
@property (nonatomic, strong) NSString *minor;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) NSString *macAddress;
@property (atomic, assign) int advertiseInterval;
@property (atomic, assign) int broadcastPower;
@property (nonatomic, strong) NSNumber *swVersion;
@property (nonatomic, strong) NSString *hdVversion;


- (void) clear;

@end
