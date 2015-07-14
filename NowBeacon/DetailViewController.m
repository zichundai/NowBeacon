//
//  DetailViewController.m
//  NowBeacon
//
//  Created by carvin on 15/5/29.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import "DetailViewController.h"
#import "XBeacon.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"

@interface DetailViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate, MBProgressHUDDelegate>{
    CBCentralManager      *centralManager;
}
@property (strong, nonatomic) NSMutableArray        *arrayServices;
@property (strong, nonatomic) XBeacon *connectedBeacon;


@end

@implementation DetailViewController
@synthesize connectedPeripheral;


#pragma mark - 窗体的处理
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _arrayServices = [[NSMutableArray alloc] init];
    _connectedBeacon = [[XBeacon alloc] init];
    centralManager.delegate = self;
    [self configAllTextField];
}

- (void)viewDidDisappear:(BOOL)animated {
    if(connectedPeripheral.state == CBPeripheralStateConnected) {
        [centralManager cancelPeripheralConnection:connectedPeripheral];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configAllTextField {
    _textUUID.regexpPattern = @"^[a-fA-F0-9]{32}";
    _textUUID.regexpValidColor = [UIColor validColor];
    _textUUID.regexpInvalidColor = [UIColor invalidColor];
    _textMajor.regexpPattern = @"^[a-fA-F0-9]{4}";
    _textMajor.regexpValidColor = [UIColor validColor];
    _textMajor.regexpInvalidColor = [UIColor invalidColor];
    _textMinor.regexpPattern = @"^[a-fA-F0-9]{1,4}";
    _textMinor.regexpValidColor = [UIColor validColor];
    _textMinor.regexpInvalidColor = [UIColor invalidColor];

}

#pragma mark - 对话框
-(void)showWarningAlert:(NSString *)errorMsg{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"错误" message:errorMsg delegate:self
                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)showInfoAlert:(NSString *)msg{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"信息" message:msg delegate:self
                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - CentralManager委托实现
- (void)scan
{
    [centralManager scanForPeripheralsWithServices:nil
                                           options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"ibeacon配置页面－－开始搜索");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"查找到ibeacon设备 %@ at %@", peripheral.name, RSSI);
    
    if ([peripheral.identifier.UUIDString isEqualToString:connectedPeripheral.identifier.UUIDString]){
        [centralManager stopScan];
        connectedPeripheral = peripheral;
        [centralManager connectPeripheral:connectedPeripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self.arrayServices removeAllObjects];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self showWarningAlert:@"断开连接！"];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Central Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"central state=%ld", (long)central.state);
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if(self.connectedPeripheral){
        [self scan];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}
#pragma mark - Perpheral委托实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{SECTION_NAME:service.UUID.description}];
        [self.arrayServices addObject:dic];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    [_connectedBeacon clear];
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"characteristic=%@", characteristic.UUID.UUIDString );
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([stringFromData isEqualToString:@"EOM"]) {
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        [centralManager cancelPeripheralConnection:peripheral];
    }
    
    for (NSMutableDictionary *dic in self.arrayServices) {
        NSString *service = [dic valueForKey:SECTION_NAME];
        if([service isEqual:characteristic.service.UUID]){
            NSLog(@"characteristic description: %@", characteristic.UUID.description);
            [dic setValue:characteristic.value forKey:characteristic.UUID.description];
        }
    }
    NSString *strHexCharacteristic = (NSString *)[characteristic.value dataToHexString];
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]){
        _charUUID = characteristic;
        _textUUID.text = [strHexCharacteristic uppercaseString];
        NSLog(@"FFF1 Received string: %@", strHexCharacteristic);
        _textEquipment.enabled = NO;
        _textEquipment.text = peripheral.name;
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF2"]){
        _charMajorMinor = characteristic;
        if ([strHexCharacteristic length] == 8){
            _textMajor.text = [[strHexCharacteristic substringWithRange:NSMakeRange(0, 4)] uppercaseString];
            _textMinor.text = [[strHexCharacteristic substringWithRange:NSMakeRange(4, 4)] uppercaseString];
        }
        NSLog(@"FFF2 Received : %@", strHexCharacteristic);
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF3"]){
        _charInterval = characteristic;
        int iInterval = 80;
        [_charInterval.value getBytes:&iInterval length:2];
        if (iInterval == 80) {
            _segInterval.selectedSegmentIndex = 2;
        }else if (iInterval == 48) {
            _segInterval.selectedSegmentIndex = 1;
        }else if (iInterval == 16) {
            _segInterval.selectedSegmentIndex = 0;
        }else {
            _segInterval.selectedSegmentIndex = 3;
        }
        NSLog(@"FFF3 Received : %i", iInterval);
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF4"]){
        _charTxPower = characteristic;
        int iTxPower = 0;
        [_charTxPower.value getBytes:&iTxPower length:2];
        if (iTxPower == 0x08) {
            _segPower.selectedSegmentIndex = 0;
        }else if (iTxPower == 0x09) {
            _segPower.selectedSegmentIndex = 1;
        }else if (iTxPower == 0x0a) {
            _segPower.selectedSegmentIndex = 2;
        }else {
            _segPower.selectedSegmentIndex = 3;
        }
        NSLog(@"FFF4 Received : %i", iTxPower);
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF5"]){
        NSLog(@"FFF5 Received : %@", strHexCharacteristic);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]){
        NSLog(@"2A23 System ID : %@", strHexCharacteristic);
        self.strMac = strHexCharacteristic;
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A27"]){
        const char *bsw=[characteristic.value bytes];
        self.strHwVer = [NSString stringWithCString:bsw encoding:NSASCIIStringEncoding];
        NSLog(@"2A27hw ver: %@", self.strHwVer);
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A28"]){
        const char *bsw=[characteristic.value bytes];
        self.strSwVer = [NSString stringWithCString:bsw encoding:NSASCIIStringEncoding];
        NSLog(@"2A28 sw ver : %@", self.strSwVer);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
}

#pragma mark - CBPeripheralManagerDelegate方法实现
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
}

- (void)hudWasHidden:(MBProgressHUD *)hud{
    
}

- (IBAction)onSavePressed:(id)sender {
    NSLog(@"username=%@", [UserInfo getUserName] );
    NSLog(@"latitude=%f", [UserInfo getLatitude]);
    NSLog(@"longitude=%f", [UserInfo getLongitude]);
    if ([_textUUID.text length]!=32 || [_textMajor.text length]!=4 || [_textMinor.text length]!=4) {
        [self showWarningAlert:@"请检查参数长度！"];
        return;
    }
    [self saveConnectedBeaconParam];
}

- (IBAction)touchView:(id)sender {
     [self.view endEditing:YES];
}

- (void)saveConnectedBeaconParam{
    if (connectedPeripheral.state != CBPeripheralStateConnected){
        [self showWarningAlert:@"断开连接，请重新连接"];
        return;
    }
    NSString *strWriteUUID = _textUUID.text;
    NSData *writeUUID = (NSData *)[strWriteUUID stringToHexData];
    [connectedPeripheral writeValue:writeUUID forCharacteristic:_charUUID type:CBCharacteristicWriteWithResponse];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error){
        NSLog(@"错误：%ld", (long)error.code);
        [self showWarningAlert:@"写入参数失败，请检查"];
        return;
    }
    if(characteristic.UUID == _charUUID.UUID){
        NSLog(@"写入uuid成功");
        NSString *strWriteMajorAndMinor = [_textMajor.text stringByAppendingString:_textMinor.text ];
        NSLog(@"写 Major and Minor =%@", strWriteMajorAndMinor);
        NSData *writeMajorMinor = (NSData *)[strWriteMajorAndMinor stringToHexData];
        [connectedPeripheral writeValue:(NSData *)writeMajorMinor forCharacteristic:_charMajorMinor type:CBCharacteristicWriteWithResponse];
    }else if(characteristic.UUID == _charMajorMinor.UUID){
        NSLog(@"写入major和minor成功");
        int iInterval = 0;
        if (_segInterval.selectedSegmentIndex == 0) {
            iInterval = 16;
        }else if (_segInterval.selectedSegmentIndex == 1) {
            iInterval = 48;
        }else if (_segInterval.selectedSegmentIndex == 2) {
            iInterval = 80;
        }else{
            iInterval = 160;
        }
        Byte cbyte[] = {iInterval};
        NSData *writeInterval = [[NSData alloc]initWithBytes:cbyte length:1];
        NSLog(@"写入interval=%d", iInterval);
        [connectedPeripheral writeValue:(NSData *)writeInterval forCharacteristic:_charInterval type:CBCharacteristicWriteWithResponse];
    }else if(characteristic.UUID == _charInterval.UUID){
        NSLog(@"写入interval成功");
        
        int iPower = 0;
        if (_segPower.selectedSegmentIndex == 0) {
            iPower = 0x08;
        }else if (_segPower.selectedSegmentIndex == 1) {
            iPower = 0x09;
        }else if (_segPower.selectedSegmentIndex == 2) {
            iPower = 0x0a;
        }else{
            iPower = 0x0b;
        }
        Byte cbyte[] = {iPower};
        NSData *writeTxPower = [[NSData alloc]initWithBytes:cbyte length:1];
        [connectedPeripheral writeValue:(NSData *)writeTxPower forCharacteristic:_charTxPower type:CBCharacteristicWriteWithResponse];
    }else if(characteristic.UUID == _charTxPower.UUID){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSDictionary *parameters = @{@"username":[UserInfo getUserName],@"latitude":[NSNumber numberWithDouble:[UserInfo getLatitude]], @"longitude":[NSNumber numberWithDouble:[UserInfo getLongitude]], @"uuid": _textUUID.text, @"major":_textMajor.text, @"minor":_textMinor.text, @"mac":self.strMac, @"interval":[self getIntervalString:_segInterval.selectedSegmentIndex], @"power":[self getPowerString:_segPower.selectedSegmentIndex], @"localname":_textEquipment.text, @"sw_ver":self.strSwVer, @"hw_ver":self.strHwVer};
        NSLog(@"strSwVer,length=%lu", (unsigned long)[self.strSwVer length]);
        NSString *url=@"http://www.shinskytech.com/add_ibeacon.php";
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            id res = [responseObject objectForKey:@"result"];
            NSLog(@"result=%@",res);
            if([res isEqual:@"TRUE"]){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                          @"错误" message:@"连接服务器失败，请检查网络" delegate:self
                                                         cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [self showInfoAlert:@"写入参数成功！"];
        
        NSLog(@"写入tx power成功");
    }
}

- (NSString *) getIntervalString : (NSInteger) index{
    NSString *resString;
    if (index == 1) {
        resString = @"300ms";
    } else if(index == 2){
        resString = @"500ms";
    }else if(index == 3){
        resString = @"1000ms";
    }else {
        resString = @"100ms";
    }
    return resString;
}

- (NSString *) getPowerString : (NSInteger) index{
    NSString *resString;
    if (index == 1) {
        resString = @"7m";
    } else if(index == 2){
        resString = @"10m";
    }else if(index == 3){
        resString = @"30m";
    }else {
        resString = @"3m";
    }
    return resString;
}
@end

#pragma mark - String处理
@implementation NSData (DataToHexString)

- (NSString *) dataToHexString
{
    NSUInteger len = [self length];
    char *chars = (char *)[self bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    
    return hexString;
}
@end

@implementation NSString (StringToHexData)

- (NSData *) stringToHexData
{
    unsigned long len = [self length] /2;
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}
@end