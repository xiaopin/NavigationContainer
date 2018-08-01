//
//  TableViewController.m
//  Example
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [UIColor colorWithRed:arc4random_uniform(256)/255.0
                                     green:arc4random_uniform(256)/255.0
                                      blue:arc4random_uniform(256)/255.0
                                     alpha:1.0];
    NSString *title = [NSString stringWithFormat:@"%u", arc4random()];
    
    self.navigationController.navigationBar.barTintColor = color;
    if (arc4random()%2) {
        self.title = title;
    } else {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.backgroundColor = [UIColor brownColor];
        self.navigationItem.titleView = label;
    }
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"{%ld,%ld}", indexPath.section, indexPath.row];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TableViewController *tableVC = (TableViewController*)[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self.class)];
    [self.navigationController pushViewController:tableVC animated:YES];
}

@end
