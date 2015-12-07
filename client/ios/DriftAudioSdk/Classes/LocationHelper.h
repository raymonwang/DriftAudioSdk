//
//  LocationHelper.h
//  DriftAudioSdk
//
//  Created by raymon_wang on 15/2/27.
//  Copyright (c) 2015年 wang3140@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^callBack)(NSString* callbackdata);

@interface LocationHelper : NSObject <CLLocationManagerDelegate>

/// 获取当前经纬度
- (void)requestCurrentEarthPosition:(callBack)func;

@end
