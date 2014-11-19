//
//  AppHelper.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AppHelper.h"
@import AVFoundation;
@import CoreLocation;
@import AssetsLibrary;

@implementation AppHelper

+ (BOOL)isBlankOrNil:(NSString *)string
{
    return !string || string == nil || [string length] == 0;
}

#pragma mark -sanbox
+ (NSString *)sandboxPathHome
{
    return NSHomeDirectory();
}

+ (NSString *)sandboxPathApp
{
    return [[NSBundle mainBundle] bundlePath];
}

+ (NSString *)sandboxPathDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)sandboxPathLibrary
{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)sandboxPathLibraryCaches
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)sandboxPathTmp
{
    return NSTemporaryDirectory();
}

+ (NSString *)sandboxFilePath:(NSString *)fileName suffix:(NSString *)suffix;
{
    return [[NSBundle mainBundle] pathForResource:fileName ofType:suffix];
}

+ (NSString *)sandboxFilePath:(NSString *)fileName suffix:(NSString *)suffix inDirectory:(NSString *)directory;
{
    return [[NSBundle mainBundle] pathForResource:fileName ofType:suffix inDirectory:directory];
}

+ (NSString *)sandboxPathImageOriginal
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"original"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageThumbnail
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"thumbnail"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageAvatar
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"avatar"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageAvatarForChat
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"avatar_chat"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageTemp:(BOOL)thumbnail
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = thumbnail ? @"img_tmp_thumb" : @"img_tmp";
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageSend:(BOOL)thumbnail
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = thumbnail ? @"img_send_t" : @"img_send_o";
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathImageRecv:(BOOL)thumbnail
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = thumbnail ? @"img_recv_t" : @"img_recv_o";
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathVoiceSend
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"rec_send"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxPathVoiceRecv
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dir = [[self sandboxPathDocuments] stringByAppendingPathComponent:@"rec_recv"];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSURL *)sandboxFilePathForCoreDataStore:(NSString *)sqliteFileName
{
    //NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsDirectory URLByAppendingPathComponent:[sqliteFileName stringByAppendingString:@".sqlite"]];
}

#pragma mark -UserInterface
+ (UIStoryboard *)stroyboardWithName:(NSString *)stroyboardName
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:stroyboardName bundle:[NSBundle mainBundle]];
    return sb;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(UIViewController *)getControllerFromStoryboard:(NSString *)storyboardname storyControllName:(NSString *)storyControllName
{
    UIStoryboard *storyboard = [AppHelper stroyboardWithName:storyboardname];
    return [storyboard instantiateViewControllerWithIdentifier:storyControllName];
}

+(double)distanceBetweenOrderBy:(double)lat1 lat2:(double)lat2 lng1:(double)lng1 lng2:(double)lng2
{
    CLLocation *orig = [[CLLocation alloc] initWithLatitude:lat1  longitude:lng1];
    CLLocation* dist = [[CLLocation alloc] initWithLatitude:lat2  longitude:lng2];
    
    CLLocationDistance kilometers=[orig distanceFromLocation:dist];

    return   kilometers;
}

+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}

+(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:uiDate];
    return date;
}

+ (UIViewController *)topViewControllerInWondow:(UIWindow *)window
{
    return [self topViewController:window.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

+ (void)hideSoftKeyboard:(UIViewController *)viewController
{
    [viewController.view endEditing:YES];
}

#pragma mark -UserPermission
+ (BOOL)permissionCaptureEnable
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized://已经获得了许可
            return YES;
        case AVAuthorizationStatusDenied://被拒绝了，不能打开
            return NO;
        case AVAuthorizationStatusNotDetermined://不确定是否获得了许可
            return YES;
        case AVAuthorizationStatusRestricted://受限制：已经询问过是否获得许可但被拒绝
            return NO;
        default:
            return NO;
    }
}

+ (BOOL)permissionAlbumEnable
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized://已经获得了许可
            return YES;
        case AVAuthorizationStatusDenied://被拒绝了，不能打开
            return NO;
        case AVAuthorizationStatusNotDetermined://不确定是否获得了许可
            return YES;
        case AVAuthorizationStatusRestricted://受限制：已经询问过是否获得许可但被拒绝
            return NO;
        default:
            return NO;
    }
}

+ (BOOL)permissionLocationEnable
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        switch (authStatus) {
            case AVAuthorizationStatusAuthorized://已经获得了许可
                return YES;
            case AVAuthorizationStatusDenied://被拒绝了，不能打开
                return NO;
            case AVAuthorizationStatusNotDetermined://不确定是否获得了许可
                return YES;
            case AVAuthorizationStatusRestricted://受限制：已经询问过是否获得许可但被拒绝
                return NO;
            default:
                return NO;
        }
    }
    return NO;
}

+ (void)permissionVoiceEnable:(void(^)(BOOL enable))completion
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL available) {
            completion(available);
        }];
    }
}

+ (BOOL)hardwareCameraAvailable
{
    BOOL available = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    return available;
}

@end

@implementation NSString (AppHelper)

- (NSString *)reverse
{
    NSMutableString *result = [NSMutableString string];
    NSUInteger len = [self length];
    for (NSUInteger i = len; i > 0; i--) {
        [result appendString:[self substringWithRange:NSMakeRange(i - 1, 1)]];
    }
    return result;
}

- (NSString*)newDateFrom:(NSString *)from to:(NSString*)format;
{
    NSString* dateStr = self;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:from];
    NSDate *date = [dateFormat dateFromString:self];
    
    [dateFormat setDateFormat:format];
    dateStr = [dateFormat stringFromDate:date];
    return dateStr == nil ? @"" : dateStr;
}

/*
 
- (CGSize)usedSizeForMaxWidth:(CGFloat)width withFont:(UIFont *)font
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, MAXFLOAT)];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:font
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect frame = [layoutManager usedRectForTextContainer:textContainer];
    return CGSizeMake(ceilf(frame.size.width),ceilf(frame.size.height));
    
}

- (CGSize)usedSizeForMaxWidth:(CGFloat)width withAttributes:(NSDictionary *)attributes
{
    NSAttributedString *attrutedString = [[NSAttributedString alloc] initWithString:self attributes:attributes];
    
    UITextView *tempTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    [tempTextView setTextContainerInset:UIEdgeInsetsZero];
    tempTextView.textContainer.lineFragmentPadding = 0;
    
    tempTextView.attributedText = attrutedString;
    [tempTextView.layoutManager glyphRangeForTextContainer:tempTextView.textContainer];
    
    CGRect usedFrame = [tempTextView.layoutManager usedRectForTextContainer:tempTextView.textContainer];
    
    return CGSizeMake(ceilf(usedFrame.size.width),ceilf(usedFrame.size.height));
}
*/

- (CGRect)sizeWithWidth:(CGFloat)width font:(UIFont *)font
{
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:self
                                                                        attributes:@{NSFontAttributeName : font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect;
}

- (CGRect)sizeForTextViewWithWidth:(CGFloat)width font:(UIFont *)font
{
    return [self sizeWithWidth:width - 16.0f font:font];
}

@end

















