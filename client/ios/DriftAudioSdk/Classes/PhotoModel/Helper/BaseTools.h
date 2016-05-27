//
//  BaseTools.h
//  AmericanBaby
//
//  Created by jiangchao on 14-8-21.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseTools : NSObject
//Json解析
+(NSDictionary *)decodeJsonString:(NSData*)data;
+(id)decodeString:(NSString *)jsonStr;
@end
