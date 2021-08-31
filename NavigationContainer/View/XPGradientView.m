//
//  XPGradientView.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/30.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "XPGradientView.h"

@implementation XPGradientView

#pragma mark - Lifecycle

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.5);
}

#pragma mark - Public

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

- (void)setGradientWithColors:(NSArray<UIColor *> *)colors {
    NSMutableArray *mColors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [mColors addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = [NSArray arrayWithArray:mColors];
}

- (void)setGradientWithColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    [self setGradientWithColors:colors];
    self.gradientLayer.startPoint = startPoint;
    self.gradientLayer.endPoint = endPoint;
}

@end
