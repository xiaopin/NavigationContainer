//
//  UIViewController+XPNavigationContainer.h
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPRootNavigationController;

@interface UIViewController (XPNavigationContainer)

// Navigation bar back button icon, default nil.
@property (nonatomic, strong) IBInspectable UIImage *xp_backIconImage;
@property (nonatomic, strong) UIImage *backIconImage __attribute__((deprecated("This property is deprecated, please use xp_backIconImage")));

/**
 Return the navigation bar controller of the controller, default [UINavigationController class]
  
 You can return to the default navigation bar by defining the macro `kXPNavigationControllerClassName`,
 Subclasses can also return to a separate navigation bar by overriding this method,
 If you customize the navigation bar, remember to deal with your own status bar and screen rotation issues

 @return Navigation bar controller class, must be `UINavigationController` or its subclass
 */
- (Class)xp_navigationControllerClass;

/// Default is `nil`
- (XPRootNavigationController *)xp_rootNavigationController;

@end
