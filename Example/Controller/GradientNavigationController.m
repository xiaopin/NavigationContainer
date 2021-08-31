//
//  GradientNavigationController.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/31.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "GradientNavigationController.h"
#import "XPNavigationContainer.h"

@interface GradientNavigationController ()

@end

@implementation GradientNavigationController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        UIImage *backImage = [[UIImage imageNamed:@"icon-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        NSDictionary *attributes = @{
                                    NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                    };
        XPGradientNavigationBar *navigationBar = [XPGradientNavigationBar appearance];
        navigationBar.translucent = YES;
        if (@available(iOS 13.0, *)) {
            UINavigationBarAppearance *standardAppearance = [[UINavigationBarAppearance alloc] init];
            standardAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
//            [standardAppearance setBackIndicatorImage:backImage transitionMaskImage:backImage];
            standardAppearance.buttonAppearance.normal.titleTextAttributes = attributes;
            standardAppearance.buttonAppearance.highlighted.titleTextAttributes = attributes;
            navigationBar.standardAppearance = standardAppearance;
        } else {
            navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
//            navigationBar.backIndicatorImage = backImage;
//            navigationBar.backIndicatorTransitionMaskImage = backImage;
            
            UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[XPGradientNavigationBar class]]];
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self xp_setNavigationBarWithGradientColors:@[
        [UIColor purpleColor],
        [UIColor redColor],
        [UIColor orangeColor]
    ]];
}

@end
