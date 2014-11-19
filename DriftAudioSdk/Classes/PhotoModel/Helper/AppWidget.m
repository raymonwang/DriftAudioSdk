//
//  AppWidget.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AppWidget.h"
#import "AppColors.h"

@interface AppWidget ()

@end

@implementation AppWidget

+ (UIButton *)buttonForCellWithColor:(UIColor *)color title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)buttonForCellWithColor:(UIColor *)color icon:(UIImage *)icon
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    return button;
}

+ (UIView *)covertRateToStarsView:(NSUInteger)rate
{
    UIImage *starImage = [UIImage imageNamed:@"ic_star_none"];
    UIImage *starFullImage = [UIImage imageNamed:@"ic_star_full"];
    UIImage *starHalfImage = [UIImage imageNamed:@"ic_star_half"];
    
    NSUInteger startCount = rate / 2;
    BOOL half = rate % 2;
    
    CGFloat imageSize = 16;
    NSUInteger starMax = 5;
    UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageSize * starMax, imageSize)];
    for (NSUInteger i = 0; i < startCount; i++) {
        UIImageView *fullStar = [[UIImageView alloc] initWithFrame:CGRectMake(i * imageSize, 0, imageSize, imageSize)];
        fullStar.image = starFullImage;
        [starView addSubview:fullStar];
    }
    
    NSUInteger rest = starMax - startCount;
    
    if (half) {
        UIImageView *halfStar = [[UIImageView alloc] initWithFrame:CGRectMake(startCount * imageSize, 0, imageSize, imageSize)];
        halfStar.image = starHalfImage;
        [starView addSubview:halfStar];
        rest --;
    }
    NSUInteger starX = (starMax - rest) * imageSize;
    for (NSUInteger i = 0; i < rest; i++) {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(starX + imageSize * i, 0, imageSize, imageSize)];
        star.image = starImage;
        [starView addSubview:star];
    }
    return starView;
}

+ (UIRefreshControl *)globalRefreshControl
{
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    return refreshControl;
}

@end











