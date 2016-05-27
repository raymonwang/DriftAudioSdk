//
//  KeyChainHelper.h
//  9youMobileToken
//
//  Created by 陆广庆 on 13-7-5.
//  Copyright (c) 2013年 陆广庆. All rights reserved.
//

@import Foundation;
@import Security;

/**
 *  @class KeyChainHelper keychain帮助类封装
 *  @brief 使用ARC 以键/值存储数据 整存整取 某值有修改需先remove
 *  @note
 *
 *  当前存储安全令用户数据key记录
 *********************************
 *  设备唯一ID: @"token_uuid"
 *  Android设备唯一ID(若有.服务器下发): @"token_uuid_and"
 *  令牌sn: @"token_sn"
 *  令牌pin码: @"token_pin"
 *  绑定帐号: @"bind_" + 1,2,3
 *  绑定帐号密码md5: @"bind_p_" + 1,2,3
 *  手机号(经短信验证后): @"cellphone"   为客服GMTools开发接口用
 *  App启动密码: @"launcher_lock_" + 1(数字密码),2(手势密码)
 **********************************
 */
@interface KeyChainHelper : NSObject

- (void)save:(NSDictionary *)data;
- (NSDictionary *)load;
- (void)remove;

@end

