//
//  PhotoInPhoneCell.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@import AssetsLibrary;

@interface PhotoInPhoneCell : UICollectionViewCell

- (void)configureWithPhotoAsset:(ALAsset *)asset;
- (void)doSelect:(BOOL)seleceted;

@end
