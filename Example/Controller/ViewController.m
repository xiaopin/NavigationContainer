//
//  ViewController.m
//  Example
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import "ViewController.h"
#import "XPNavigationContainer.h"
#import "WhiteNavigationController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%u", arc4random()];
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Root" style:UIBarButtonItemStylePlain target:self action:@selector(rootButtonAction:)];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rootButtonAction:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (Class)xp_navigationControllerClass {
    // 单独配置导航栏
    return [WhiteNavigationController class];
}

- (UIColor *)xp_backIconTintColor {
    return [UIColor orangeColor];
}

@end
