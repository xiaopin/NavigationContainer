//
//  XPGradientNavigationBar.m
//  Example
//
//  Created by Pincheng Wu on 2021/8/30.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import "XPGradientNavigationBar.h"
#import "XPGradientView.h"
#import "XPHelper+NavigationContainer.h"
#import <objc/runtime.h>

@implementation XPGradientNavigationBar

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTranslucent:YES];
        self->_gradientView = [[XPGradientView alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self->_gradientView.superview) {
        UIView *barBackgroundView = self.subviews.firstObject;
        if (@available(iOS 10.0, *)) {
            UIView *targetView = nil;
            if (@available(iOS 14.0, *)) {
                targetView = barBackgroundView;
            } else {
                targetView = barBackgroundView.subviews.lastObject.subviews.lastObject;
            }
            if (nil == targetView) return;
            [self addGradientViewForSuperview:targetView];
        } else {
            for (UIView *subview in barBackgroundView.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIBackdropView")]) {
                    [self addGradientViewForSuperview:subview];
                    break;
                }
            }
        }
    }
}

- (void)setTranslucent:(BOOL)translucent {
    [super setTranslucent:YES];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    BOOL isNeedForward = (view && view.nextResponder && [view.nextResponder isKindOfClass:UINavigationBar.class]);
    if (NO == isNeedForward) return view;
    /**
     When event penetration is enabled and the transparency is less than or equal to 0.1,
     the event is forwarded to the current view controller
     */
    BOOL isEventPenetration = [objc_getAssociatedObject(self, &kXPNavigationBarEventPenetrateKey) boolValue];
    CGFloat alpha = [objc_getAssociatedObject(self, &kXPNavigationBarTransparencyKey) floatValue];
    if (isEventPenetration && alpha <= 0.1) {
        UINavigationController *nav = nil;
        UIResponder *responder = view.nextResponder;
        while (responder) {
            if ([responder isKindOfClass:UINavigationController.class]) {
                nav = (UINavigationController *)responder;
                break;
            }
            responder = responder.nextResponder;
        }
        if (nav && nav.topViewController) {
            view = nav.topViewController.view;
            point.y += self.frame.origin.y;
            UIView *hitView = [view hitTest:point withEvent:event];
            if (hitView) view = hitView;
        }
    }
    return view;
}

#pragma mark - Private

- (void)addGradientViewForSuperview:(UIView *)superview {
    [superview addSubview:self->_gradientView];
    [self->_gradientView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = @{ @"view": self->_gradientView };
    NSArray *array1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views];
    NSArray *array2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views];
    [NSLayoutConstraint activateConstraints:array1];
    [NSLayoutConstraint activateConstraints:array2];
}

@end
