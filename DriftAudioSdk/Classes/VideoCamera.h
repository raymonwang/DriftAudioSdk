//
//  VideoCamera.h
//  VideoCamera2
//
//  Created by matao.ct@gmail.com on 12-6-4.
//  Copyright 2012 __福州微泰网络__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoCamera : UIViewController<UIImagePickerControllerDelegate> {
	UIImageView *imageView;
	
	NSURL *targetURL;
	BOOL isCamera;
}

-(void)startCamera;
-(void)getPreViewImg:(NSURL *)url;

-(NSString *)getFileName:(NSString *)fileName;
-(NSString *)timeStampAsString;

-(void)uploadImg:(UIImage*)image;
@end
