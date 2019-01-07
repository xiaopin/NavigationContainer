//
//  XPRootNavigationController.m
//  https://github.com/xiaopin/NavigationContainer.git
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

#import "XPRootNavigationController.h"
#import <objc/runtime.h>


static char const kXPRootNavigationControllerKey = '\0';

#pragma mark - 容器控制器
@interface XPContainerViewController : UIViewController

@property (nonatomic, weak) UIViewController *contentViewController;
@property (nonatomic, weak) UINavigationController *containerNavigationController;

+ (instancetype)containerViewControllerWithViewController:(UIViewController *)viewController;
- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

@implementation XPContainerViewController

+ (instancetype)containerViewControllerWithViewController:(UIViewController *)viewController {
    return [[self alloc] initWithViewController:viewController];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        if (viewController.parentViewController) {
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
        }
        
        Class cls = [viewController xp_navigationControllerClass];
        NSAssert(![cls isKindOfClass:UINavigationController.class], @"`-xp_navigationControllerClass` must return UINavigationController or its subclasses.");
        UINavigationController *navigationController = [[cls alloc] initWithRootViewController:viewController];
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        self.contentViewController = viewController;
        self.containerNavigationController = navigationController;
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
    }
    return self;
}

@end


#pragma mark - 全局函数

/// 装包
UIKIT_STATIC_INLINE XPContainerViewController* XPWrapViewController(UIViewController *vc)
{
    if ([vc isKindOfClass:XPContainerViewController.class]) {
        return (XPContainerViewController*)vc;
    }
    return [XPContainerViewController containerViewControllerWithViewController:vc];
}

/// 解包
UIKIT_STATIC_INLINE UIViewController* XPUnwrapViewController(UIViewController *vc)
{
    if ([vc isKindOfClass:XPContainerViewController.class]) {
        return ((XPContainerViewController*)vc).contentViewController;
    }
    return vc;
}

/// 替换方法实现
UIKIT_STATIC_INLINE void xp_swizzled(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma mark - 导航栏控制器

@interface XPRootNavigationController ()<UIGestureRecognizerDelegate>
@end

@implementation XPRootNavigationController

#pragma mark Lifecycle

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    XPContainerViewController *container = XPWrapViewController(viewController);
    if (self.viewControllers.count > 0) {
        // 返回按钮目前仅支持图片
        UIImage *backImage = nil;
        if (viewController.backIconImage) {
            backImage = viewController.backIconImage;
        } else if (container.containerNavigationController.backIconImage) {
            backImage = container.containerNavigationController.backIconImage;
        } else {
            backImage = self.backIconImage ?: [self navigationBarBackIconImage];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:viewController action:@selector(xp_popViewController)];
#pragma clang diagnostic pop
        viewController.navigationItem.leftBarButtonItem = backItem;
    }
    [super pushViewController:container animated:animated];
    
    // pop手势
    self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
    
    /**
     * 保留一个`XPRootNavigationController`的弱引用
     * 用于解决用户执行 pop 后立即 push 的使用场景
     *
     * 示例代码:
     * UINavigationController *nav = self.navigationController;
     * [nav popViewControllerAnimated:NO];
     * [nav pushViewController:nil animated:YES];
     */
    objc_setAssociatedObject(container.containerNavigationController, &kXPRootNavigationControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.viewControllers.count > 1);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/// 在pop手势生效后能够确保滚动视图静止
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

#pragma mark Private

- (void)commonInit {
    // 注意: 需要先隐藏导航栏再设置控制器，否则在某些低版本系统下有问题
    [self setNavigationBarHidden:YES animated:NO];
    UIViewController *topViewController = self.topViewController;
    if (topViewController) {
        UIViewController *wrapViewController = XPWrapViewController(topViewController);
        [super setViewControllers:@[wrapViewController] animated:NO];
    }
}

- (UIImage *)navigationBarBackIconImage {
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
    return image;
}

#pragma mark setter & getter

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [super setNavigationBarHidden:YES];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:XPWrapViewController(vc)];
    }
    [super setViewControllers:aViewControllers animated:animated];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    NSMutableArray<UIViewController *> *aViewControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        [aViewControllers addObject:XPWrapViewController(vc)];
    }
    [super setViewControllers:[NSArray arrayWithArray:aViewControllers]];
}

- (NSArray<UIViewController *> *)viewControllers {
    // 返回真正的控制器给外界
    NSMutableArray<UIViewController *> *vcs = [NSMutableArray array];
    NSArray<UIViewController *> *viewControllers = [super viewControllers];
    for (UIViewController *vc in viewControllers) {
        [vcs addObject:XPUnwrapViewController(vc)];
    }
    return [NSArray arrayWithArray:vcs];
}

@end


#pragma mark -

@implementation UIViewController (XPNavigationContainer)

/// 通过返回不同的导航栏控制器可以给每个控制器定制不同的导航栏样式
- (Class)xp_navigationControllerClass {
#ifdef kXPNavigationControllerClassName
    return NSClassFromString(kXPNavigationControllerClassName);
#else
    return [XPContainerNavigationController class];
#endif
}

- (void)setBackIconImage:(UIImage *)backIconImage {
    objc_setAssociatedObject(self, @selector(backIconImage), backIconImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)backIconImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (XPRootNavigationController *)xp_rootNavigationController {
    UIViewController *parentViewController = self.navigationController.parentViewController;
    if (parentViewController && [parentViewController isKindOfClass:XPContainerViewController.class]) {
        XPContainerViewController *container = (XPContainerViewController*)parentViewController;
        return (XPRootNavigationController*)container.navigationController;
    }
    return nil;
}

- (void)xp_popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end


#pragma mark -

@interface UINavigationController (XPNavigationContainer)
@end

@implementation UINavigationController (XPNavigationContainer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *actions = @[
                             NSStringFromSelector(@selector(pushViewController:animated:)),
                             NSStringFromSelector(@selector(popViewControllerAnimated:)),
                             NSStringFromSelector(@selector(popToViewController:animated:)),
                             NSStringFromSelector(@selector(popToRootViewControllerAnimated:)),
                             NSStringFromSelector(@selector(viewControllers)),
                             NSStringFromSelector(@selector(tabBarController))
                             ];
        
        for (NSString *str in actions) {
            xp_swizzled(self, NSSelectorFromString(str), NSSelectorFromString([@"xp_" stringByAppendingString:str]));
        }
    });
}

#pragma mark Private

- (XPRootNavigationController *)rootNavigationController {
    if (self.parentViewController && [self.parentViewController isKindOfClass:XPContainerViewController.class]) {
        XPContainerViewController *containerViewController = (XPContainerViewController *)self.parentViewController;
        XPRootNavigationController *rootNavigationController = (XPRootNavigationController *)containerViewController.navigationController;
        // 如果用户执行了pop操作, 则此时`rootNavigationController`将为nil
        // 将尝试从关联对象中取出`XPRootNavigationController`
        return (rootNavigationController ?: objc_getAssociatedObject(self, &kXPRootNavigationControllerKey));
    }
    return nil;
}

#pragma mark Override

- (void)xp_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    XPRootNavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        return [rootNavigationController pushViewController:viewController animated:animated];
    }
    [self xp_pushViewController:viewController animated:animated];
}

- (UIViewController *)xp_popViewControllerAnimated:(BOOL)animated {
    XPRootNavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        XPContainerViewController *containerViewController = (XPContainerViewController*)[rootNavigationController popViewControllerAnimated:animated];
        return containerViewController.contentViewController;
    }
    return [self xp_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)xp_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    XPRootNavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        XPContainerViewController *container = (XPContainerViewController*)viewController.navigationController.parentViewController;
        NSArray<UIViewController*> *array = [rootNavigationController popToViewController:container animated:animated];
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (UIViewController *vc in array) {
            [viewControllers addObject:XPUnwrapViewController(vc)];
        }
        return viewControllers;
    }
    return [self xp_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)xp_popToRootViewControllerAnimated:(BOOL)animated {
    XPRootNavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        NSArray<UIViewController*> *array = [rootNavigationController popToRootViewControllerAnimated:animated];
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (UIViewController *vc in array) {
            [viewControllers addObject:XPUnwrapViewController(vc)];
        }
        return viewControllers;
    }
    return [self xp_popToRootViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)xp_viewControllers {
    XPRootNavigationController *rootNavigationController = [self rootNavigationController];
    if (rootNavigationController) {
        return [rootNavigationController viewControllers];
    }
    return [self xp_viewControllers];
}

- (UITabBarController *)xp_tabBarController {
    UITabBarController *tabController = [self xp_tabBarController];
    if (self.parentViewController && [self.parentViewController isKindOfClass:XPContainerViewController.class]) {
        if (self.viewControllers.count > 1 && self.topViewController.hidesBottomBarWhenPushed) {
            // 解决滚动视图在iOS11以下版本中底部留白问题
            return nil;
        }
        // Fix issue #4 https://github.com/xiaopin/NavigationContainer/issues/4
        if (!tabController.tabBar.isTranslucent) {
            return nil;
        }
    }
    return tabController;
}

@end


#pragma mark - 状态栏样式 & 屏幕旋转

@implementation XPContainerNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.topViewController) {
        return XPUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.topViewController) {
        return XPUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) preferredStatusBarUpdateAnimation];
    }
    return [super preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) prefersStatusBarHidden];
    }
    return [super prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) preferredInterfaceOrientationForPresentation];
    }
    return [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return XPUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForScreenEdgesDeferringSystemGestures];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) preferredScreenEdgesDeferringSystemGestures];
    }
    return [super preferredScreenEdgesDeferringSystemGestures];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return [XPUnwrapViewController(self.topViewController) prefersHomeIndicatorAutoHidden];
    }
    return [super prefersHomeIndicatorAutoHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    if (self.topViewController) {
        return XPUnwrapViewController(self.topViewController);
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}
#endif

@end
