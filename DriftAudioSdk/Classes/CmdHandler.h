//
//  CmdHandler.h
//  freepai_client
//
//  Created by wang3140@hotmail.com on 14-5-22.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum : NSUInteger {
    req_get = 0,
    req_post = 1,
} ReqType;

typedef void (^ReqRet)(id res);

@interface CmdHandler : NSObject

@property (strong, nonatomic)AFHTTPRequestOperationManager* httpManager;

+ (CmdHandler *) sharedInstance;

-(void)postFile:(NSString *)requrl reqParams:(NSDictionary *)reqParams data:(NSData*)data completBlock:(ReqRet)completBlock;

-(void)getFile:(NSString *)requrl reqParams:(NSDictionary *)reqParams completBlock:(ReqRet)completBlock;

@end
