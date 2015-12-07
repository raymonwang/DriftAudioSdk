//
//  PhotoAlbumCell.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@import AssetsLibrary;

@interface PhotoAlbumCell : UITableViewCell

- (void)configureWithAlbumAssetGroup:(ALAssetsGroup *)assetGroup;

@end
