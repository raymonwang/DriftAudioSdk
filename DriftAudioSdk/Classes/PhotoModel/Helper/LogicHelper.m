//
//  LogicHelper.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-17.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "LogicHelper.h"
#import "AppColors.h"
#import "AppHelper.h"
#import "MNCryptor.h"
//#import "CoreDataStore.h"
//#import "UserDefaultsStore.h"
@import AssetsLibrary;

/*!
 *  @brief  短信验证间隔 尽量与服务器同步
 */
static NSUInteger const kSmsInterval = 30;
/*!
 *  @brief  重新登录间隔时间
 */
static NSUInteger const kReloginInterval = 60 * 60 * 24;

#define kNoneStrAyy [[NSArray alloc] initWithObjects:@"NONE",@"Nil",@"Null", nil]

@implementation LogicHelper


+ (NSUInteger)calSMSCountdownTime:(NSUInteger)lastSendTime
{
    NSInteger interval = [[NSDate date] timeIntervalSince1970] - lastSendTime;
    if (interval >= 0 && interval <= kSmsInterval) {
        return kSmsInterval - interval;
    }
    return 0;
}

+ (BOOL)overReloginTime:(NSUInteger)lastLoginTime
{
    NSInteger interval = [[NSDate date] timeIntervalSince1970] - lastLoginTime;
    if (interval >= 0 && interval <= kReloginInterval) {
        return NO;
    }
    return YES;
}

+(BOOL)isNone:(NSString *)string
{
    if ([kNoneStrAyy containsObject:string]) {
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)changeNoneString:(NSString *)string
{
    if ([kNoneStrAyy containsObject:string]) {
        return [NSString new];
    }else{
        return string;
    }
}


+ (NSString *)formatString:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"~" withString:@"\n"];
}


//+ (User *)findLoginUser
//{
//    CoreDataStore *store = [CoreDataStore new];
//    UserDefaultsStore *userdefault = [UserDefaultsStore new];
//    NSString *uId = [userdefault loadAppStatus].loginUserIdentifier;
//    User *u = [store loadUser:uId];
//    return u;
//}

+ (NSString *)formatDateMMddHHmm:(NSDate *)date
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setDateFormat:@"MM-dd HH:mm"];
    return [f stringFromDate:date];
}

+ (NSString *)formatDateMMdd:(NSDate *)date
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setDateFormat:@"MM-dd"];
    return [f stringFromDate:date];
}

+ (NSString *)formatDateHHmm:(NSDate *)date
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setDateFormat:@"HH:mm"];
    return [f stringFromDate:date];
}

+ (NSString *)globalErrorMessage:(NSString *)error
{
    if (![AppHelper isBlankOrNil:error]) {
        return error;
    }
    return NSLocalizedString(@"app.global.error.message", nil);
}

+ (NSString *)networkMessage:(NSString *)messageCode
{
    if (![AppHelper isBlankOrNil:messageCode]) {
        NSString *string = [NSString stringWithFormat:@"notwork.code.%@",messageCode];
        return NSLocalizedString(string, nil);
    }
    return NSLocalizedString(@"notwork.code.-1", nil);
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(NSDate *)changeTimeStampToFormatterDate:(NSString *)timeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeStamp integerValue]];
    return confromTimesp;
}

+ (NSString *)randomFileName
{
    NSString *fileName = [self createUUID];
    if ([AppHelper isBlankOrNil:fileName]) {
        fileName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000000];
    }
    return fileName;
}

+ (NSString *)createUUID
{
    NSString *result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result =[NSString stringWithFormat:@"%@",uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}

+ (BOOL)isThumbnail:(NSString *)path
{
    return [path hasSuffix:ThumbnailSuffix];
}

+ (NSString *)appVersionName
{
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    return bundleDict[@"CFBundleShortVersionString"];
}


+ (BOOL)isBlankOrNil:(NSData *)data
{
    return !data || data == nil || [data length] == 0;
}
@end







