//
//  AppNotificationCenter.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;

// 数据key
extern NSString * const kAppNotificationCenterDataKeyMiChatFriends;

typedef NS_ENUM(NSInteger, AppNotificationType)
{
    AppNotificationTypeLocationChanged,
    AppNotificationTypeApplicationWillEnterForeground,
    AppNotificationTypeApplicationDidEnterBackground,
    
    AppNotificationTypeLoginRegisterCompleted,
    
    AppNotificationTypeTabBarRootViewDidAppear,
    AppNotificationTypeTabBarRootViewWillDisappear,
    
    // AppNotificationTypeOnRecvMiChatFriends,//userInfo[@"friends"] : Nsarray MiChatFriends; 好友列表不走通知
    AppNotificationTypeOnRecvMiChatMessage,//userInfo[@"messages"] : Nsarray MiChatMessgaes;
    AppNotificationTypeOnSendMiChatMessageResponse,//userInfo[@"response"] : BaseResponse;
    
    // 相册选取完照片
    AppNotificationTypePhotoAlbumSelectCompleted,
    
};



@interface AppNotificationCenter : NSObject

+ (void)postNotification:(AppNotificationType)type;
+ (void)postNotification:(AppNotificationType)type withUserInfo:(NSDictionary *)userInfo;
+ (void)registerNotification:(AppNotificationType)type receiver:(id)receiver action:(SEL)action;
+ (void)removeNotification:(AppNotificationType)type receiver:(id)receiver;




@end
