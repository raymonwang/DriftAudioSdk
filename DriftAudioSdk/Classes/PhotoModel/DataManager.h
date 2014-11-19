//
//  DataManager.h
//  DriftAudioSdk
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong)NSMutableArray*    photos;

+ (DataManager *) sharedInstance;

@end
