//
//  XPRootNavigationController.h
//  https://github.com/xiaopin/NavigationContainer.git
//
//  Created by xiaopin on 2018/8/1.
//  Copyright © 2018年 xiaopin. All rights reserved.
//

/**
 * 功能：为每个控制器配置单独的导航栏
 *
 * 使用说明：
 *  前提说明：本代码是针对公司项目做的适配，有些场景可能覆盖不全；
 *          如果你的项目在使用上遇到任何问题，欢迎提 Issue。
 *
 *  1、将`XPRootNavigationController.{h/m}`文件拖入项目
 *
 *  2、只需将导航栏类设置为`XPRootNavigationController`即可
 *
 *  3、目前返回按钮仅支持图片，如果你设置了`backIconImage`属性但是发现图标还是蓝色的，
 *     请检查图片的渲染模式是否为`UIImageRenderingModeAlwaysOriginal`
 *
 *  4、如果你的项目有自定义的UINavigationController，
 *     则请在你的项目中定义`kXPNavigationControllerClassName`这个宏(参考下面示例)，
 *     如果是个别页面有定制的导航栏，控制器也可以通过重写`-xp_navigationControllerClass`方法返回对应的导航栏
 */

#import <UIKit/UIKit.h>

/** #define kXPNavigationControllerClassName    @"UINavigationController" */


/// 仅限于内部使用
NS_CLASS_AVAILABLE_IOS(8_0)
@interface XPContainerNavigationController : UINavigationController
@end


/// 导航栏控制器
NS_CLASS_AVAILABLE_IOS(8_0)
@interface XPRootNavigationController : XPContainerNavigationController

@end


@interface UIViewController (XPNavigationContainer)

/// 返回按钮图标, 默认`nil`
@property (nonatomic, strong) IBInspectable UIImage *backIconImage;

/**
 返回控制器的导航栏,默认`XPContainerNavigationController.class`
 
 你可以通过定义`kXPNavigationControllerClassName`这个宏来返回默认的导航栏,
 子类也可以通过重写这个方法返回单独的导航栏,
 如果你自定义了导航栏之后,记得自己处理状态栏和屏幕旋转等问题

 @return 导航栏控制器类,必须是`UINavigationController`或其子类
 */
- (Class)xp_navigationControllerClass;

/// Default is `nil`
- (XPRootNavigationController *)xp_rootNavigationController;

@end
