//
//  AppColors.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-1.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AppColors.h"

@implementation UIColor (AppColors)

+ (instancetype)appGlobalRedColor
{
    return [UIColor colorWithRed:230.0f/255 green:81.0f/255 blue:69.0f/255 alpha:1];
}

+ (instancetype)appGlobalGreenColor
{
    return [UIColor colorWithRed:38.0f/255 green:182.0f/255 blue:5.0f/255 alpha:1];
}

+ (instancetype)appGlobalGlodColor
{
    return [UIColor colorWithRed:201.0f/255 green:150.0f/255 blue:37.0f/255 alpha:1];
}

+ (instancetype)appGlobalWhiteColor
{
    return [UIColor colorWithRed:251.0f/255 green:251.0f/255 blue:251.0f/255 alpha:1];
}

+ (instancetype)appGlobalOrangeColor
{
    return [UIColor colorWithRed:255.0f/255 green:159.0f/255 blue:8.0f/255 alpha:1];
}

+ (instancetype)appGlobalBlueColor
{
    return [UIColor colorWithRed:30.0f/255 green:131.0f/255 blue:216.0f/255 alpha:1];
}

+ (instancetype)appGlobalGreyColor
{
    return [UIColor colorWithRed:243.0f/255 green:243.0f/255 blue:243.0f/255 alpha:1];
}

+ (instancetype)appGlobalSplitLineColor
{
    return [UIColor colorWithRed:231.0f/255 green:231.0f/255 blue:231.0f/255 alpha:1];
}

+ (instancetype)navigationBackgroundColor
{
    return [self appGlobalWhiteColor];
}

+ (instancetype)toolBarTextColor
{
    return [self appGlobalRedColor];
}

+ (instancetype)navigationTitleColor
{
    return [UIColor appGlobalRedColor];
}

+ (instancetype)tabBarBackgroundColor
{
    return [UIColor colorWithRed:251.0f/255 green:251.0f/255 blue:251.0f/255 alpha:1];
}

+ (instancetype)tabBarTextColor:(BOOL)selected
{
    return selected ? [self appGlobalRedColor] : [UIColor darkGrayColor];
}

+ (instancetype)tabBarIconSelectedColor
{
    return [self appGlobalRedColor];
}

+ (instancetype)regStateViewBackgroundColor:(BOOL)selected
{
    return selected ? [UIColor colorWithRed:54.0f/255 green:184.0f/255 blue:128.0f/255 alpha:1]:[UIColor colorWithRed:255.0f/255 green:184.0f/255 blue:128.0f/255 alpha:1];
}

+ (instancetype)cellDeleteButtonBackgroundColor
{
    return [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1];

}

+ (instancetype)cellMoreButtonBackgroundColor
{
    return [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1];

}

+ (instancetype)cellMarkButtonBackgroundColor
{
    return [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1];

}

+ (instancetype)globalLoadingBackgroundColor
{
    return [UIColor colorWithRed:251.0f/255 green:251.0f/255 blue:251.0f/255 alpha:1];
}

+ (instancetype)globalCellBackground:(BOOL)selected
{
    return selected ? [self appGlobalSplitLineColor] : [UIColor whiteColor];
}

@end
