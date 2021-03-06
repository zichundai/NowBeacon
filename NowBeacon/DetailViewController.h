//
//  DetailViewController.h
//  NowBeacon
//
//  Created by carvin on 15/5/29.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSValidatedTextField.h"
#import "UIColor+CustomColors.h"
#define SECTION_NAME                    @"SECTION_NAME"


@interface DetailViewController : UIViewController{
    CBPeripheral *connectedPeripheral;
}
@property (strong, nonatomic) IBOutlet TSValidatedTextField *textUUID;
@property (strong, nonatomic) IBOutlet TSValidatedTextField *textMajor;
@property (strong, nonatomic) IBOutlet TSValidatedTextField *textMinor;
@property (strong, nonatomic) IBOutlet TSValidatedTextField *textEquipment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segInterval;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segPower;
@property (strong, nonatomic) IBOutlet UILabel *lblMajorHex;

@property (strong, nonatomic) IBOutlet UILabel *lblMinorHex;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (strong, nonatomic) CBCharacteristic *charUUID;
@property (strong, nonatomic) CBCharacteristic *charMajorMinor;
@property (strong, nonatomic) CBCharacteristic *charInterval;
@property (strong, nonatomic) CBCharacteristic *charTxPower;
@property (strong, nonatomic) NSString *strMac;
@property (strong, nonatomic) NSString *strSwVer;
@property (strong, nonatomic) NSString *strHwVer;
- (IBAction)touchView:(id)sender;

- (void)saveConnectedBeaconParam;
@end

@interface NSData (DataToHexString)
-(NSData*) dataToHexString ;
@end

@interface NSString (NSStringHexToBytes)
- (NSData *) stringToHexData;
@end