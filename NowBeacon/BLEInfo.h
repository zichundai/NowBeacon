//
//  BLEInfo.h
//  xbeacon
//
//  Created by carvin on 15/4/21.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface BLEInfo : NSObject
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, strong) NSString *major;
@property (nonatomic, strong) NSString *minor;
@property (atomic,assign) int interval;
@end
