//
//  BaseTools.m
//  AmericanBaby
//
//  Created by jiangchao on 14-8-21.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "BaseTools.h"

#define ifLog if(YES)

@implementation BaseTools


+(NSDictionary *)decodeJsonString:(NSData*)data
{
    if (data == nil) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *dictFromJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error == nil) {
        return dictFromJson;
    }else{
        ifLog NSLog(@"Json解析失败:%@",error);
    }
    return nil;
}

// 将JSON串转化为字典或者数组
+(id)decodeString:(NSString *)jsonStr {
    if (! jsonStr) {
        return nil;
    }
    
    NSData *strToData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:strToData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}
@end
