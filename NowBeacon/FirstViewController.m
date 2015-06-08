//
//  FirstViewController.m
//  NowBeacon
//
//  Created by carvin on 15/5/28.
//  Copyright (c) 2015年 SZMB. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png" ] ]];
    //[self.view setAlpha:1];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"background.png"];
    imageView.alpha = 1;
    [self.view addSubview:imageView];
    
    UIImageView *flameAnimation = [[UIImageView alloc] initWithFrame:self.view.frame];
    flameAnimation.contentMode = UIViewContentModeCenter;
    // load all the frames of our animation
    flameAnimation.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"search1.png"],
                                      [UIImage imageNamed:@"search2.png"],
                                      [UIImage imageNamed:@"search3.png"],
                                      [UIImage imageNamed:@"search4.png"],nil];
    
    // all frames will execute in 1.75 seconds
    flameAnimation.animationDuration = 1.0;
    // repeat the annimation forever
    flameAnimation.animationRepeatCount = 0;
    // start animating
    [flameAnimation startAnimating];
    // add the animation view to the main window
    [self.view addSubview:flameAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
