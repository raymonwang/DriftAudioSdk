//
//  TestRootViewController.m
//  DriftAudioSdk
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#import "TestRootViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TestRootViewController ()

@property (nonatomic)BOOL isCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TestRootViewController
@synthesize isCamera=isCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onChoosePhotoBtn:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //混合类型 photo + movie
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onUploadPhotoBtn:(id)sender
{
    NSLog(@"onUploadPhotoBtn");
}

#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"info = %@",info);
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:@"public.movie"])			//被选中的是视频
    {
//        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
//        targetURL = url;		//视频的储存路径
//        
//        if (isCamera)
//        {
//            //保存视频到相册
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:nil];
//            [library release];
//        }
//        
//        //获取视频的某一帧作为预览
//        [self getPreViewImg:url];
    }
    else if([mediaType isEqualToString:@"public.image"])	//被选中的是图片
    {
        //获取照片实例
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        NSString *fileName = [[NSString alloc] init];
        
        if ([info objectForKey:UIImagePickerControllerReferenceURL]) {
            fileName = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
            //ReferenceURL的类型为NSURL 无法直接使用  必须用absoluteString 转换，照相机返回的没有UIImagePickerControllerReferenceURL，会报错
            fileName = [self getFileName:fileName];
        }
        else
        {
            fileName = [self timeStampAsString];
        }
        
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        
        [myDefault setValue:fileName forKey:@"fileName"];
        if (isCamera) //判定，避免重复保存
        {
            //保存到相册
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:[image CGImage]
                                      orientation:(ALAssetOrientation)[image imageOrientation]
                                  completionBlock:nil];
        }
        
        [self performSelector:@selector(saveImg:) withObject:image afterDelay:0.0];
    }
    else
    {
        NSLog(@"Error media type");
        return;
    }
    isCamera = FALSE;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancle it");
    isCamera = FALSE;
    [picker dismissModalViewControllerAnimated:YES];
}


-(NSString *)getFileName:(NSString *)fileName
{
    NSArray *temp = [fileName componentsSeparatedByString:@"&ext="];
    NSString *suffix = [temp lastObject];
    
    temp = [[temp objectAtIndex:0] componentsSeparatedByString:@"?id="];
    
    NSString *name = [temp lastObject];
    
    name = [name stringByAppendingFormat:@".%@",suffix];
    return name;
}

-(void)saveImg:(UIImage *) image
{
    NSLog(@"Review Image");
    _imageView.image = image;
}

-(NSString *)timeStampAsString
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE-MMM-d"];
    NSString *locationString = [df stringFromDate:nowDate];
    return [locationString stringByAppendingFormat:@".png"];
}



@end
