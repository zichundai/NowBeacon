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
#import "AFHTTPRequestOperation.h"


@interface LoginViewController ()<CLLocationManagerDelegate>
@property (strong, nonatomic)CLLocationManager *locationManager;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"welcome_bg.png"];
    imageView.alpha = 1;
    [self.view addSubview:imageView];
    
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
    //读取保存的用户名
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filename=[plistPath stringByAppendingPathComponent:@"myconfig.plist"];

    NSMutableDictionary *data = [[[NSMutableDictionary alloc] initWithContentsOfFile:filename]mutableCopy];
    NSLog(@"%@", data);
    NSNumber *boolNum = [data valueForKey:@"isRemember"];
    BOOL isRemember = [boolNum boolValue];
    [_switchRemember setOn:isRemember];
    if (isRemember) {
        NSString *user_name = [data valueForKey:@"default_name"];
        NSString *password = [data valueForKey:@"default_password"];
        NSLog(@"user=%@, password=%@", user_name, password);//直接打印数据。
        [_textUsername setText:user_name];
        [_textPassword setText:password];
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
        [self showWarningAlert:@"获取位置信息失败，请打开Wi-Fi！"];
        return;
    }
    if ([_textUsername.text length]<1 || [_textPassword.text length]<1) {
        [self showWarningAlert:@"用户名和密码均不能为空，请检查"];
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //传入的参数
    NSDictionary *parameters = @{@"username":_textUsername.text,@"password":_textPassword.text};
    //你的接口地址
    NSString *url=@"http://www.shinskytech.com/login_check.php";
    NSLog(@"username=%@", _textUsername.text);
    NSLog(@"passowrd=%@", _textPassword.text);
    //发送请求
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        id res = [responseObject objectForKey:@"result"];
        NSLog(@"result=%@",res);
        if([res isEqual:@"1"]){
            MainTabViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"maintab"];
            [self presentViewController:viewController animated:YES
                             completion:^(void){}];
            [UserInfo setUserName:_textUsername.text];
            //保存用户名
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *plistPath1 = [paths objectAtIndex:0];
            NSString *filename=[plistPath1 stringByAppendingPathComponent:@"myconfig.plist"];
             NSMutableDictionary *data =  [[[NSMutableDictionary alloc] initWithContentsOfFile:filename]mutableCopy];
            BOOL isSwitch  = [_switchRemember isOn];
            [data setValue:[NSNumber numberWithBool:isSwitch] forKey:@"isRemember"];
            if (isSwitch){
                [data setValue:_textUsername.text forKey:@"default_name"];
                [data setValue:_textPassword.text forKey:@"default_password"];
            }else{
                [data setValue:@"" forKey:@"default_name"];
                [data setValue:@"" forKey:@"default_password"];
            }
            BOOL res = [data writeToFile:filename atomically:YES];
            NSLog(@"write file =%d", res);
            NSMutableDictionary *data1 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
            NSLog(@"%@", data1);
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                      @"错误" message:@"用户名或密码错误，请检查" delegate:self
                                                     cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - CLLocationManagerDelegate
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
