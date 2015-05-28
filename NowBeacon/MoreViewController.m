//
//  MoreViewController.m
//  NowBeacon
//
//  Created by carvin on 15/5/28.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void) initMenus {
    NSMutableArray *arrayValue = [[NSMutableArray alloc]init];
    NSString *value1 = @"UUID列表";
    [arrayValue addObject:value1];
    NSString *value2 = @"NowBeacon教程";
    [arrayValue addObject:value2];
    NSString *value3 = @"联系我们";
    [arrayValue addObject:value3];
    menuArray = arrayValue;
    
    NSMutableArray *arrayImage = [[NSMutableArray alloc]init];
    NSString *value11 = @"notepad.png";
    [arrayImage addObject:value11];
    NSString *value21 = @"microphone.png";
    [arrayImage addObject:value21];
    NSString *value31 = @"phone.png";
    [arrayImage addObject:value31];
    imageArray = arrayImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_moreTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _moreTableView.delegate = self;
    _moreTableView.dataSource = self;
   
    NSMutableArray *arrayValue = [[NSMutableArray alloc]init];
    NSString *value1 = @"UUID列表";
    [arrayValue addObject:value1];
    NSString *value2 = @"NowBeacon教程";
    [arrayValue addObject:value2];
    NSString *value3 = @"联系我们";
    [arrayValue addObject:value3];
    menuArray = arrayValue;
    
    NSMutableArray *arrayImage = [[NSMutableArray alloc]init];
    NSString *value11 = @"notepad.png";
    [arrayImage addObject:value11];
    NSString *value21 = @"microphone.png";
    [arrayImage addObject:value21];
    NSString *value31 = @"phone.png";
    [arrayImage addObject:value31];
    imageArray = arrayImage;
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_moreTableView setTableFooterView:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/* 这个函数是显示tableview的章节数*/
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}
/* 这个函数是指定显示多少cells*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //定义个静态字符串为了防止与其他类的tableivew重复
    static NSString *CellIdentifier =@"Cell";
    //定义cell的复用性当处理大量数据时减少内存开销
    UITableViewCell *cell = [_moreTableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell ==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
@end
