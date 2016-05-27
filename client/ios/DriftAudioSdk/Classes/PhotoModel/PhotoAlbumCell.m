//
//  PhotoAlbumCell.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoAlbumCell.h"

@interface PhotoAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iAlbumCoverImage;
@property (weak, nonatomic) IBOutlet UILabel *iAlbumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *iPhotoCountLabel;


@end

@implementation PhotoAlbumCell

- (void)configureWithAlbumAssetGroup:(ALAssetsGroup *)assetGroup
{
    CGImageRef cgimage = [assetGroup posterImage];
    UIImage *image = [UIImage imageWithCGImage:cgimage];
    NSString *name = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    _iAlbumCoverImage.image = image;
    NSUInteger count = [assetGroup numberOfAssets];
    _iAlbumNameLabel.text = name;
    _iPhotoCountLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)count];
}

@end
