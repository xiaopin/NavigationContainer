//
//  XPHelper+NavigationContainer.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "XPHelper+NavigationContainer.h"
#import "XPWrappingViewController.h"
#import "UIViewController+XPNavigationContainer.h"
#import <objc/message.h>

char const kXPRootNavigationControllerKey = '\0';

#pragma mark - Override

void xpnc_add_method(Class cls, SEL sel, IMP imp) {
    Method method = class_getInstanceMethod(cls, sel);
    const char *type = method_getTypeEncoding(method);
    class_addMethod(cls, sel, imp, type);
}

/// class
Class xpnc_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

/// pushViewController:animated:
void xpnc_pushViewController_animated(id self, SEL _cmd, UIViewController *viewController, BOOL animated) {
    if ([self isViewLoaded]) {
        id nav = [self xp_rootNavigationController];
        ((void (*)(id, SEL, id, BOOL))objc_msgSend)(nav, _cmd, viewController, animated);
        return;
    }
    // Forward the message to the parent class
    struct objc_super super_struct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    ((void (*)(void*, SEL, id, BOOL))objc_msgSendSuper)(&super_struct, _cmd, viewController, animated);
}

/// popViewControllerAnimated:
void xpnc_popViewControllerAnimated(id self, SEL _cmd, BOOL animated) {
    id nav = [self xp_rootNavigationController];
    ((void (*)(id, SEL, BOOL))objc_msgSend)(nav, _cmd, animated);
}

/// popToViewController:animated:
void xpnc_popToViewController_animated(id self, SEL _cmd, UIViewController *viewController, BOOL animated) {
    id nav = [self xp_rootNavigationController];
    ((void (*)(id, SEL, id, BOOL))objc_msgSend)(nav, _cmd, viewController, animated);
}

/// popToRootViewControllerAnimated:
void xpnc_popToRootViewControllerAnimated(id self, SEL _cmd, BOOL animated) {
    id nav = [self xp_rootNavigationController];
    ((void (*)(id, SEL, BOOL))objc_msgSend)(nav, _cmd, animated);
}

/// viewControllers
NSArray* xpnc_viewControllers(id self, SEL _cmd) {
    id nav = [self xp_rootNavigationController];
    return ((id (*)(id, SEL))objc_msgSend)(nav, _cmd);
}

/// setViewControllers
void xpnc_setViewControllers(id self, SEL _cmd, NSArray *viewControllers) {
    id nav = [self xp_rootNavigationController];
    ((id (*)(id, SEL, id))objc_msgSend)(nav, _cmd, viewControllers);
}

/// setViewControllers:animated:
void xpnc_setViewControllers_animated(id self, SEL _cmd, NSArray *viewControllers, BOOL animated) {
    id nav = [self xp_rootNavigationController];
    ((id (*)(id, SEL, id, BOOL))objc_msgSend)(nav, _cmd, viewControllers, animated);
}

/// visibleViewController
UIViewController* xpnc_visibleViewController(id self, SEL _cmd) {
    id nav = [self xp_rootNavigationController];
    return ((id (*)(id, SEL))objc_msgSend)(nav, _cmd);
}

/// tabBarController
UITabBarController* xpnc_tabBarController(UINavigationController* self, SEL _cmd) {
    id nav = [self xp_rootNavigationController];
    UITabBarController *tabBarController = ((id (*)(id, SEL))objc_msgSend)(nav, _cmd);
    if (UIDevice.currentDevice.systemVersion.doubleValue < 11.0) {
        // Solve the problem that the bottom of the scroll view is blank in iOS11 and below
        if (self.viewControllers.count > 1 && self.topViewController.hidesBottomBarWhenPushed) {
            return nil;
        }
    }
    // Fix issue #4 https://github.com/xiaopin/NavigationContainer/issues/4
    if (NO == tabBarController.tabBar.isTranslucent) return nil;
    return tabBarController;
}

/// interactivePopGestureRecognizer
UIPanGestureRecognizer* xpnc_interactivePopGestureRecognizer(id self, SEL _cmd) {
    id nav = [self xp_rootNavigationController];
    return ((id (*)(id, SEL))objc_msgSend)(nav, _cmd);
}

#pragma mark - Public

/// Create subclass
/// @param parentClass The parent class
Class xp_createChildClass(Class parentClass) {
    const char *className = [[@"XPNC_" stringByAppendingString:NSStringFromClass(parentClass)] UTF8String];
    Class childClass = objc_getClass(className);
    if (childClass) return childClass;
    childClass = objc_allocateClassPair(parentClass, className, 0);
    objc_registerClassPair(childClass);

    // Override method implementation
    xpnc_add_method(childClass, @selector(class), (IMP)xpnc_class);
    xpnc_add_method(childClass, @selector(pushViewController:animated:), (IMP)xpnc_pushViewController_animated);
    xpnc_add_method(childClass, @selector(popViewControllerAnimated:), (IMP)xpnc_popViewControllerAnimated);
    xpnc_add_method(childClass, @selector(popToViewController:animated:), (IMP)xpnc_popToViewController_animated);
    xpnc_add_method(childClass, @selector(popToRootViewControllerAnimated:), (IMP)xpnc_popToRootViewControllerAnimated);
    xpnc_add_method(childClass, @selector(viewControllers), (IMP)xpnc_viewControllers);
    xpnc_add_method(childClass, @selector(setViewControllers:), (IMP)xpnc_setViewControllers);
    xpnc_add_method(childClass, @selector(setViewControllers:animated:), (IMP)xpnc_setViewControllers_animated);
    xpnc_add_method(childClass, @selector(visibleViewController), (IMP)xpnc_visibleViewController);
    xpnc_add_method(childClass, @selector(tabBarController), (IMP)xpnc_tabBarController);
    xpnc_add_method(childClass, @selector(interactivePopGestureRecognizer), (IMP)xpnc_interactivePopGestureRecognizer);
    
    return childClass;
}

/// Wrapping the view controller
XPWrappingViewController* xp_wrappingViewController(UIViewController *viewController) {
    if ([viewController isKindOfClass:XPWrappingViewController.class]) {
        return (XPWrappingViewController*)viewController;
    }
    return [XPWrappingViewController wrappingViewControllerWithViewController:viewController];
}

/// Unwrapping the view controller
UIViewController* xp_unwrappingViewController(UIViewController *viewController) {
    if ([viewController isKindOfClass:XPWrappingViewController.class]) {
        return [(XPWrappingViewController*)viewController contentViewController];
    }
    return viewController;
}
