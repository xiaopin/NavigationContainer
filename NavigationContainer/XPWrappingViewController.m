//
//  XPWrappingViewController.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "XPWrappingViewController.h"
#import "UIViewController+XPNavigationContainer.h"
#import "XPHelper+NavigationContainer.h"


@interface XPWrappingViewController ()

@end

@implementation XPWrappingViewController

+ (instancetype)wrappingViewControllerWithViewController:(UIViewController *)viewController {
    return [[self alloc] initWithViewController:viewController];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        if (viewController.parentViewController) {
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
        }
        
        Class cls = [viewController xp_navigationControllerClass];
        NSAssert(cls && [cls isSubclassOfClass:UINavigationController.class],
                 @"`-xp_navigationControllerClass` must return UINavigationController or its subclasses.");
        cls = xp_createChildClass(cls);
        UINavigationController *navigationController = [[cls alloc] initWithRootViewController:viewController];
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        navigationController.hidesBottomBarWhenPushed = viewController.hidesBottomBarWhenPushed;
        self->_contentNavigationController = navigationController;
        self->_contentViewController = viewController;
        
        self.tabBarItem = viewController.tabBarItem;
        self.hidesBottomBarWhenPushed = viewController.hidesBottomBarWhenPushed;
        [self addChildViewController:navigationController];
        [self.view addSubview:navigationController.view];
        // Fix Issues #6: https://github.com/xiaopin/NavigationContainer/issues/6
        navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                      views:@{@"view": navigationController.view}]
        ];
        [NSLayoutConstraint activateConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                      views:@{@"view": navigationController.view}]
        ];
        [navigationController didMoveToParentViewController:self];
        
        // Solve the strange problem caused by the global pop gesture of `FDFullscreenPopGesture`
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UIPanGestureRecognizer *fd_fullscreenPopGestureRecognizer = [navigationController performSelector:@selector(fd_fullscreenPopGestureRecognizer)];
        [fd_fullscreenPopGestureRecognizer setEnabled:NO];
        [navigationController performSelector:@selector(setFd_interactivePopDisabled:) withObject:@YES];
#pragma clang diagnostic pop
        } @catch (NSException *exception) {}
    }
    return self;
}
@end
