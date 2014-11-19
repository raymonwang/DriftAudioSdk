//
//  AppDependencies.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-7-31.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@import Foundation;

#import "PhotoAlbumsHandler.h"

/**
 *  @class AppDependencies
 *  @brief 依赖注入
 */
@interface AppDependencies : NSObject

@property (nonatomic) PhotoAlbumsHandler* photoAlbumsHandler;

+ (AppDependencies *) sharedInstance;

- (void)installRootView:(UIWindow *)window;

@end
