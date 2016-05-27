//
//  AppDependencies.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-7-31.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AppDependencies.h"

#import "PhotoAlbumsRouter.h"
#import "PhotoAlbumsHandler.h"
#import "PhotoAlbumsInteractor.h"

#import "PhotoInPhoneRouter.h"
#import "PhotoInPhoneHandler.h"
#import "PhotoInPhoneInteractor.h"

#define InitWrapClass(ClassName, BoardName, ControllerName)    \
    ClassName##Router* p_##ClassName##Router = [ClassName##Router new];    \
    ClassName##Handler* p_##ClassName##Handler = [ClassName##Handler new];   \
    ClassName##Interactor *p_##ClassName##Interactor = [ClassName##Interactor new];    \
    p_##ClassName##Router.handler = p_##ClassName##Handler; \
    p_##ClassName##Handler.router = p_##ClassName##Router;  \
    p_##ClassName##Handler.interactor = p_##ClassName##Interactor;  \
    p_##ClassName##Interactor.handler = p_##ClassName##Handler; \
    p_##ClassName##Interactor.store = store;    \
    p_##ClassName##Interactor.defaultsStore = defaultsStore;    \
    p_##ClassName##Router.storyboardName = BoardName;   \
    p_##ClassName##Router.controllerIdentifier = ControllerName;    \
//p_##ClassName##Handler.userInterface = commonUserInteractor;   \

@interface AppDependencies ()


@end

@implementation AppDependencies

+(AppDependencies *)sharedInstance
{
    static AppDependencies *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureDependencies];
    }
    return self;
}

- (void)installRootView:(UIWindow *)window
{
//    [_rootRouter setupRootView:window];
}

/**
 *  IoC
 */
- (void)configureDependencies
{
    PhotoAlbumsRouter *photoAlbumsRouter = [PhotoAlbumsRouter new];
    self.photoAlbumsHandler = [PhotoAlbumsHandler new];
    PhotoAlbumsInteractor *photoAlbumsInteractor = [PhotoAlbumsInteractor new];
    photoAlbumsRouter.handler = _photoAlbumsHandler;
    _photoAlbumsHandler.router = photoAlbumsRouter;
    _photoAlbumsHandler.interactor = photoAlbumsInteractor;
    photoAlbumsInteractor.handler = _photoAlbumsHandler;
//    miShopDiscussAddRouter.photoAlbumsRouter = photoAlbumsRouter;
//    userInfoRouter.photoAlbumsRouter = photoAlbumsRouter;
    
    //shareInputRouter.photoAlbumsRouter = photoAlbumsRouter;
    //photoAlbumsRouter.shareInputRouter = shareInputRouter;
    
    PhotoInPhoneRouter *photoInPhoneRouter = [PhotoInPhoneRouter new];
    PhotoInPhoneHandler *photoInPhoneHandler = [PhotoInPhoneHandler new];
    PhotoInPhoneInteractor *photoInPhoneInteractor = [PhotoInPhoneInteractor new];
    photoInPhoneRouter.handler = photoInPhoneHandler;
    photoInPhoneHandler.router = photoInPhoneRouter;
    photoInPhoneHandler.interactor = photoInPhoneInteractor;
    photoInPhoneInteractor.handler = photoInPhoneHandler;
    photoAlbumsRouter.photoInPhoneRouter = photoInPhoneRouter;
    photoInPhoneRouter.photoAlbumsRouter = photoAlbumsRouter;
}
@end























