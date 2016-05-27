//
//  AppImages.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-22.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class ALAsset;

extern const CGFloat kDownloadAvatarSize;

typedef NS_ENUM(NSInteger, AppImageType)
{
    AppImageTypeAvatarForChat,        // 聊天界面头像
    AppImageTypeAvatar,        // 头像
    AppImageTypeThumbnail,       // 缩略图
    AppImageTypeOriginal,  // 原始图
};

@interface UIImage (AppImages)

+ (instancetype)defaultUserAvatar;
+ (instancetype)defaultThumbnail;
+ (instancetype)defaultMiShopThumbnail;
+ (instancetype)defaultMiCircleIcon;

/*!
 *  @brief  异步加载图片
 *
 *  @param type       图片类型
 *  @param url        图片地址
 *  @param completion callback
 */
+ (void)asynLoadImageByType:(AppImageType)type
                        url:(NSString *)url
                 completion:(void(^)(UIImage *image))completion;

+ (void)asynLoadImageByType:(AppImageType)type
                        url:(NSString *)url
                  scaleSize:(CGSize)scaleSize
                 completion:(void(^)(UIImage *image))completion;

+ (NSString *)writeImageAssetToLocal:(NSString *)filePath imageOrAsset:(NSObject *)imageOrAsset isThumbnail:(BOOL)thumbnail;
+ (void)deleteImageAssetFromLocal:(NSArray *)filePaths;

+ (NSString *)imageLocalPathWithType:(AppImageType)type url:(NSString *)url;
+ (CGFloat)qualityWithType:(AppImageType)type;



- (UIImage *)scaleAndClipToFillSize:(CGSize)destSize;

- (UIImage *)cropImageInRect:(CGRect)rect;

- (UIImage *)scaleImageToSize:(CGSize)size;

- (UIImage *)gaussianBlurWithRadius:(CGFloat)radius;

- (UIImage *)ellipseImageWithDefaultSetting;

- (UIImage *)ellipseImage:(UIImage *)image
                withInset:(CGFloat)inset
              borderWidth:(CGFloat)width
              borderColor:(UIColor *)color;

@end











