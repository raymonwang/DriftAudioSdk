//
//  SoundRecognize.h
//  DriftAudioSdk
//
//  Created by raymon_wang on 15-1-8.
//  Copyright (c) 2015年 wang3140@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"

@interface SoundRecognize : NSObject <IFlySpeechRecognizerDelegate>

//-(void)parseSoundData:(NSData*)data;
//
//-(void)parseSoundPcmFile:(NSString*)fullfilename;

-(void)startListenMic;

-(void)stopListenMic;

@end
