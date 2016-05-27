//
//  PhotoAlbumsController.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoAlbumsController.h"
#import "PhotoAlbumCell.h"
#import "AppHelper.h"
#import "DataManager.h"

@interface PhotoAlbumsController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iCancleButton;
@property (nonatomic) ALAssetsLibrary*  library;

@property (nonatomic) NSMutableDictionary *albumsDic;   //相册 K:相册名 V:照片array
@property (nonatomic) NSMutableArray*   photos; //所有照片
@property (nonatomic) NSMutableArray*   albums; //相册

@end

@implementation PhotoAlbumsController

-(void)loadView
{
    [super loadView];
    
    self.library = [[ALAssetsLibrary alloc] init];
    self.photos = [[NSMutableArray alloc] init];
    self.albums = [[NSMutableArray alloc] init];
    self.albumsDic = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadPhotos];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)loadPhotos
{
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            ALAssetsFilter *filter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:filter];
            
            NSMutableArray *albumPhotos = [NSMutableArray new];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [_photos addObject:result];
                    [albumPhotos addObject:result];
                }
            }];
            [_albums addObject:group];
            _albumsDic[[group valueForProperty:ALAssetsGroupPropertyName]] = albumPhotos;
        } else {
            [self.tableView reloadData];
//            [_userInterface showPhotoAlbums:_albums];
//            //展示所有照片
//            [_router pushPhotoInPhoneController:@{@"photos" : _photos,
//                                                  @"maxPhotoCount" : @(1)}];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_albums count];
}

- (IBAction)didCancleButtonClick:(id)sender
{
//    [_handler cancleChoose];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"PhotoAlbumCell";
    PhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    ALAssetsGroup *group = _albums[indexPath.row];
    [cell configureWithAlbumAssetGroup:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ALAssetsGroup *group = _albums[indexPath.row];
    
    NSMutableArray* selectphotos = [_albumsDic objectForKey:[group valueForProperty:ALAssetsGroupPropertyName]];
    [[DataManager sharedInstance] setPhotos:selectphotos];
    
    UIViewController* newvc = [AppHelper getControllerFromStoryboard:@"MainStoryboard" storyControllName:@"PhotoInPhoneController"];
    [self.navigationController pushViewController:newvc animated:YES];
//    [_handler showPhotoInAlbums:[group valueForProperty:ALAssetsGroupPropertyName]];
}

@end
