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
#import <objc/runtime.h>

@implementation UIViewController (XPNavigationContainer)

/// By returning to different navigation bar controllers, you can customize different navigation bar styles for each controller
- (Class)xp_navigationControllerClass {
#ifdef kXPNavigationControllerClassName
    return NSClassFromString(kXPNavigationControllerClassName);
#else
    return [UINavigationController class];
#endif
}

- (void)setXp_backIconImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(xp_backIconImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)xp_backIconImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBackIconImage:(UIImage *)backIconImage {
    [self setXp_backIconImage:backIconImage];
}

- (UIImage *)backIconImage {
    return [self xp_backIconImage];
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

@end
