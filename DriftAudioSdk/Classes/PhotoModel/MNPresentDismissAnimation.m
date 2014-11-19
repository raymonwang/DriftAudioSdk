//
//  MNPresentDismissAnimation.m
//  MNAnimation
//
//  Created by 陆广庆 on 14/7/19.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MNPresentDismissAnimation.h"

@implementation MNPresentDismissAnimation

+ (NSArray *)animationsTypeArray
{
    return @[@"Grow", @"Shrink", @"Fade", @"ShrinkWithRotation", @"GrowWithRotationrow", @"SlideInFromLeft", @"SlideInFromRight", @"SlideInFromTop", @"SlideInFromBottom", @"SlideOutToLeft", @"SlideOutToRight", @"SlideOutToTop", @"SlideOutToBottom", @"SlideInFromLeftWithSpring", @"SlideInFromRightWithSpring", @"SlideInFromTopWithSpring", @"SlideInFromBottomWithSpring"];
}

- (CGFloat)getDuration
{
    return _duration = _duration > 0 ? _duration : 0.25;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _duration = _duration > 0 ? _duration : 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    switch(_animationType){
        case MNControllerAnimationTypeGrow:
            [self performAnimationTypeGrow:transitionContext];
            break;
        case MNControllerAnimationTypeShrink:
            [self performAnimationTypeShrink:transitionContext];
            break;
        case MNControllerAnimationTypeFade:
            [self performAnimationTypeFade:transitionContext];
            break;
        case MNControllerAnimationTypeShrinkWithRotation:
            [self performAnimationTypeShrink:transitionContext withRotation:M_PI];
            break;
        case MNControllerAnimationTypeGrowWithRotation:
            [self performAnimationTypeGrow:transitionContext withRotation:M_PI];
            break;
        case MNControllerAnimationTypeSlideInFromLeft:
            [self performAnimationTypeSlideIn:transitionContext withType:MNControllerAnimationTypeSlideInFromLeft] ;
            break;
        case MNControllerAnimationTypeSlideInFromRight:
            [self performAnimationTypeSlideIn:transitionContext withType:MNControllerAnimationTypeSlideInFromRight];
            break;
        case MNControllerAnimationTypeSlideInFromTop:
            [self performAnimationTypeSlideIn:transitionContext withType:MNControllerAnimationTypeSlideInFromTop];
            break;
        case MNControllerAnimationTypeSlideInFromBottom:
            [self performAnimationTypeSlideIn:transitionContext withType:MNControllerAnimationTypeSlideInFromBottom];
            break;
        case MNControllerAnimationTypeSlideOutToLeft:
            [self performAnimationTypeSlideOut:transitionContext withType:MNControllerAnimationTypeSlideOutToLeft] ;
            break;
        case MNControllerAnimationTypeSlideOutToRight:
            [self performAnimationTypeSlideOut:transitionContext withType:MNControllerAnimationTypeSlideOutToRight];
            break;
        case MNControllerAnimationTypeSlideOutToTop:
            [self performAnimationTypeSlideOut:transitionContext withType:MNControllerAnimationTypeSlideOutToTop];
            break;
        case MNControllerAnimationTypeSlideOutToBottom:
            [self performAnimationTypeSlideOut:transitionContext withType:MNControllerAnimationTypeSlideOutToBottom];
            break;
        case MNControllerAnimationTypeSlideInFromLeftWithSpring:
            [self performAnimationTypeSlideInWithSpring:transitionContext withType:MNControllerAnimationTypeSlideInFromLeftWithSpring];
            break;
        case MNControllerAnimationTypeSlideInFromRightWithSpring:
            [self performAnimationTypeSlideInWithSpring:transitionContext withType:MNControllerAnimationTypeSlideInFromRightWithSpring];
            break;
        case MNControllerAnimationTypeSlideInFromTopWithSpring:
            [self performAnimationTypeSlideInWithSpring:transitionContext withType:MNControllerAnimationTypeSlideInFromTopWithSpring];
            break;
        case MNControllerAnimationTypeSlideInFromBottomWithSpring:
            [self performAnimationTypeSlideInWithSpring:transitionContext withType:MNControllerAnimationTypeSlideInFromBottomWithSpring];
            break;
    }
    
}

- (void)performAnimationTypeGrow:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:to.view];
    UIView *toSnapShotView = [to.view snapshotViewAfterScreenUpdates:YES];
    toSnapShotView.frame = finalFrame;
    [containerView addSubview:toSnapShotView];
    to.view.hidden = YES;
    CGAffineTransform scale = CGAffineTransformMakeScale(.01f, .01f);
    toSnapShotView.transform = scale;
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         toSnapShotView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         to.view.frame = finalFrame;
                         to.view.hidden = NO;
                         [toSnapShotView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)performAnimationTypeShrink:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    to.view.frame = finalFrame;
    [containerView addSubview:to.view];
    [containerView sendSubviewToBack:to.view];
    UIView *snapShotView = [from.view snapshotViewAfterScreenUpdates:NO];
    snapShotView.frame = from.view.frame;
    [containerView addSubview:snapShotView];
    [from.view removeFromSuperview];
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         snapShotView.transform = CGAffineTransformMakeScale(.01f, .01f);
                     } completion:^(BOOL finished) {
                         [snapShotView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    
}

- (void)performAnimationTypeFade:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:to.view];
    to.view.alpha = .2f;
    from.view.alpha = 1.0f;
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         to.view.alpha = 1.0f;
                         from.view.alpha = .2f;
                     } completion:^(BOOL finished) {
                         from.view.alpha = 1.0f;
                         to.view.frame = finalFrame;
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)performAnimationTypeShrink:(id<UIViewControllerContextTransitioning>)transitionContext withRotation: (double)rotation
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    to.view.frame = finalFrame;
    [containerView addSubview:to.view];
    [containerView sendSubviewToBack:to.view];
    UIView *snapShotView = [from.view snapshotViewAfterScreenUpdates:NO];
    snapShotView.frame = from.view.frame;
    [containerView addSubview:snapShotView];
    [from.view removeFromSuperview];
    CGAffineTransform scale = CGAffineTransformMakeScale(.01f, .01f);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(rotation);
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         snapShotView.transform = CGAffineTransformConcat(scale, rotate);
                     } completion:^(BOOL finished) {
                         [snapShotView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    
}

- (void)performAnimationTypeGrow:(id<UIViewControllerContextTransitioning>)transitionContext withRotation:(double)rotation
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:to.view];
    UIView *toSnapShotView = [to.view snapshotViewAfterScreenUpdates:YES];
    toSnapShotView.frame = finalFrame;
    [containerView addSubview:toSnapShotView];
    to.view.hidden = YES;
    CGAffineTransform scale = CGAffineTransformMakeScale(.01f, .01f);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(rotation);
    toSnapShotView.transform = CGAffineTransformConcat(scale, rotate);
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         toSnapShotView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         to.view.frame = finalFrame;
                         to.view.hidden = NO;
                         [toSnapShotView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)performAnimationTypeSlideIn:(id<UIViewControllerContextTransitioning>)transitionContext withType:(MNControllerAnimationType)type
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:to.view];
    CGRect initialRect = to.view.frame;
    switch (type) {
        case MNControllerAnimationTypeSlideInFromLeft:
            initialRect.origin.x = initialRect.origin.x - initialRect.size.width;
            break;
        case MNControllerAnimationTypeSlideInFromRight:
            initialRect.origin.x = initialRect.origin.x + initialRect.size.width;
            break;
        case MNControllerAnimationTypeSlideInFromTop:
            initialRect.origin.y = initialRect.origin.y - initialRect.size.height;
            break;
        case MNControllerAnimationTypeSlideInFromBottom:
            initialRect.origin.y = initialRect.origin.y + initialRect.size.height;
            break;
        default:
            break;
    }
    
    to.view.frame = initialRect;
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         to.view.frame = finalFrame;
                     } completion:^(BOOL finished) {
                         to.view.frame = finalFrame;
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)performAnimationTypeSlideOut:(id<UIViewControllerContextTransitioning>)transitionContext withType:(MNControllerAnimationType)type
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:to];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:to.view];
    [containerView sendSubviewToBack:to.view];
    CGRect finalFromRect = from.view.frame;
    switch (type) {
        case MNControllerAnimationTypeSlideOutToLeft:
            finalFromRect.origin.x = finalFromRect.origin.x - finalFromRect.size.width;
            break;
        case MNControllerAnimationTypeSlideOutToRight:
            finalFromRect.origin.x = finalFromRect.origin.x + finalFromRect.size.width;
            break;
        case MNControllerAnimationTypeSlideOutToTop:
            finalFromRect.origin.y = finalFromRect.origin.y - finalFromRect.size.height;
            break;
        case MNControllerAnimationTypeSlideOutToBottom:
            finalFromRect.origin.y = finalFromRect.origin.y + finalFromRect.size.height;
            break;
        default:
            break;
            
    }
    [UIView animateWithDuration:_duration
                          delay:.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         from.view.frame = finalFromRect;
                     } completion:^(BOOL finished) {
                         to.view.frame = finalFrame;
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)performAnimationTypeSlideInWithSpring:(id<UIViewControllerContextTransitioning>)transitionContext withType:(MNControllerAnimationType)type
{
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGFloat travelDistanceHorizontal = [transitionContext containerView].bounds.size.width + 20;
    CGFloat travelDistanceVertical = [transitionContext containerView].bounds.size.height + 20;
    CGAffineTransform travel;
    switch (type) {
        case MNControllerAnimationTypeSlideInFromLeftWithSpring:
            travel = CGAffineTransformMakeTranslation (travelDistanceHorizontal , 0);
            break;
        case MNControllerAnimationTypeSlideInFromRightWithSpring:
            travel = CGAffineTransformMakeTranslation (-travelDistanceHorizontal , 0);
            break;
        case MNControllerAnimationTypeSlideInFromTopWithSpring:
            travel = CGAffineTransformMakeTranslation (0 , travelDistanceVertical);
            break;
        case MNControllerAnimationTypeSlideInFromBottomWithSpring:
            travel = CGAffineTransformMakeTranslation (0 , -travelDistanceVertical);
            break;
        default:
            break;
            
    }
    
    [[transitionContext containerView] addSubview:to.view];
    to.view.alpha = 0;
    to.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:.75f initialSpringVelocity:.5f options:0x00 animations:^{
        from.view.transform = travel;
        from.view.alpha = 0;
        to.view.transform = CGAffineTransformIdentity;
        to.view.alpha = 1;
    } completion:^(BOOL finished) {
        from.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        from.view.alpha = 1;
    }];
}

@end


















