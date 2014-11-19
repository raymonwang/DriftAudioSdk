//
//  AppWidget.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;

/*!
 *  @brief  自定义控件
 */
@interface AppWidget : NSObject

/**
 *  @brief 创建cell滑出按钮 文字
 *
 *  @param color 颜色
 *  @param title 按钮标题
 *
 *  @return UIButton
 */
+ (UIButton *)buttonForCellWithColor:(UIColor *)color title:(NSString *)title;

/**
 *  @brief 创建cell滑出按钮 图标
 *
 *  @param color 颜色
 *  @param icon 按钮图标
 *
 *  @return UIButton
 */
+ (UIButton *)buttonForCellWithColor:(UIColor *)color icon:(UIImage *)icon;


/*!
 *  @brief  将评级转为星星视图
 *
 *  @param  rate 评级
 *
 *  @return
 */
+ (UIView *)covertRateToStarsView:(NSUInteger)rate;

/*!
 *  @brief  下拉刷新
 *
 *  @return 
 */
+ (UIRefreshControl *)globalRefreshControl;

@end
