//
//  AppVoiceManager.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-30.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;

@protocol AppVoiceManagerDelegate <NSObject>

@optional
/*!
 *  @brief  录音时间过短
 */
- (void)voiceManagerDidRecordTimeInLeastDuration;
/*!
 *  @brief  录音结束
 *
 *  @return 音频文件地址
 */
- (void)voiceManagerDidRecordCompleted:(NSString *)filePath duration:(double)duration;

/*!
 *  @brief  录音时间超过最大值
 */
- (void)voiceManagerOverRecordMaxDuration:(NSString *)filePath duration:(double)duration;

/*!
 *  @brief  播放开始
 */
- (void)voiceDidStartPlaying;
/*!
 *  @brief  播放结束
 */
- (void)voiceDidFinishPlaying;

@end

@interface AppVoiceManager : NSObject

@property (nonatomic) id<AppVoiceManagerDelegate> delegate;

@property (nonatomic) NSTimeInterval maxDuration;

- (instancetype)initWithDelegate:(id<AppVoiceManagerDelegate>)delegate;

- (void)startRecord;
- (void)stopRecord;
- (void)cancleRecord;
- (void)playVoice:(NSString *)filePath;
- (BOOL)playing;
- (void)playVoice:(NSString *)filePath animationButton:(UIButton *)button;
- (void)playVoice:(NSString *)filePath animationImageView:(UIImageView *)imageView animationImages:(NSArray *)images;
- (void)stopPlay;
+ (float)recordTime:(NSString *)filePath;
- (void)addVolumeImageView:(UIImageView *)image;

/*!
 *  @brief  生成自己的录音文件本地路径
 *
 *  @return 文件绝对 带后缀名
 */
+ (NSString *)generateUserVoiceFilePath;

+ (NSString *)writeVoiceToFilePath:(NSString *)path;

- (void)asynLoadMiChatVoice:(NSString *)url completion:(void(^)(NSString *path))completion;

@end




















