//
//  FirstViewController.m
//  NowBeacon
//
//  Created by carvin on 15/5/28.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import "FirstViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEInfo.h"

@interface FirstViewController ()<CBCentralManagerDelegate>
@property (nonatomic, strong) NSArray *pointsArray;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) NSMutableArray        *arrayBLE;

@end

@implementation FirstViewController
#pragma mark - Central Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    [self scan];
    
}
/** Scan for peripherals  **/
- (void)scan{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    if (_arrayBLE != nil){
        [_arrayBLE removeAllObjects];
    }
    
    NSLog(@"Scanning started");
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
    
    [self startUpdatingRadar];
    return YES;
}
#pragma mark - 窗体控制

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png" ] ]];
    //[self.view setAlpha:1];
    /*UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"background.png"];
    imageView.alpha = 1;
    [self.view addSubview:imageView];
     */
    
    XHRadarView *radarView = [[XHRadarView alloc] initWithFrame:self.view.bounds];
    radarView.frame = self.view.frame;
    radarView.dataSource = self;
    radarView.delegate = self;
    radarView.radius = 215;
    radarView.backgroundColor = [UIColor colorWithRed:0.251 green:0.329 blue:0.490 alpha:1];
    radarView.backgroundImage = [UIImage imageNamed:@"radar_background"];
    radarView.labelText = @"正在搜索附近的iBeacon";
    [self.view addSubview:radarView];
    _radarView = radarView;
    
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-39, self.view.center.y-39, 78, 78)];
    avatarView.layer.cornerRadius = 39;
    avatarView.layer.masksToBounds = YES;
    
    [avatarView setImage:[UIImage imageNamed:@"avatar"]];
    [_radarView addSubview:avatarView];
    [_radarView bringSubviewToFront:avatarView];
    
    //目标点位置
    _pointsArray = @[
                     @[@6, @90],
                     @[@-140, @108],
                     @[@-83, @98],
                     @[@-25, @142],
                     @[@60, @111],
                     @[@-111, @96],
                     @[@150, @145],
                     @[@25, @144],
                     @[@-55, @110],
                     @[@95, @109],
                     @[@170, @180],
                     @[@125, @112],
                     @[@-150, @165],
                     @[@-7, @160],
                     @[@6, @90],
                     @[@-140, @108],
                     @[@-83, @98],
                     @[@-25, @142],
                     @[@60, @111],
                     @[@-111, @96],
                     @[@150, @145],
                     @[@25, @144],
                     @[@-55, @110],
                     @[@95, @109],
                     @[@170, @180],
                     @[@125, @112],
                     @[@-150, @165],
                     @[@-7, @160],
                     @[@6, @90],
                     @[@-140, @108],
                     @[@-83, @98],
                     @[@-25, @142],
                     @[@60, @111],
                     @[@-111, @96],
                     @[@150, @145],
                     @[@25, @144],
                     @[@-55, @110],
                     @[@95, @109],
                     @[@170, @180],
                     @[@125, @112],
                     @[@-150, @165],
                     @[@-7, @160],
                     ];
    //[self.radarView scan];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    // And somewhere to store the incoming data
    _arrayBLE = [[NSMutableArray alloc] init];
    //[self startUpdatingRadar];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.radarView scan];
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    [self scan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.centralManager stopScan];
    [self.radarView stop];
}

#pragma mark - Custom Methods
- (void)startUpdatingRadar {
    typeof(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.radarView.labelText = [NSString stringWithFormat:@"搜索已完成，共找到%lu个目标", _arrayBLE.count];//(unsigned long)weakSelf.pointsArray.count];
        [weakSelf.radarView show];
    });
}

#pragma mark - XHRadarViewDataSource
- (NSInteger)numberOfSectionsInRadarView:(XHRadarView *)radarView {
    return 4;
}

- (NSInteger)numberOfPointsInRadarView:(XHRadarView *)radarView {
    //return [self.pointsArray count];
    return _arrayBLE.count;
}

- (UIView *)radarView:(XHRadarView *)radarView viewForIndex:(NSUInteger)index {
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 25)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [imageView setImage:[UIImage imageNamed:@"point"]];
    [pointView addSubview:imageView];
    return pointView;
}

- (CGPoint)radarView:(XHRadarView *)radarView positionForIndex:(NSUInteger)index {
    NSArray *point = [self.pointsArray objectAtIndex:index];
    return CGPointMake([point[0] floatValue], [point[1] floatValue]);
}

#pragma mark - XHRadarViewDelegate
- (void)radarView:(XHRadarView *)radarView didSelectItemAtIndex:(NSUInteger)index {
    NSLog(@"didSelectItemAtIndex:%lu", (unsigned long)index);
    
}
@end
