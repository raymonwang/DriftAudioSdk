//
//  LocationHelper.m
//  DriftAudioSdk
//
//  Created by raymon_wang on 15/2/27.
//  Copyright (c) 2015年 wang3140@hotmail.com. All rights reserved.
//

#import "LocationHelper.h"
#import <UIKit/UIKit.h>

@interface LocationHelper () {
    callBack    _func;
}

@property (nonatomic)CLLocationManager* locationManager;
@property (nonatomic)CLGeocoder* clGeocoder;

@end


@implementation LocationHelper

-(instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager setDistanceFilter:1000.0f];
    
    self.clGeocoder = [[CLGeocoder alloc] init];
    
    return self;
}

-(void)dealloc
{
    _locationManager = nil;
    _clGeocoder = nil;
}

/// 获取当前经纬度
- (void)requestCurrentEarthPosition:(callBack)func
{
    _func = func;
    [_locationManager startUpdatingLocation];
}

- (void)locationAddressWithCLLocation:(CLLocation*)locationGps
{
    [self.clGeocoder reverseGeocodeLocation:locationGps completionHandler:^(NSArray* placemarks, NSError* error)
     {
         CLPlacemark* placemark = [placemarks objectAtIndex:0];
         NSString* result = [NSString stringWithFormat:@"\"x\":\"%f\",\"y\":\"%f\",\"posinfo\":\"%@\"", locationGps.coordinate.longitude, locationGps.coordinate.latitude, placemark.name];
         _func(result);
     }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] == 0) {
        return;
    }
    
    CLLocation* currentLocation = [locations objectAtIndex:0];
    
    if (signbit(currentLocation.horizontalAccuracy)) {
        return;
    }
    
    [_locationManager stopUpdatingLocation];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [self locationAddressWithCLLocation:currentLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位出现错误!");
}

@end
