//
//  PhotoInPhoneCell.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoInPhoneCell.h"

@interface PhotoInPhoneCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iPhotoPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView *iSelectedImage;


@end

@implementation PhotoInPhoneCell

- (void)configureWithPhotoAsset:(ALAsset *)asset
{
    CGImageRef ref = [asset thumbnail];
    UIImage *image = [[UIImage alloc] initWithCGImage:ref];
    _iPhotoPreviewImage.image = image;
    _iSelectedImage.hidden = YES;
}

- (void)doSelect:(BOOL)seleceted
{
    _iSelectedImage.hidden = !seleceted;
    _iPhotoPreviewImage.alpha = seleceted ? .3f : 1.0f;
}

@end
