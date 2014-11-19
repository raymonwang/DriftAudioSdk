//
//  AppHelper.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface AppHelper : NSObject

// 为空
+ (BOOL)isBlankOrNil:(NSString *)string;

// 用户权限
+ (BOOL)permissionCaptureEnable;
+ (BOOL)permissionAlbumEnable;
+ (BOOL)permissionLocationEnable;
+ (void)permissionVoiceEnable:(void(^)(BOOL enable))completion;

// 设备是否有相机
+ (BOOL)hardwareCameraAvailable;

//sandbox path
+ (NSString *)sandboxPathHome;
+ (NSString *)sandboxPathApp;
+ (NSString *)sandboxPathDocuments;
+ (NSString *)sandboxPathLibrary;
+ (NSString *)sandboxPathLibraryCaches;
+ (NSString *)sandboxPathTmp;
+ (NSString *)sandboxFilePath:(NSString *)fileName suffix:(NSString *)suffix;
+ (NSString *)sandboxFilePath:(NSString *)fileName suffix:(NSString *)suffix inDirectory:(NSString *)directory;
+ (NSURL *)sandboxFilePathForCoreDataStore:(NSString *)sqliteFileName;
+ (NSString *)sandboxPathImageOriginal;
+ (NSString *)sandboxPathImageThumbnail;
+ (NSString *)sandboxPathImageAvatar;
+ (NSString *)sandboxPathImageAvatarForChat;
+ (NSString *)sandboxPathImageTemp:(BOOL)thumbnail;
+ (NSString *)sandboxPathImageSend:(BOOL)thumbnail;
+ (NSString *)sandboxPathImageRecv:(BOOL)thumbnail;
+ (NSString *)sandboxPathVoiceSend;
+ (NSString *)sandboxPathVoiceRecv;


+ (UIViewController *)topViewControllerInWondow:(UIWindow *)window;// 获取栈顶视图
+ (UIStoryboard *)stroyboardWithName:(NSString *)stroyboardName;// 获取sb
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;// 确认对话框

//从资源获取视图控制器
+ (UIViewController*)getControllerFromStoryboard:(NSString*)storyboardname storyControllName:(NSString*)storyControllName;

/// 两点距离计算
+(double)distanceBetweenOrderBy:(double)lat1 lat2:(double)lat2 lng1:(double)lng1 lng2:(double)lng2;

/// 计算年龄
+(NSInteger)ageWithDateOfBirth:(NSDate *)date;

+(NSDate*) convertDateFromString:(NSString*)uiDate;

@end

@interface NSString (AppHelper)

// 字符串翻转
- (NSString *)reverse;


// 日期转换
- (NSString *)newDateFrom:(NSString *)from to:(NSString*)format;

- (CGRect)sizeWithWidth:(CGFloat)width font:(UIFont *)font;
- (CGRect)sizeForTextViewWithWidth:(CGFloat)width font:(UIFont *)font;


@end