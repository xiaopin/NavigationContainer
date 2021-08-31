//
//  XPGradientView.h
//  Example
//
//  Created by Pincheng Wu on 2021/8/30.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

// Gradient view, default horizontal gradient
@interface XPGradientView : UIView

/// The gradient layer
- (CAGradientLayer *)gradientLayer;

/// Set gradient color
/// @param colors       Gradient colors
- (void)setGradientWithColors:(NSArray<UIColor *> *)colors;

/// Set gradient color and gradient position
/// @param colors       Gradient colors
/// @param startPoint   Start gradient position
/// @param endPoint     End gradient position
- (void)setGradientWithColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end
