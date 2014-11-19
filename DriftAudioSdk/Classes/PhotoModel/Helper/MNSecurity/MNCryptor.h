//
//  MNCryptor.h
//  MNToolkit
//
//  Created by 陆广庆 on 14/7/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;

/**
 *  @class MNCryptor
 *  @brief 加密工具类
 */
@interface MNCryptor : NSObject

#pragma mark -Base64编码
+ (NSString *) b64Encode:(id)stringOrData;
+ (NSString *) b64Decode:(NSString *)b64String;
+ (NSString *) b64Decode:(NSString *)b64String withEncode:(NSStringEncoding)enc;
+ (NSData *)   b64Decode4Data:(NSString *)b64String;

#pragma mark -URL编码
+ (NSString *) urlEncode:(NSString *)clearText;
+ (NSString *) urlDecode:(NSString *)urlString;

@end

#pragma mark -OTP
@interface MNCryptor (OTP)
// 根据时间戳生成动态密码 30秒间隔
+ (NSString *) oneTimePassword:(NSString *)gen serverTime:(unsigned long long)serverTimeSecond;

@end

#pragma mark -MD5 HASH
@interface MNCryptor (md5Hash)

+ (NSString *) md5:(id)stringOrData;
+ (NSString *) md5File:(NSString *)filePath;
+ (NSString *) md5To16bit:(NSString *)md5_32bit;

@end

#pragma mark -SHA HASH
@interface MNCryptor (shaHash)

+ (NSString *) sha1:(id)stringOrData;
+ (NSString *) sha224:(id)stringOrData;
+ (NSString *) sha256:(id)stringOrData;
+ (NSString *) sha384:(id)stringOrData;
+ (NSString *) sha512:(id)stringOrData;

+ (NSString *) sha1File:(NSString *)filePath;
+ (NSString *) sha224File:(NSString *)filePath;
+ (NSString *) sha256File:(NSString *)filePath;
+ (NSString *) sha384File:(NSString *)filePath;
+ (NSString *) sha512File:(NSString *)filePath;

@end

#pragma mark -AES
@interface MNCryptor (AES)

+ (NSData *) aes256Encrypt:(id)stringOrData key:(id)key;
+ (NSData *) aes256Decrypt:(id)stringOrData key:(id)key;

+ (BOOL)     aes256EncryptFile:(NSString *)filePath
                            to:(NSString *)targetFilePath
                            key:(id)key;
+ (BOOL)     aes256DecryptFile:(NSString *)filePath
                            to:(NSString *)targetFilePath
                            key:(id)key;
@end

#pragma mark -RSA
@interface MNCryptor (RSA)

+ (SecKeyRef) rsaPublicKeyRef:(NSString *)publicKeyPath;
+ (SecKeyRef) rsaPrivateKeyRef:(NSString *)privateKeyPath keyPassword:(NSString *)password;
+ (NSData *)  rsaEncryptWithPublicKey:(NSData *)data publicKeyRef:(SecKeyRef)publicKeyRef;
+ (NSData *)  rsaDecryptWithPrivateKey:(NSData *)data privateKeyRef:(SecKeyRef)privateKeyRef;

+ (NSData *)  rsaSignWithPrivateKey:(NSData *)data privateKeyRef:(SecKeyRef)privateKeyRef;
+ (BOOL)      rsaVerifyWithPublicKey:(NSData *)data signature:(NSData *)signature publicKeyRef:(SecKeyRef)publicKeyRef;


@end































