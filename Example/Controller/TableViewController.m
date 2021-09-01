//
//  TableViewController.m
//  Example
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import "TableViewController.h"
#import "XPNavigationContainer.h"

@interface TableViewController ()

@property (nonatomic, assign, getter=isEnabledAlpha) BOOL enabledAlpha;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = [NSString stringWithFormat:@"%u", arc4random()];
    if (arc4random()%2) {
        self.title = title;
    } else {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.backgroundColor = [UIColor brownColor];
        self.navigationItem.titleView = label;
    }
    
    if (self.navigationController.viewControllers.count % 2 == 0) {
        [self xp_setNavigationBarAlpha:0.0];
        [self setEnabledAlpha:YES];
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
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
    return 4;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (NO == self.isEnabledAlpha) return;
    CGFloat maxOffset = 300.0;
    CGFloat verticalOffset = MIN(MAX(scrollView.contentOffset.y, 0.0), maxOffset);
    CGFloat alpha = verticalOffset / maxOffset;
    [self xp_setNavigationBarAlpha:alpha];
}

@end
