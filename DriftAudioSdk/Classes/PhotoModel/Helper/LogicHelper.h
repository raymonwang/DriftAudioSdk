//
//  LogicHelper.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-17.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class ALAsset;
@class User;

#define MensesCycle(a) (a>35||a<28)?YES:NO

#define ThumbnailSuffix (@"_thumbnail") 

typedef NS_ENUM(NSInteger, PhotoImageButtonState)
{
    PhotoImageButtonStateNoraml,//未选择照片
    PhotoImageButtonStateChosen//已选择照片
};

@interface LogicHelper : NSObject


/*!
 *  @brief  计算短信发送剩余间隔时间
 *
 *  @param lastSendTime 短信最后发送时间 单位：秒
 *
 *  @return 剩余时间 单位：秒
 */
+ (NSUInteger)calSMSCountdownTime:(NSUInteger)lastSendTime;

+ (BOOL)overReloginTime:(NSUInteger)lastLoginTime;

+ (BOOL)isNone:(NSString *)string;
+ (NSString *)changeNoneString:(NSString *)string;

+ (NSString *)formatString:(NSString *)string;


+ (User *)findLoginUser;

+ (NSString *)formatDateMMddHHmm:(NSDate *)date;
+ (NSString *)formatDateMMdd:(NSDate *)date;
+ (NSString *)formatDateHHmm:(NSDate *)date;

+ (NSString *)globalErrorMessage:(NSString *)error;
+ (NSString *)networkMessage:(NSString *)messageCode;

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (NSDate *)changeTimeStampToFormatterDate:(NSString *)timeStamp;

+ (NSString *)randomFileName;

+ (BOOL)isThumbnail:(NSString *)path;

+ (NSString *)appVersionName;

+ (BOOL)isBlankOrNil:(NSData *)data;
@end
