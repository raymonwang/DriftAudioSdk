//
//  DeviceHelper.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-5.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
#import "DeviceHelper.h"
#import <sys/utsname.h>

@implementation DeviceHelper

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"Apple#iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"Apple#iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"Apple#iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"Apple#iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"Apple#iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"Apple#iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Apple#iPhone 4 Verizon";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"Apple#iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"Apple#iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"Apple#iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"Apple#iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"Apple#iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"Apple#iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"Apple#iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"Apple#iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Apple#Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Apple#Simulator";
#ifdef  DEBUG
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
#endif
    return [NSString stringWithFormat:@"Apple#%@",deviceString];
}

+ (BOOL)hardwareCameraAvailable
{
    BOOL available = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    return available;
}

@end
