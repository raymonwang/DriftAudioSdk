//
//  MNCryptor.m
//  MNToolkit
//
//  Created by 陆广庆 on 14/7/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MNCryptor.h"

@implementation MNCryptor 

+ (NSString *) b64Encode:(id)stringOrData
{
    NSParameterAssert([stringOrData isKindOfClass: [NSData class]] || [stringOrData isKindOfClass: [NSString class]]);
    NSData *data;
    if ([stringOrData isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)stringOrData;
        data = [string dataUsingEncoding:NSASCIIStringEncoding];
    } else {
        data = (NSData *)stringOrData;
    }
    NSString *result = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return result;
}

+ (NSString *) b64Decode:(NSString *)b64String
{
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:b64String options:0];
    NSString *result = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    return result;
}

+ (NSData *) b64Decode4Data:(NSString *)b64String
{
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:b64String options:0];
    return decodeData;
}

+ (NSString *) urlEncode:(NSString *)clearText
{
    NSString *result = [clearText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *) urlDecode:(NSString *)urlString
{
    NSString *result = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *) b64Decode:(NSString *)b64String withEncode:(NSStringEncoding)enc
{
    if (!b64String) {
        return nil;
    }
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:b64String options:0];
    NSString *result = [[NSString alloc] initWithData:decodeData encoding:enc];
    return result;
}
@end
















