//
//  AppColors.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-1.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;


/**
 *  @brief  App颜色帮助类
 */
@interface UIColor (AppColors)


/*!
 *  @brief  App全局红色
 *
 *  @return
 */
+ (instancetype)appGlobalRedColor;

/*!
 *  @brief  App全局绿色
 *
 *  @return
 */
+ (instancetype)appGlobalGreenColor;

/*!
 *  @brief  App全局金色
 *
 *  @return 
 */
+ (instancetype)appGlobalGlodColor;

/*!
 *  @brief  App全局白色
 *
 *  @return 
 */
+ (instancetype)appGlobalWhiteColor;

/*!
 *  @brief  App全局橘色
 *
 *  @return
 */
+ (instancetype)appGlobalOrangeColor;

/*!
 *  @brief  App全局蓝色
 *
 *  @return
 */
+ (instancetype)appGlobalBlueColor;

/*!
 *  @brief  App全局灰色
 *
 *  @return 
 */
+ (instancetype)appGlobalGreyColor;

/*!
 *  @brief  App全局分割线颜色
 *
 *  @return 
 */
+ (instancetype)appGlobalSplitLineColor;

/**
 *  @brief  全局导航背景颜色
 *
 *  @return
 */
+ (instancetype)navigationBackgroundColor;

/*!
 *  @brief  全局工具栏字体颜色
 *
 *  @return
 */
+ (instancetype)toolBarTextColor;

/**
 *  @brief  全局导航标题颜色
 *
 *  @return
 */
+ (instancetype)navigationTitleColor;

/**
 *  @brief  TabBar背景颜色
 *
 *  @return
 */
+ (instancetype)tabBarBackgroundColor;

/**
 *  @brief  TabBar文字颜色颜色
 *
 *  @return
 */
+ (instancetype)tabBarTextColor:(BOOL)selected;

/**
 *  @brief  TabBar图标颜色
 *
 *  @return
 */
+ (instancetype)tabBarIconSelectedColor;

/**
 *  @brief  注册界面状态选择块背景颜色
 *
 *  @return
 */
+ (instancetype)regStateViewBackgroundColor:(BOOL)selected;

/**
 *  @brief  cell滑动按钮背景颜色
 *  @note   删除
 *  @return
 */
+ (instancetype)cellDeleteButtonBackgroundColor;

/**
 *  @brief  cell滑动按钮背景颜色
 *  @note   更多
 *  @return
 */
+ (instancetype)cellMoreButtonBackgroundColor;

/**
 *  @brief  cell滑动按钮背景颜色
 *  @note   标记
 *  @return
 */
+ (instancetype)cellMarkButtonBackgroundColor;

/*!
 *  @brief  全局加载界面背景颜色
 *
 *  @return
 */
+ (instancetype)globalLoadingBackgroundColor;

/*!
 *  @brief  table cell背景
 *
 *  @return
 */
+ (instancetype)globalCellBackground:(BOOL)selected;


@end
