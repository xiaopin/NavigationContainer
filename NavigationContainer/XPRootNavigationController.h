//
//  XPRootNavigationController.h
//  https://github.com/xiaopin/NavigationContainer.git
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(8_0)
@interface XPRootNavigationController : UINavigationController

/// Whether the status bar style and home indicator are managed by the navigation bar controller, default NO.
@property (nonatomic, assign, getter=isChildViewControllerIsNavigationController) IBInspectable BOOL childViewControllerIsNavigationController;

/// Reference hidesBottomBarWhenPushed, default YES.
@property (nonatomic, assign, getter=isViewControllerHidesBottomBarWhenPushed) IBInspectable BOOL viewControllerHidesBottomBarWhenPushed;

@end
