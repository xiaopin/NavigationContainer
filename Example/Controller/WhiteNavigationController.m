//
//  WhiteNavigationController.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/31.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "WhiteNavigationController.h"
#import "NavigationBar.h"

@interface WhiteNavigationController ()

@end

@implementation WhiteNavigationController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        UIImage *backImage = [[UIImage imageNamed:@"icon-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        NSDictionary *attributes = @{
                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                    NSForegroundColorAttributeName: [UIColor blackColor],
                                    };
        NavigationBar *navigationBar = [NavigationBar appearance];
        navigationBar.translucent = YES;
        if (@available(iOS 13.0, *)) {
            UINavigationBarAppearance *standardAppearance = [[UINavigationBarAppearance alloc] init];
            standardAppearance.titleTextAttributes = @{
                NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                NSForegroundColorAttributeName: [UIColor redColor],
            };
//            [standardAppearance setBackIndicatorImage:backImage transitionMaskImage:backImage];
            standardAppearance.buttonAppearance.normal.titleTextAttributes = attributes;
            standardAppearance.buttonAppearance.highlighted.titleTextAttributes = attributes;
            navigationBar.standardAppearance = standardAppearance;
        } else {
            navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
//            navigationBar.backIndicatorImage = backImage;
//            navigationBar.backIndicatorTransitionMaskImage = backImage;
            
            UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[NavigationBar class]]];
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
        }
    });
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:NavigationBar.class toolbarClass:toolbarClass];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
