//
//  XPHelper+NavigationContainer.h
//  Example
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPWrappingViewController;

UIKIT_EXTERN const char kXPRootNavigationControllerKey;

/// Create subclass
/// @param parentClass The parent class
UIKIT_EXTERN Class xp_createChildClass(Class parentClass);

/// Wrapping the view controller
UIKIT_EXTERN XPWrappingViewController* xp_wrappingViewController(UIViewController *viewController);

/// Unwrapping the view controller
UIKIT_EXTERN UIViewController* xp_unwrappingViewController(UIViewController *viewController);
