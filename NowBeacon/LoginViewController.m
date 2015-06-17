//
//  LoginViewController.m
//  
//
//  Created by carvin on 15/6/16.
//
//

#import "LoginViewController.h"
#import "MainTabViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UserInfo.h"

@interface LoginViewController ()<CLLocationManagerDelegate>
@property (strong, nonatomic)CLLocationManager *locationManager;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.delegate = self;    // 判断定位操作是否被允许
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1000.0f;
        [self.locationManager startUpdatingLocation];
        NSLog(@"开始定位");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showWarningAlert:(NSString *)errorMsg{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"错误" message:errorMsg delegate:self
                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


- (IBAction)onRegisterClick:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"信息" message:@"注册请联系QQ：13644949" delegate:self
                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];

}

- (IBAction)onLoginClick:(id)sender {
    if ([UserInfo getLatitude]==-1 || [UserInfo getLongitude]==-1) {
        [self showWarningAlert:@"获取位置信息失败，请检查！"];
    }
    MainTabViewController *viewController = [self.storyboard     instantiateViewControllerWithIdentifier:@"maintab"];
    [self presentModalViewController:viewController animated:YES];
}

- (BOOL) loginCheck:(NSString *)username password:(NSString *)password{
    return NO;
}
#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 获取经纬度
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    // 停止位置更新
    [manager stopUpdatingLocation];
}*/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // 获取经纬度
    CLLocation *checkinLocation = [locations lastObject];
    
    double latitude =  checkinLocation.coordinate.latitude;
    double longitude = checkinLocation.coordinate.longitude;

    NSLog(@"纬度:%f",latitude);
    NSLog(@"经度:%f",longitude);
    [UserInfo setLatitude:latitude];
    [UserInfo setLongitude:longitude];
    // 停止位置更新
    [manager stopUpdatingLocation];

    
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位错误error:%@",error);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
