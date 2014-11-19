//
//  AppImages.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-22.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import AssetsLibrary;
#import "AppImages.h"
#import "MNCryptor.h"
#import "AppHelper.h"
#import "LogicHelper.h"

#define ifLog if(YES)
#define ABDEVICE_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define ABDEVICE_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

static const CGFloat kThumbnailRate = 0.4f; // 缩略图压缩质量比
static const CGFloat kImageRate = 0.4f; // 原图压缩质量比

static const CGFloat kThumbnailSize = 80;
const CGFloat kDownloadAvatarSize = 100;
static const CGFloat kDownloadAvatarChatSize = 25;

@implementation UIImage (AppImages)

+ (instancetype)defaultUserAvatar
{
    return [self imageNamed:@"img_default_avatar"];
}

+ (instancetype)defaultThumbnail
{
    return [self imageNamed:@"default_image_thumbnail"];
}

+ (instancetype)defaultMiShopThumbnail
{
    return [self imageNamed:@"default_mishop_thumbnail"];
}

+ (instancetype)defaultMiCircleIcon
{
    return [self imageNamed:@"ic_default_micircle"];
}

+ (void)asynLoadImageByType:(AppImageType)type
                        url:(NSString *)url
                 completion:(void(^)(UIImage *image))completion
{
    CGSize size = CGSizeZero;
    if (type == AppImageTypeAvatar) {
        size = CGSizeMake(kDownloadAvatarSize, kDownloadAvatarSize);
    } else if (type == AppImageTypeAvatarForChat) {
        size = CGSizeMake(kDownloadAvatarChatSize, kDownloadAvatarChatSize);
    }
    [self asynLoadImageByType:type url:url scaleSize:size completion:completion];
}

+ (void)asynLoadImageByType:(AppImageType)type
                        url:(NSString *)url
                  scaleSize:(CGSize)scaleSize
                 completion:(void(^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [self imageLocalPathWithType:type url:url];
        if (filePath == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
                return;
            });
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *resultImage = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(resultImage);
            });
            ifLog {
                long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileSize];
                NSLog(@"fileSize:%lld kb width:%f height:%f",fileSize / 1024,resultImage.size.width,resultImage.size.height);
            }
            return;
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        NSURLSessionTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(location == nil || error != nil || [httpResponse statusCode] != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
                return;
            }
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *image = [UIImage imageWithData:data];
            if (!CGSizeEqualToSize(CGSizeZero,scaleSize)) {
                image = [image scaleAndClipToFillSize:scaleSize];
            }
            if([[url pathExtension] isEqualToString:@"png"]) {
                [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
            } else {
                [UIImageJPEGRepresentation(image, [self qualityWithType:type]) writeToFile:filePath atomically:YES];
            }
            ifLog {
                long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileSize];
                NSLog(@"fileSize:%lld kb width:%f height:%f",fileSize / 1024,image.size.width,image.size.height);
            }
            UIImage *resultImage = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(resultImage);
            });
        }];
        [task resume];
    });
}

+ (NSString *)imageLocalPathWithType:(AppImageType)type url:(NSString *)url
{
    if (!url || url == nil || [url length] == 0)
        return nil;
    NSString *fileName = [MNCryptor md5:url];
    NSString *root;
    switch (type) {
        case AppImageTypeAvatarForChat:
            root = [AppHelper sandboxPathImageAvatarForChat];
            break;
        case AppImageTypeAvatar:
            root = [AppHelper sandboxPathImageAvatar];
            break;
        case AppImageTypeThumbnail:
            root = [AppHelper sandboxPathImageThumbnail];
            break;
        case AppImageTypeOriginal:
            root = [AppHelper sandboxPathImageOriginal];
            break;
    }
    NSString *filePath = [root stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (CGFloat)qualityWithType:(AppImageType)type
{
    switch (type) {
        case AppImageTypeAvatarForChat:
            return .6f;
        case AppImageTypeAvatar:
            return .6f;
        case AppImageTypeThumbnail:
            return .6f;
        case AppImageTypeOriginal:
            return .6f;
    }
}

+ (NSString *)writeImageAssetToLocal:(NSString *)filePath imageOrAsset:(NSObject *)imageOrAsset isThumbnail:(BOOL)thumbnail
{
    if (thumbnail) {
        filePath = [filePath stringByAppendingString:ThumbnailSuffix];
    }
    if ([imageOrAsset isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)imageOrAsset;
        return [self writeAssetToLocal:filePath asset:asset isThumbnail:thumbnail];
    } else if ([imageOrAsset isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)imageOrAsset;
        return [self writeImageToLocal:filePath image:image isThumbnail:thumbnail];
    }
    return [NSString new];
}

+ (NSString *)writeAssetToLocal:(NSString *)filePath asset:(ALAsset *)asset isThumbnail:(BOOL)thumbnail
{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    long long size = representation.size;
    NSUInteger usize = (unsigned int)size;
    NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:usize];
    void *buffer = [rawData mutableBytes];
    [representation getBytes:buffer fromOffset:0 length:usize error:nil];
    NSData *assetData = [[NSData alloc] initWithBytes:buffer length:usize];
    UIImage *image = [UIImage imageWithData:assetData];
    
    filePath = [self writeImageToLocal:filePath image:image isThumbnail:thumbnail];
    return filePath;

}

+ (NSString *)writeImageToLocal:(NSString *)filePath image:(UIImage *)image isThumbnail:(BOOL)thumbnail
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat scaleRatio;
    if (width == height) {
        image = [image scaleAndClipToFillSize:CGSizeMake(ABDEVICE_SCREEN_WIDTH, ABDEVICE_SCREEN_WIDTH)];
    } else if (width > height) {
        scaleRatio = ABDEVICE_SCREEN_WIDTH / height;
        image = [image scaleAndClipToFillSize:CGSizeMake(width * scaleRatio, ABDEVICE_SCREEN_WIDTH)];
    } else if (width < height) {
        scaleRatio = ABDEVICE_SCREEN_WIDTH / width;
        image = [image scaleAndClipToFillSize:CGSizeMake(ABDEVICE_SCREEN_WIDTH, height * scaleRatio)];
    }
    
    if (thumbnail) {
        width = image.size.width;
        height = image.size.height;
        if (width > height) {
            image = [image cropImageInRect:CGRectMake((width - height) / 2, 0, height, height)];
        } else if (width < height) {
            image = [image cropImageInRect:CGRectMake(0, (height - width) / 2, width, width)];
        }
        image = [image scaleAndClipToFillSize:CGSizeMake(kThumbnailSize, kThumbnailSize)];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, thumbnail ? kThumbnailRate : kImageRate);
    [imageData writeToFile:filePath atomically:YES];
    ifLog {
        NSFileManager* manager = [NSFileManager defaultManager];
        long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        NSLog(@"filesize:%lld kb",fileSize / 1024);
    }
    return filePath;
}

+ (void)deleteImageAssetFromLocal:(NSArray *)filePaths
{
    if (filePaths == nil || [filePaths count] == 0) {
        return;
    }
    NSFileManager *mgr = [NSFileManager defaultManager];
    for (NSString *path in filePaths) {
        if ([mgr fileExistsAtPath:path]) {
            [mgr removeItemAtPath:path error:NULL];
        }
    }
}

- (UIImage *)scaleAndClipToFillSize:(CGSize)destSize
{
    CGFloat showWidth = destSize.width;
    CGFloat showHeight = destSize.height;
    CGFloat scaleWidth = showWidth;
    CGFloat scaleHeight = showHeight;
    
    scaleWidth = ceilf(scaleHeight / self.size.height * self.size.width);
    if (scaleWidth < destSize.width) {
        scaleWidth = destSize.width;
        scaleHeight = ceilf(scaleWidth / self.size.width * self.size.height);
    }
    
    //scale
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scaleWidth, scaleHeight), NO, 0.0f);
    [self drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //clip
    CGFloat originX = ceilf((scaleWidth - showWidth) / 2);
    CGFloat originY = ceilf((scaleHeight - showHeight) / 2);
    
    
    CGRect cropRect = CGRectMake(ceilf(originX * scaledImage.scale),
                                 ceilf(originY * scaledImage.scale),
                                 ceilf(showWidth * scaledImage.scale),
                                 ceilf(showHeight * scaledImage.scale));
    return [scaledImage cropImageInRect:cropRect];
}

- (UIImage *)cropImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropImage;
}

- (UIImage *)scaleImageToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0f);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)gaussianBlurWithRadius:(CGFloat)radius
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
}

- (UIImage *)ellipseImageWithDefaultSetting
{
    return [self ellipseImage:self
                    withInset:0
                  borderWidth:0
                  borderColor:[UIColor clearColor]];
}

- (UIImage *)ellipseImage:(UIImage *)image
                withInset:(CGFloat)inset
              borderWidth:(CGFloat)width
              borderColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(inset,
                             inset,
                             image.size.width - inset * 2.0f,
                             image.size.height - inset * 2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [image drawInRect:rect];
    
    if (width > 0) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextSetLineWidth(context, width);
        CGContextAddEllipseInRect(context, CGRectMake(inset + width / 2,
                                                      inset +  width / 2,
                                                      image.size.width - width - inset * 2.0f,
                                                      image.size.height - width - inset * 2.0f));
        
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end












