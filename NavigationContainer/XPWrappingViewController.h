//
//  XPWrappingViewController.h
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XPWrappingViewController : UIViewController

@property (nonatomic, weak, readonly) UIViewController *contentViewController;
@property (nonatomic, weak, readonly) UINavigationController *contentNavigationController;

+ (instancetype)wrappingViewControllerWithViewController:(UIViewController *)viewController;
- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

