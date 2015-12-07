//
//  CmdHandler.m
//  freepai_client
//
//  Created by wang3140@hotmail.com on 14-5-22.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#import "CmdHandler.h"

@implementation CmdHandler

+(CmdHandler *)sharedInstance
{
    static CmdHandler *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id)init
{
    id p = [super init];
    if (p) {
        if (self.httpManager == nil) {
            self.httpManager = [AFHTTPRequestOperationManager manager];
//            self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"text/plain", nil];
            [self.httpManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
            self.httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [self.httpManager.requestSerializer setTimeoutInterval:15];
        }
        
        return p;
    }
    
    return nil;
}

//-(void)sendReqCmd:(NSString *)reqCmd needHashStr:(NSString *)needHashStr reqParams:(NSDictionary *)reqParams isGetType:(ReqType)isGetType completBlock:(ReqRet)completBlock
//{
//    NSString* urlStr = [NSString stringWithFormat:@"%s%@", FreePaiServerAddress, reqCmd];
//    
//    needHashStr = [NSString stringWithFormat:@"%@", needHashStr];
//    
//    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:reqParams];
//    
//    if (isGetType == req_post) {
//        if (_httpManager) {
//            [_httpManager POST:urlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                completBlock(responseObject);
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                completBlock(error);
//            }];
//        }
//    }
//    else {
//        if (_httpManager) {
//            [_httpManager GET:urlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                completBlock(responseObject);
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                completBlock(error);
//            }];
//        }
//    }
//}

-(void)postFile:(NSString *)requrl reqParams:(NSDictionary *)reqParams data:(NSData*)data completBlock:(ReqRet)completBlock
{
    if (_httpManager) {
        [_httpManager POST:requrl parameters:reqParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"1.txt" mimeType:@"application/octet-stream"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString* string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            completBlock(string);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"上传失败:%@", error);
            completBlock(nil);
        }];
    }
}

-(void)getFile:(NSString *)requrl reqParams:(NSDictionary *)reqParams completBlock:(ReqRet)completBlock
{
    if (_httpManager) {
        [_httpManager GET:requrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completBlock(nil);
        }];
    }
}

@end
