//
//  MNPresentDismissAnimation.h
//  MNAnimation
//
//  Created by 陆广庆 on 14/7/19.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, MNControllerAnimationType)
{
    MNControllerAnimationTypeGrow, //渐现
    MNControllerAnimationTypeShrink,//源缩小
    MNControllerAnimationTypeFade, //渐隐
    MNControllerAnimationTypeShrinkWithRotation, //旋转缩小
    MNControllerAnimationTypeGrowWithRotation,
    MNControllerAnimationTypeSlideInFromLeft,
    MNControllerAnimationTypeSlideInFromRight,
    MNControllerAnimationTypeSlideInFromTop,
    MNControllerAnimationTypeSlideInFromBottom,
    MNControllerAnimationTypeSlideOutToLeft,
    MNControllerAnimationTypeSlideOutToRight,
    MNControllerAnimationTypeSlideOutToTop,
    MNControllerAnimationTypeSlideOutToBottom,
    MNControllerAnimationTypeSlideInFromLeftWithSpring,
    MNControllerAnimationTypeSlideInFromRightWithSpring,
    MNControllerAnimationTypeSlideInFromTopWithSpring,
    MNControllerAnimationTypeSlideInFromBottomWithSpring,
};

@interface MNPresentDismissAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) MNControllerAnimationType animationType;
@property (nonatomic,getter = getDuration) CGFloat duration;

+ (NSArray *)animationsTypeArray;

@end
