//
//  KeyChainHelper.m
//  9youMobileToken
//
//  Created by 陆广庆 on 13-7-5.
//  Copyright (c) 2013年 陆广庆. All rights reserved.
//

#import "KeyChainHelper.h"

@interface KeyChainHelper ()

@property (nonatomic) NSString *storeKey;

@end

@implementation KeyChainHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        _storeKey = [identifier stringByAppendingString:@".appinfo"];
    }
    return self;
}

- (void)save:(NSDictionary *)data
{
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery];
    //删除老数据
    SecItemDelete((__bridge_retained CFDictionaryRef)keyChainQuery);
    //添加新数据
    keyChainQuery[(__bridge_transfer id)kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:data];
    SecItemAdd((__bridge_retained CFDictionaryRef)keyChainQuery, NULL);
}

- (NSDictionary *)load
{
    id ret = nil;
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery];
    keyChainQuery[(__bridge_transfer id)kSecReturnData] = (id)kCFBooleanTrue;
    keyChainQuery[(__bridge_transfer id)kSecMatchLimit] = (__bridge_transfer id)kSecMatchLimitOne;
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keyChainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"KeyChainHelper load %@ failed: %@", _storeKey, e);
        } @finally {
        }
    }
    return ret;
}

- (void)remove
{
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery];
    SecItemDelete((__bridge_retained CFDictionaryRef)keyChainQuery);
}

- (NSMutableDictionary *)getKeyChainQuery
{
    NSDictionary *dic = @{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                          (__bridge_transfer id)kSecAttrService : _storeKey,
                          (__bridge_transfer id)kSecAttrAccount : _storeKey,
                          (__bridge_transfer id)kSecAttrAccessible : (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock};
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dic];
    return result;
}

@end
