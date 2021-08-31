//
//  XPGradientNavigationBar.h
//  Example
//
//  Created by Pincheng Wu on 2021/8/30.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPGradientView;

/// Gradient color navigation bar
@interface XPGradientNavigationBar : UINavigationBar

@property (nonatomic, strong, readonly) XPGradientView *gradientView;

@end
