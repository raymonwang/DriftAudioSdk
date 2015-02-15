//
//  SoundRecognize.m
//  DriftAudioSdk
//
//  Created by raymon_wang on 15-1-8.
//  Copyright (c) 2015年 wang3140@hotmail.com. All rights reserved.
//

#import "SoundRecognize.h"
#import "ISRDataHelper.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUnderstander.h"

#import "RTChatSDKMain_Ios.h"

@interface SoundRecognize () {
    NSString*   content;
}

//@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;

//语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;

@end

@implementation SoundRecognize

-(instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    self.iFlySpeechUnderstander.delegate = self;

    //设置为麦克风输入语音
    [_iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    [_iFlySpeechUnderstander setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    // 创建识别对象
//    self.iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
//    
//    self.iFlySpeechRecognizer.delegate = self;
//    
//    [self.iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //设置采样率
//    [self.iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置录音保存文件
    //    [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    //设置为非语义模式
//    [self.iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
    
    //设置返回结果的数据格式，可设置为json，xml，plain，默认为json。
//    [self.iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
//    [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    
    return self;
}

//- (void)SoundProcessThread:(NSData*)data
//{
//    int count = 10;
//    unsigned long audioLen = data.length/count;
//    
//    //分割音频
//    for (int i = 0 ; i < count-1; i++) {
//        char * part1Bytes = malloc(audioLen);
//        NSRange range = NSMakeRange(audioLen*i, audioLen);
//        [data getBytes:part1Bytes range:range];
//        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
//        //写入音频，让SDK识别
//        int ret = [self.iFlySpeechRecognizer writeAudio:part1];
//        free(part1Bytes);
//        
//        //检测数据发送是否正常
//        if(!ret)
//        {
//            NSLog(@"sendAudioThread[ERROR]");
//            
//            [self.iFlySpeechRecognizer stopListening];
//            
//            return;
//        }
//    }
//    
//    //处理最后一部分
//    unsigned long writtenLen = audioLen * (count-1);
//    char * part3Bytes = malloc(data.length-writtenLen);
//    NSRange range = NSMakeRange(writtenLen, data.length-writtenLen);
//    [data getBytes:part3Bytes range:range];
//    NSData * part3 = [NSData dataWithBytes:part3Bytes length:data.length-writtenLen];
//    
//    [self.iFlySpeechRecognizer writeAudio:part3];
//    
//    free(part3Bytes);
//    
//    //音频数据写入完成，进入等待状态
//    [self.iFlySpeechRecognizer stopListening];
//    
//    NSLog(@"sendAudioThread[OUT]");
//}
//
//-(void)parseSoundPcmFile:(NSString *)fullfilename
//{
//    if(!fullfilename || [fullfilename length] == 0)
//    {
//        return;
//    }
//    
//    NSFileManager *fm = [NSFileManager defaultManager];
//    if (![fm fileExistsAtPath:fullfilename]) {
//        NSLog(@"文件不存在");
//        return;
//    }
//    
//    //从文件中读取音频
//    NSData *data = [NSData dataWithContentsOfFile:fullfilename];
//    
//    [self parseSoundData:data];
//}
//
//-(void)parseSoundData:(NSData *)data
//{
//    if (!data) {
//        return;
//    }
//    
//    [self.iFlySpeechRecognizer startListening];
//    
//    [NSThread detachNewThreadSelector:@selector(SoundProcessThread:) toTarget:self withObject:data];
//}

-(void)startListenMic
{
    content = [[NSString alloc] init];
    [_iFlySpeechUnderstander startListening];
}

-(void)stopListenMic
{
    [_iFlySpeechUnderstander stopListening];
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
    NSLog(@"%@",text);
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果：%@",resultString);
    
    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    
    content = [content stringByAppendingString:resultFromJson];
    
    NSLog(@"resultFromJson = %@",resultFromJson);
    
    if (isLast) {
        rtchatsdk::RTChatSDKMain::sharedInstance().onReceiveVoiceTextResult([content UTF8String]);
    }
}


@end






