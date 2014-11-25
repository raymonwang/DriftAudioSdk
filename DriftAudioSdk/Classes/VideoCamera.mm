//
//  VideoCamera.m
//  VideoCamera2
//
//  Created by wang3140@hotmail.com on 12-6-4.
//  Copyright 2012 __巨人网络__. All rights reserved.
//

#import "VideoCamera.h"
#import "CmdHandler.h"
#import "RTChatSDKMain.h"

@implementation VideoCamera

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    targetURL = [[NSURL alloc] init];
    isCamera = FALSE;
    self.allowsEditing = YES;
    self.delegate = self;

    //检查摄像头是否支持摄像机模式
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        //		camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        NSLog(@"Camera not exist");
        return;
    }
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissModalViewControllerAnimated:YES];
    
    NSLog(@"info = %@",info);
		
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if([mediaType isEqualToString:@"public.movie"])			//被选中的是视频
	{
		NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
		targetURL = url;		//视频的储存路径
		
		if (isCamera) 
		{
			//保存视频到相册
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:nil];
		}
		
		//获取视频的某一帧作为预览
        [self getPreViewImg:url];
	}
	else if([mediaType isEqualToString:@"public.image"])	//被选中的是图片
	{
        //获取照片实例
		UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
		
        NSString *fileName = [[NSString alloc] init];
        
        if ([info objectForKey:UIImagePickerControllerReferenceURL]) {
            fileName = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
            //ReferenceURL的类型为NSURL 无法直接使用  必须用absoluteString 转换，照相机返回的没有UIImagePickerControllerReferenceURL，会报错
            fileName = [self getFileName:fileName];
        }
        else
        {
            fileName = [VideoCamera timeStampAsString];
        }
		
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        
        [myDefault setValue:fileName forKey:@"fileName"];
		if (isCamera) //判定，避免重复保存
		{
			//保存到相册
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library writeImageToSavedPhotosAlbum:[editedImage CGImage]
									  orientation:(ALAssetOrientation)[editedImage imageOrientation]
								  completionBlock:nil];
		}
        
        NSData* data = UIImageJPEGRepresentation(editedImage, 0.3);
		
//		[self performSelector:@selector(saveImg:) withObject:data afterDelay:0.0];
        [VideoCamera saveImg:data filename:fileName];
        
        [self uploadImgData:data filename:fileName];
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


#pragma mark -
#pragma mark userFunc

-(void)getPreViewImg:(NSURL *)url
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    [self performSelector:@selector(saveImg:) withObject:img afterDelay:0.1];
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

+(void)saveImg:(NSData*)imageData filename:(NSString*)filename
{
	NSLog(@"save Image to disk");
    
    if (imageData) {
        [imageData writeToFile:filename atomically:YES];
    }
}

+(NSString *)timeStampAsString
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE-MMM-d"];
    NSString *locationString = [df stringFromDate:nowDate];
    return [locationString stringByAppendingFormat:@".png"];
}

#pragma mark -
#pragma mark sendFile
-(void)startCamera
{
//	UIImagePickerController *camera = [[UIImagePickerController alloc] init];
//	camera.delegate = self;
//	camera.allowsEditing = YES;
	isCamera = TRUE;
	
	//检查摄像头是否支持摄像机模式
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//	{		
//		camera.sourceType = UIImagePickerControllerSourceTypeCamera;
//		camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//	}
//	else 
//	{
//		NSLog(@"Camera not exist");
//		return;
//	}
	
    //仅对视频拍摄有效
//	switch (segmentVideoQuality.selectedSegmentIndex) {
//		case 0:
//			camera.videoQuality = UIImagePickerControllerQualityTypeHigh;
//			break;
//		case 1:
//			camera.videoQuality = UIImagePickerControllerQualityType640x480;
//			break;
//		case 2:
//			camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
//			break;
//		case 3:
//			camera.videoQuality = UIImagePickerControllerQualityTypeLow;
//			break;
//		default:
//			camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
//			break;
//	}
	
//	[self presentModalViewController:camera animated:YES];
}

#pragma -
#pragma ftpDelegate
// Successes
- (void) receivedListing: (NSDictionary *) listing;
{
    NSLog(@"listing");
}
- (void) downloadFinished
{
    NSLog(@"finish");
}
- (void) dataUploadFinished: (NSNumber *) bytes
{
    NSLog(@"data upload finish,%@",bytes);
    UIView *wait = [self.view viewWithTag:10086];
    [wait removeFromSuperview];
//    [wait release];
    
}
- (void) progressAtPercent: (NSNumber *) aPercent
{
    NSLog(@"percent");
}


// Failures
- (void) listingFailed
{
    
}
- (void) dataDownloadFailed: (NSString *) reason
{
    
}
- (void) dataUploadFailed: (NSString *) reason
{
    
}
- (void) credentialsMissing
{
    
}

-(void)uploadImgData:(NSData *)imageData filename:(NSString *)filename
{
    if (!imageData) {
        return;
    }
    
    [[CmdHandler sharedInstance]postFile:@"http://uploadchat.ztgame.com.cn:10000/wangpan.php" reqParams:[[NSDictionary alloc]init] data:imageData completBlock:^(id res) {
        if (res == nil) {
            NSLog(@"上传失败");
            rtchatsdk::RTChatSDKMain::sharedInstance().onImageUploadOver(false, 0, 0, "", "");
        }
        else {
            NSLog(@"%@", res);
            rtchatsdk::RTChatSDKMain::sharedInstance().onImageUploadOver(true, (unsigned int)_uid, (int)_itype, [filename UTF8String], [res UTF8String]);
        }
    }];
}

+(void)downloadImgData:(NSString *)url uid:(NSInteger)uid type:(NSInteger)type
{
    [[CmdHandler sharedInstance]getFile:url reqParams:[[NSDictionary alloc] init] completBlock:^(id res) {
        if (res == nil) {
            NSLog(@"下载失败");
        }
        else {
            NSLog(@"下载成功");
            NSString* fileName = [VideoCamera timeStampAsString];
            NSData* data = res;
            [self saveImg:data filename:fileName];
            rtchatsdk::RTChatSDKMain::sharedInstance().onImageDownloadOver(true, (unsigned int)uid, (int)type, [fileName UTF8String]);
        }
    }];
}

@end
