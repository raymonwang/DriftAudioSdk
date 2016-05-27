//
//  DataManager.m
//  DriftAudioSdk
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+(DataManager *)sharedInstance
{
    static DataManager *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

@end
