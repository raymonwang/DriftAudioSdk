//
//  DeviceHelper.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-5.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;

#define ABDeviceScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ABDeviceScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface DeviceHelper : NSObject

+ (NSString *)deviceModel;
+ (BOOL)hardwareCameraAvailable;//相机是否存在

@end
