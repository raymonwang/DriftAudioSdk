//
//  MNCryptor+MD5.m
//  MNToolkit
//
//  Created by 陆广庆 on 14/7/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MNCryptor.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 4096

@implementation MNCryptor (md5Hash)

+ (NSString *) md5:(id)stringOrData
{
    NSParameterAssert([stringOrData isKindOfClass: [NSData class]] || [stringOrData isKindOfClass: [NSString class]]);
    const char *c;
    if ([stringOrData isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)stringOrData;
        c = [string UTF8String];
    } else {
        NSData *data = (NSData *)stringOrData;
        c = (const char *)[data bytes];
    }
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5( c, (CC_LONG)strlen(c), digist );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [result appendFormat:@"%02x",digist[i]];
    }
    return result;
}

+ (NSString *) md5File:(NSString *)filePath
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filePath,FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData) {
    
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                     (CFStringRef)filePath,
                                                     kCFURLPOSIXPathStyle,
                                                     (Boolean)false);
    
    if (!fileURL) goto done;
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)fileURL);
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1)break;
        if (readBytesCount == 0) {
            hasMoreData =false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    didSucceed = !hasMoreData;
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    if (!didSucceed) goto done;
    
    char hash[2 *sizeof(digest) + 1];
    for (size_t i =0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+ (NSString *) md5To16bit:(NSString *)md5_32bit
{
    NSString *md5_16 = [[md5_32bit substringToIndex:24] substringFromIndex:8];
    return md5_16;
}

@end
















