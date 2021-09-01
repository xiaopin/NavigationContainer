//
//  UIViewController+XPNavigationContainer.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "UIViewController+XPNavigationContainer.h"
#import "XPHelper+NavigationContainer.h"
#import "XPRootNavigationController.h"
#import "XPGradientNavigationBar.h"
#import "XPGradientView.h"
#import <objc/runtime.h>

@implementation UIViewController (XPNavigationContainer)

#pragma mark - Public

/// By returning to different navigation bar controllers, you can customize different navigation bar styles for each controller
- (Class)xp_navigationControllerClass {
#ifdef kXPNavigationControllerClassName
    return NSClassFromString(kXPNavigationControllerClassName);
#else
    return [UINavigationController class];
#endif
}

- (Class)xp_navigationBarClass {
    return [XPGradientNavigationBar class];
}

- (void)xp_setNavigationBarWithGradientColors:(NSArray<UIColor *> *)colors {
    UINavigationBar *navigationBar = nil;
    if ([self isKindOfClass:UINavigationController.class]) {
        navigationBar = [(UINavigationController *)self navigationBar];
    } else {
        navigationBar = self.navigationController.navigationBar;
    }
    if (NO == [navigationBar isKindOfClass:XPGradientNavigationBar.class]) return;
    XPGradientView *gradientView = [(XPGradientNavigationBar *)navigationBar gradientView];
    [gradientView setGradientWithColors:colors];
}

- (void)xp_setNavigationBarWithGradientColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UINavigationBar *navigationBar = nil;
    if ([self isKindOfClass:UINavigationController.class]) {
        navigationBar = [(UINavigationController *)self navigationBar];
    } else {
        navigationBar = self.navigationController.navigationBar;
    }
    if (NO == [navigationBar isKindOfClass:XPGradientNavigationBar.class]) return;
    XPGradientView *gradientView = [(XPGradientNavigationBar *)navigationBar gradientView];
    [gradientView setGradientWithColors:colors startPoint:startPoint endPoint:endPoint];
}

#pragma mark - setter & getter
 
- (void)setXp_backIconImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(xp_backIconImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)xp_backIconImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXp_backIconTintColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(xp_backIconTintColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)xp_backIconTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (XPRootNavigationController *)xp_rootNavigationController {
    id ret = objc_getAssociatedObject(self, &kXPRootNavigationControllerKey);
    if (ret) return ret;
    Class cls = [XPRootNavigationController class];
    UIViewController *vc = self;
    while (vc) {
        if ([vc isKindOfClass:cls]) return (id)vc;
        vc = vc.parentViewController;
    }
    return nil;
}

- (void)xp_setNavigationBarAlpha:(CGFloat)alpha {
    UINavigationBar *navigationBar = nil;
    if ([self isKindOfClass:UINavigationController.class]) {
        navigationBar = [(UINavigationController *)self navigationBar];
    } else {
        navigationBar = self.navigationController.navigationBar;
    }
    UIView *barBackgroundView = navigationBar.subviews.firstObject;
    if (@available(iOS 13.0, *)) {
        barBackgroundView.alpha = alpha;
        return;
    }
    // Whether to hide the bottom dividing line
    UIView *shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    shadowView.hidden = (alpha < 1.0);
    // Background transparency
    if (navigationBar.isTranslucent) {
        if (@available(iOS 10.0, *)) {
            UIView *backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            backgroundEffectView.alpha = alpha;
        } else {
            UIView *adaptiveBackdrop = [barBackgroundView valueForKey:@"_adaptiveBackdrop"];
            adaptiveBackdrop.alpha = alpha;
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
}

@end
