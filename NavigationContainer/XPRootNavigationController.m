//
//  XPRootNavigationController.m
//  https://github.com/xiaopin/NavigationContainer.git
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import "XPRootNavigationController.h"
#import "XPWrappingViewController.h"
#import "XPHelper+NavigationContainer.h"
#import "UIViewController+XPNavigationContainer.h"
#import <objc/runtime.h>

#define kBackIconCacheFileName  @"xpnc_backicon.png"


@interface XPRootNavigationController ()<UIGestureRecognizerDelegate>
@end

@implementation XPRootNavigationController

#pragma mark - Lifecycle

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    XPWrappingViewController *container = xp_wrappingViewController(viewController);
    if (self.viewControllers.count > 0) {
        UIImage *backImage = nil;
        if (viewController.xp_backIconImage) {
            backImage = viewController.xp_backIconImage;
        } else if (container.contentViewController.xp_backIconImage) {
            backImage = container.contentViewController.xp_backIconImage;
        } else {
            backImage = self.xp_backIconImage ?: [self navigationBarBackIconImage];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(backIconButtonAction:)];
#pragma clang diagnostic pop
        viewController.navigationItem.leftBarButtonItem = backItem;
    }
    [super pushViewController:container animated:animated];
    
    self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
    
    /**
     Keep a weak reference to `XPRootNavigationController`
     Used to solve the usage scenario of push immediately after the user executes pop
     
     Sample code:
        UINavigationController *nav = self.navigationController;
        [nav popViewControllerAnimated:NO];
        [nav pushViewController:nil animated:YES];
     */
    objc_setAssociatedObject(container.contentNavigationController, &kXPRootNavigationControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.viewControllers.count > 1);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/// When the pop gesture takes effect, it can ensure that the scroll view is in a static state
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

#pragma mark - Private

- (void)commonInit {
    // Note: You need to hide the navigation bar before setting the controller, otherwise there will be problems in some low-version systems
    [self setNavigationBarHidden:YES animated:NO];
    UIViewController *topViewController = self.topViewController;
    if (topViewController) {
        UIViewController *wrapViewController = xp_wrappingViewController(topViewController);
        [super setViewControllers:@[wrapViewController] animated:NO];
    }
}

- (UIImage *)navigationBarBackIconImage {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filepath = [cacheDir stringByAppendingPathComponent:kBackIconCacheFileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filepath]) {
        NSData *cacheData = [fm contentsAtPath:filepath];
        UIImage *cacheImage = [UIImage imageWithData:cacheData scale:UIScreen.mainScreen.scale];
        if (cacheImage) {
            return [cacheImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    
    CGSize const size = CGSizeMake(15.0, 21.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    
    UIColor *color = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    [color setFill];
    [color setStroke];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(10.9, 0)];
    [bezierPath addLineToPoint: CGPointMake(12, 1.1)];
    [bezierPath addLineToPoint: CGPointMake(1.1, 11.75)];
    [bezierPath addLineToPoint: CGPointMake(0, 10.7)];
    [bezierPath addLineToPoint: CGPointMake(10.9, 0)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(11.98, 19.9)];
    [bezierPath addLineToPoint: CGPointMake(10.88, 21)];
    [bezierPath addLineToPoint: CGPointMake(0.54, 11.21)];
    [bezierPath addLineToPoint: CGPointMake(1.64, 10.11)];
    [bezierPath addLineToPoint: CGPointMake(11.98, 19.9)];
    [bezierPath closePath];
    [bezierPath setLineWidth:1.0];
    [bezierPath fill];
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:filepath atomically:YES];
    });
    
    return image;
}

- (void)backIconButtonAction:(UIBarButtonItem *)sender {
    [self popViewControllerAnimated:YES];
}

#pragma mark - setter & getter

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [super setNavigationBarHidden:YES];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:xp_wrappingViewController(vc)];
    }
    [super setViewControllers:aViewControllers animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:xp_wrappingViewController(vc)];
    }
    [super setViewControllers:[NSArray arrayWithArray:aViewControllers]];
}

- (NSArray<UIViewController *> *)viewControllers {
    NSMutableArray<UIViewController *> *vcs = [NSMutableArray array];
    NSArray<UIViewController *> *viewControllers = [super viewControllers];
    for (UIViewController *vc in viewControllers) {
        [vcs addObject:xp_unwrappingViewController(vc)];
    }
    return [NSArray arrayWithArray:vcs];
}

- (UIViewController *)visibleViewController {
    UIViewController *vc = [super visibleViewController];
    return xp_unwrappingViewController(vc);
}

#pragma mark - Status bar style & screen rotation

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.topViewController) {
        return xp_unwrappingViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.topViewController) {
        return xp_unwrappingViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) preferredStatusBarUpdateAnimation];
    }
    return [super preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) prefersStatusBarHidden];
    }
    return [super prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) preferredInterfaceOrientationForPresentation];
    }
    return [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return xp_unwrappingViewController(self.topViewController);
    }
    return [super childViewControllerForScreenEdgesDeferringSystemGestures];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) preferredScreenEdgesDeferringSystemGestures];
    }
    return [super preferredScreenEdgesDeferringSystemGestures];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return [xp_unwrappingViewController(self.topViewController) prefersHomeIndicatorAutoHidden];
    }
    return [super prefersHomeIndicatorAutoHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return xp_unwrappingViewController(self.topViewController);
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}
#endif

@end
