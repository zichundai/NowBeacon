//
//  ConfigTableViewController.m
//  NowBeacon
//
//  Created by carvin on 15/5/29.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import "ConfigTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "XBeacon.h"
#import "BLEInfo.h"

@interface ConfigTableViewController ()<CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableArray        *arrayBLE;
@property (strong, nonatomic) NSMutableArray        *arrayServices;
@property (strong, nonatomic) XBeacon *connectedBeacon;
@end

@implementation ConfigTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self){
        [_configTableView setDelegate:self];
        [_configTableView setDataSource:self];
        [self.view addSubview:_configTableView];
    }
    return self;
}

- (IBAction)onRefreshPressed:(id)sender {
    NSLog(@"刷新数据");
    [self scan];
}

- (void) initIcons {
    NSMutableArray *arrayImage = [[NSMutableArray alloc]init];
    [arrayImage addObject:@"10.png"];
    [arrayImage addObject:@"1.png"];
    [arrayImage addObject:@"2.png"];
    [arrayImage addObject:@"3.png"];
    [arrayImage addObject:@"4.png"];
    [arrayImage addObject:@"5.png"];
    [arrayImage addObject:@"6.png"];
    [arrayImage addObject:@"7.png"];
    [arrayImage addObject:@"8.png"];
    [arrayImage addObject:@"9.png"];
    imageArray = arrayImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    // And somewhere to store the incoming data
    _arrayBLE = [[NSMutableArray alloc] init];
    _arrayServices = [[NSMutableArray alloc] init];
    _connectedBeacon = [[XBeacon alloc] init];
    [self initIcons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Central Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    [self scan];
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    //if ([peripheral.name isEqualToString:SEARCH_BEACON_NAME]){
        BLEInfo *beacon = [[BLEInfo alloc]init];
        beacon.discoveredPeripheral = peripheral;
        beacon.rssi = RSSI;
        [self saveBLEInfo:beacon];
    //}
}

-(BOOL)saveBLEInfo:(BLEInfo *)addBeacon
{
    for (BLEInfo *beacon in self.arrayBLE) {
        if([beacon.discoveredPeripheral.identifier.UUIDString isEqualToString:addBeacon.discoveredPeripheral.identifier.UUIDString]){
            return NO;
        }
    }
    
    [self.arrayBLE addObject:addBeacon];
    [self.configTableView reloadData];
    return YES;
}
- (void)cleanup
{
    // Don't do anything if we're not connected
    if ((self.discoveredPeripheral.state != CBPeripheralStateConnected)) {
        return;
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}
/** Scan for peripherals  **/
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _arrayBLE.count;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    /*
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"BeaconTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    */
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        BLEInfo *beacon = [self.arrayBLE objectAtIndex:indexPath.row];
        cell.textLabel.text = beacon.discoveredPeripheral.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"信号强度: %@ dbm", beacon.rssi];
        int index = (indexPath.row%10+1);
        cell.imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:index]];
        //cell.LableTitle.text = beacon.discoveredPeripheral.name;
        //cell.LableDetail1.text = [NSString stringWithFormat:@"UUID: %@", beacon.discoveredPeripheral.identifier.UUIDString];
        //cell.LableDetail2.text = [NSString stringWithFormat:@"RSSI: %@ dbm", beacon.rssi];
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't keep the table selection.
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLEInfo *beacon = [self.arrayBLE objectAtIndex:indexPath.row];
    CBPeripheral *disPeripheral = beacon.discoveredPeripheral;
    if(disPeripheral){
        /*
        BeaconDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailcontroller"];
        viewController.connectedPeripheral = disPeripheral;
        [self.navigationController pushViewController:viewController animated:YES];
         */
        [self.centralManager stopScan];
    }
}


@end
