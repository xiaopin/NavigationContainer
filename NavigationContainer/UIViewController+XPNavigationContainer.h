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

/// Navigation bar back button icon, default nil.
@property (nonatomic, strong) IBInspectable UIImage *xp_backIconImage;
/// Color of the goback icon, default nil.
@property (nonatomic, strong) IBInspectable UIColor *xp_backIconTintColor;

/**
 Return the navigation bar controller of the controller, default [UINavigationController class]
  
 You can return to the default navigation bar by defining the macro `kXPNavigationControllerClassName`,
 Subclasses can also return to a separate navigation bar by overriding this method,
 If you customize the navigation bar, remember to deal with your own status bar and screen rotation issues

 @return Navigation bar controller class, must be `UINavigationController` or its subclass
 */
- (Class)xp_navigationControllerClass;

/**
 Return to the custom navigation bar class, the default [XPGradientNavigationBar class]
 
 @return Navigation bar class, must be `UINavigationBar` or its subclass
 */
- (Class)xp_navigationBarClass;

/// Default is `nil`
- (XPRootNavigationController *)xp_rootNavigationController;

/// Set the gradient color of the navigation bar
/// @param colors       Gradient colors
- (void)xp_setNavigationBarWithGradientColors:(NSArray<UIColor *> *)colors;

/// Set the gradient color and position of the navigation bar
/// @param colors       Gradient colors
/// @param startPoint   Start gradient position
/// @param endPoint     End gradient position
- (void)xp_setNavigationBarWithGradientColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/// Set the transparency of the navigation bar
/// @param alpha Transparency(0.0~1.0)
- (void)xp_setNavigationBarAlpha:(CGFloat)alpha;

/// Set the transparency of the navigation bar
/// @param alpha Transparency(0.0~1.0)
/// @param isPenetration When the navigation bar is transparent, whether the event is allowed to penetrate
- (void)xp_setNavigationBarAlpha:(CGFloat)alpha eventPenetrationWhenTransparent:(BOOL)isPenetration;

@end
