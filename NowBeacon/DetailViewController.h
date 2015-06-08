//
//  DetailViewController.h
//  NowBeacon
//
//  Created by carvin on 15/5/29.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define SECTION_NAME                    @"SECTION_NAME"


@interface DetailViewController : UIViewController{
    CBPeripheral *connectedPeripheral;
}
@property (strong, nonatomic) IBOutlet UITextField *textUUID;
@property (strong, nonatomic) IBOutlet UITextField *textMajor;
@property (strong, nonatomic) IBOutlet UITextField *textMinor;
@property (strong, nonatomic) IBOutlet UITextField *textEquipment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segInterval;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segPower;

@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (strong, nonatomic) CBCharacteristic *charUUID;
@property (strong, nonatomic) CBCharacteristic *charMajorMinor;
@property (strong, nonatomic) CBCharacteristic *charInterval;
@property (strong, nonatomic) CBCharacteristic *charTxPower;
- (IBAction)touchView:(id)sender;

- (void)saveConnectedBeaconParam;
@end

@interface NSData (DataToHexString)
-(NSData*) dataToHexString ;
@end

@interface NSString (NSStringHexToBytes)
- (NSData *) stringToHexData;
@end