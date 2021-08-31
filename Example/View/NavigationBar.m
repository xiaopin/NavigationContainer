//
//  NavigationBar.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/31.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "NavigationBar.h"
#import "XPGradientView.h"

@implementation NavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        XPGradientView *gradientView = [self gradientView];
        [gradientView setGradientWithColors:@[
            UIColor.whiteColor,
            UIColor.whiteColor,
        ]];
    }
    return self;
}

@end
