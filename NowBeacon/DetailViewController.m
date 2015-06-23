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
    _textMinor.regexpPattern = @"^[a-fA-F0-9]{4}";
    _textMinor.regexpValidColor = [UIColor validColor];
    _textMinor.regexpInvalidColor = [UIColor invalidColor];

}

#pragma mark - CentralManager委托实现
- (void)scan
{
    [centralManager scanForPeripheralsWithServices:nil
                                           options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if ([peripheral.identifier.UUIDString isEqualToString:connectedPeripheral.identifier.UUIDString]){
        [centralManager stopScan];
        connectedPeripheral = peripheral;
        [centralManager connectPeripheral:connectedPeripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //_lableInfo.text = @"连接成功！";
    [self.arrayServices removeAllObjects];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //_lableInfo.text = @"断开连接！";
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //_lableInfo.text = @"连接失败！";
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Central Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"central state=%ld", (long)central.state);
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
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
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{SECTION_NAME:service.UUID.description}];
        [self.arrayServices addObject:dic];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    [_connectedBeacon clear];
    // Again, we loop through the array, just in case.
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
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    for (NSMutableDictionary *dic in self.arrayServices) {
        NSString *service = [dic valueForKey:SECTION_NAME];
        if([service isEqual:characteristic.service.UUID]){
            NSLog(@"characteristic description: %@", characteristic.UUID.description);
            [dic setValue:characteristic.value forKey:characteristic.UUID.description];
        }
    }
    NSString *testString = (NSString *)[characteristic.value dataToHexString];
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]){
        _charUUID = characteristic;
        _textUUID.text = [testString uppercaseString];
        NSLog(@"FFF1 Received string: %@", testString);
        _textEquipment.enabled = NO;
        _textEquipment.text = peripheral.name;
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF2"]){
        _charMajorMinor = characteristic;
        if ([testString length] == 8){
            _textMajor.text = [[testString substringWithRange:NSMakeRange(0, 4)] uppercaseString];
            _textMinor.text = [[testString substringWithRange:NSMakeRange(4, 4)] uppercaseString];
        }
        NSLog(@"FFF2 Received : %@", testString);
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
        NSLog(@"FFF5 Received : %@", testString);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]){
        NSLog(@"2A23 System ID : %@", testString);
    }
    
    // Log it
    //NSLog(@"Received: %@", stringFromData);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
}

#pragma mark - CBPeripheralManagerDelegate方法实现
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
}

- (void)myTask {
    // Do something usefull in here instead of sleeping ...
    //sleep(3);
    [self scan];
}

- (void)hudWasHidden:(MBProgressHUD *)hud{
    
}
- (IBAction)onSavePressed:(id)sender {
    NSLog(@"username=%@", [UserInfo getUserName] );
    NSLog(@"latitude=%f", [UserInfo getLatitude]);
    NSLog(@"longitude=%f", [UserInfo getLongitude]);
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
        [connectedPeripheral writeValue:(NSData *)writeInterval forCharacteristic:_charInterval type:CBCharacteristicWriteWithResponse];
    }else if(characteristic.UUID == _charInterval.UUID){
        NSLog(@"写入interval成功");
        [self showInfoAlert:@"写入参数成功！"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //申明返回的结果是json类型
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //申明请求的数据是json类型
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        
        //如果报接受类型不一致请替换一致text/html或别的
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //传入的参数
        NSDictionary *parameters = @{@"username":[UserInfo getUserName],@"latitude":[NSNumber numberWithDouble:[UserInfo getLatitude]], @"longitude":[NSNumber numberWithDouble:[UserInfo getLongitude]], @"uuid": _textUUID.text, @"major":_textMajor.text, @"minor":_textMinor.text, @"interval":[NSNumber numberWithDouble:_segInterval.selectedSegmentIndex], @"power":[NSNumber numberWithDouble:_segPower.selectedSegmentIndex]};
        //你的接口地址
        NSString *url=@"http://www.shinskytech.com/add_ibeacon.php";
        //发送请求
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
        //[self.navigationController popViewControllerAnimated:YES];
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
        //Byte cbyte[] = {iPower};
        //NSData *writeTxPower = [[NSData alloc]initWithBytes:cbyte length:1];
        //[connectedPeripheral writeValue:(NSData *)writeTxPower forCharacteristic:_charTxPower type:CBCharacteristicWriteWithResponse];
    }else if(characteristic.UUID == _charTxPower.UUID){
        NSLog(@"写入tx power成功");
    }
}

@end

#pragma mark - String处理
@implementation NSData (DataToHexString)

- (NSString *) dataToHexString
{
    NSUInteger          len = [self length];
    char *              chars = (char *)[self bytes];
    NSMutableString *   hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    
    return hexString;
}
@end

@implementation NSString (StringToHexData)

- (NSData *) stringToHexData
{
    unsigned long len = [self length] /2;    // Target length
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