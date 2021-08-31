//
//  XPNavigationContainer.h
//  https://github.com/xiaopin/NavigationContainer.git
//
//  Created by Pincheng Wu on 2021/8/27.
//  Copyright © 2021 xiaopin. All rights reserved.
//

#ifndef XPNavigationContainer_h
#define XPNavigationContainer_h

/**
 功能：为每个控制器配置单独的导航栏
 
 前提说明：本代码是针对公司项目做的适配，有些场景可能覆盖不全；如果你的项目在使用上遇到任何问题，欢迎提 [Issue](https://github.com/xiaopin/NavigationContainer/issues)。
 
 使用说明：
 1、将源码文件拖入项目
 2、只需将导航栏类设置为`XPRootNavigationController`即可
 3、目前返回按钮仅支持图片，如果你设置了`xp_backIconImage`属性但是发现图标还是蓝色的，
    请检查图片的渲染模式是否为`UIImageRenderingModeAlwaysOriginal`
 4、如果你的项目有自定义的UINavigationController，
    则请在你的项目中定义`kXPNavigationControllerClassName`这个宏，
    如果是个别页面有定制的导航栏，控制器也可以通过重写`-xp_navigationControllerClass`方法返回对应的导航栏
 */

/** #define kXPNavigationControllerClassName    @"YourCustomNavigationController" */

#import "UIViewController+XPNavigationContainer.h"
#import "XPRootNavigationController.h"
#import "XPGradientNavigationBar.h"

#endif /* XPNavigationContainer_h */
