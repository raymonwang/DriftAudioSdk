//
//  VideoCamera.m
//  VideoCamera2
//
//  Created by matao.ct@gmail.com on 12-6-4.
//  Copyright 2012 __福州微泰网络__. All rights reserved.
//

#import "VideoCamera.h"
#import "CmdHandler.h"

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
- (void)viewDidLoad {
	targetURL = [[NSURL alloc] init];
	isCamera = FALSE;
    [super viewDidLoad];
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
            fileName = [self timeStampAsString];
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
		
		[self performSelector:@selector(saveImg:) withObject:editedImage afterDelay:0.0];
        
        [self uploadImg:editedImage];
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

-(void)saveImg:(UIImage *) image
{
	NSLog(@"Review Image");
	imageView.image = image;
}

-(NSString *)timeStampAsString
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
	UIImagePickerController *camera = [[UIImagePickerController alloc] init];
	camera.delegate = self;
	camera.allowsEditing = YES;
	isCamera = TRUE;
	
	//检查摄像头是否支持摄像机模式
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{		
		camera.sourceType = UIImagePickerControllerSourceTypeCamera;
//		camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else 
	{
		NSLog(@"Camera not exist");
		return;
	}
	
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
	
	[self presentModalViewController:camera animated:YES];
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

-(void)uploadImg:(UIImage *)image
{
    if (!image) {
        return;
    }
    NSData* data = UIImageJPEGRepresentation(image, 0.3);
    [[CmdHandler sharedInstance]postFile:@"http://uploadchat.ztgame.com.cn:10000/wangpan.php" reqParams:[[NSDictionary alloc]init] data:data completBlock:^(id res) {
        if (res == nil) {
            NSLog(@"上传失败");
        }
        else {
            NSLog(@"%@", res);
        }
    }];
}

@end
