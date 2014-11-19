//
//  AppVoiceManager.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-30.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import AVFoundation;
#import "AppVoiceManager.h"
#import "AppHelper.h"
#import "MNCryptor.h"
#import "LogicHelper.h"

#define ifLog if(YES)

static NSString * const kFileSuffix = @"caf";
// 录音采样率
static const float kAVSampleRate = 8000.0f;
// 通道数
static const NSInteger kAVNumberOfChannel = 1;
// 解码率
static const NSInteger kAVEncoderBitRate = 12800;
// 线性采样位数  8、16、24、32
static const NSInteger kAVLinearPCMBitDepth = 8;
// 录音的质量
static const NSInteger kAVEncoderAudioQuality = AVAudioQualityMin;
// 录音时间 秒
static const NSTimeInterval kRecordLeastDuration = 1.0;
static const NSTimeInterval kRecordMaxDuration = 60.0;

@interface AppVoiceManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) NSURL *tempUrl;
@property (nonatomic) NSString *storePath;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *detectionVoiceTimer;
@property (nonatomic) NSTimer *voiceTimer;
@property (nonatomic) NSUInteger recordSeconds;
@property (nonatomic) AVAudioPlayer *player;
@property (nonatomic) NSDictionary *setting;
@property (nonatomic) NSArray *playImage;
@property (nonatomic) UIButton *animationButton;
@property (nonatomic) UIImageView *animationImageView;
@property (nonatomic) UIImageView *volumeImage;
@property (nonatomic) NSArray *volumeImages;

@end


@implementation AppVoiceManager

- (instancetype)initWithDelegate:(id<AppVoiceManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _maxDuration = kRecordMaxDuration;
        _delegate = delegate;
        [self setupAudio];
    }
    return self;
}

- (void)setupAudio
{
    NSMutableDictionary *setting = [NSMutableDictionary new];
    setting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    setting[AVSampleRateKey] = @(kAVSampleRate);
    setting[AVNumberOfChannelsKey] = @(kAVNumberOfChannel);
    setting[AVEncoderAudioQualityKey] = @(kAVEncoderAudioQuality);
    setting[AVLinearPCMBitDepthKey] = @(kAVLinearPCMBitDepth);
    setting[AVEncoderBitRateKey] = @(kAVEncoderBitRate);
    
    _setting = setting;
}

#pragma mark 录音
- (void)startRecord
{
    [self recordModel];
    NSString *path = [AppVoiceManager generateUserVoiceFilePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSError *error = NULL;
        [manager removeItemAtPath:path error:&error];
    }
    _storePath = path;
    _tempUrl = [NSURL fileURLWithPath:_storePath];
    NSError *error;
    _recorder = [[AVAudioRecorder alloc]initWithURL:_tempUrl settings:_setting error:&error];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    if ([_recorder prepareToRecord]) {
        [_recorder record];
        _recordSeconds = 0;
        if (_timer != nil) {
            [_timer invalidate];
            _timer = nil;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        if (_volumeImage != nil) {
            _volumeImage.hidden = NO;
            _detectionVoiceTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
        }
    }
}

- (void)stopRecord
{
    double time = _recorder.currentTime;
    if (time == 0) {
        return;
    }
    if (time > kRecordLeastDuration) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(voiceManagerDidRecordCompleted:duration:)]) {
            [_delegate voiceManagerDidRecordCompleted:_storePath duration:time];
        }
    } else {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(voiceManagerDidRecordTimeInLeastDuration)]) {
            [_delegate voiceManagerDidRecordTimeInLeastDuration];
        }
    }
    [_recorder deleteRecording];
    [_recorder stop];
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_detectionVoiceTimer != nil) {
        [_detectionVoiceTimer invalidate];
        _detectionVoiceTimer = nil;
    }
    if (_volumeImage != nil) {
        _volumeImage.hidden = YES;
    }
}

- (void)cancleRecord
{
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_detectionVoiceTimer != nil) {
        [_detectionVoiceTimer invalidate];
        _detectionVoiceTimer = nil;
    }
    if (_volumeImage != nil) {
        _volumeImage.hidden = YES;
    }
    if ([_recorder isRecording]) {
        [_recorder deleteRecording];
        [_recorder stop];
    }
    
}

// 记录录音时间
- (void)countdown
{
    _recordSeconds ++;
    NSLog(@"<VoiceManager>record time:%ld",(unsigned long)_recordSeconds);
    if (_recordSeconds > _maxDuration) {
        [_recorder stop];
        if (_delegate != nil && [_delegate respondsToSelector:@selector(voiceManagerOverRecordMaxDuration:duration:)]) {
            [_delegate voiceManagerOverRecordMaxDuration:_storePath duration:_maxDuration];
        }
        if (_timer != nil) {
            [_timer invalidate];
            _timer = nil;
        }
        if (_detectionVoiceTimer != nil) {
            [_detectionVoiceTimer invalidate];
            _detectionVoiceTimer = nil;
        }
        if (_volumeImage != nil) {
            _volumeImage.hidden = YES;
        }
    }
}

// 录音动画
- (void)detectionVoice
{
    [_recorder updateMeters];//刷新音量数据
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    //最大50  0
    //图片 小-》大
    if (0 < lowPassResults <= 0.06) {
        [_volumeImage setImage:_volumeImages[0]];
    } else if (0.06 < lowPassResults <= 0.13) {
        [_volumeImage setImage:_volumeImages[1]];
    } else if (0.13 < lowPassResults <= 0.20) {
        [_volumeImage setImage:_volumeImages[2]];
    } else if (0.20 < lowPassResults <= 0.27) {
        [_volumeImage setImage:_volumeImages[3]];
    } else if (0.27 < lowPassResults <= 0.34) {
        [_volumeImage setImage:_volumeImages[4]];
    } else if (0.34 < lowPassResults <= 0.41) {
        [_volumeImage setImage:_volumeImages[5]];
    } else if (0.41 < lowPassResults <= 0.48) {
        [_volumeImage setImage:_volumeImages[6]];
    } else if (0.48 < lowPassResults <= 0.55) {
        [_volumeImage setImage:_volumeImages[7]];
    } else if (0.55 < lowPassResults <= 0.62) {
        [_volumeImage setImage:_volumeImages[8]];
    } else if (0.62 < lowPassResults <= 0.69) {
        [_volumeImage setImage:_volumeImages[9]];
    } else if (0.69 < lowPassResults <= 0.76) {
        [_volumeImage setImage:_volumeImages[10]];
    } else if (0.76 < lowPassResults <= 0.83) {
        [_volumeImage setImage:_volumeImages[11]];
    } else if (0.83 < lowPassResults <= 0.9) {
        [_volumeImage setImage:_volumeImages[12]];
    } else {
        [_volumeImage setImage:_volumeImages[13]];
    }
}

#pragma mark 播放
- (void)playVoice:(NSString *)filePath
{
    if (_player.playing) {
        [_player stop];
        return;
    }
    [self speakerModel];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.delegate = self;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(voiceDidStartPlaying)]) {
        [_delegate voiceDidStartPlaying];
    }
    [_player play];
}

- (void)playVoice:(NSString *)filePath animationButton:(UIButton *)button
{
    [self playVoice:filePath];
    _animationButton = button;
    _voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(voicePlaying) userInfo:nil repeats:YES];
    _playImage = @[[UIImage imageNamed:@"ic_voice_play_1"], [UIImage imageNamed:@"ic_voice_play_2"], [UIImage imageNamed:@"ic_voice_play_3"]];
}

- (void)playVoice:(NSString *)filePath animationImageView:(UIImageView *)imageView animationImages:(NSArray *)images
{
    [self playVoice:filePath];
    _animationImageView = imageView;
    _voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(voicePlaying) userInfo:nil repeats:YES];
    _playImage = images;
}

- (BOOL)playing
{
    if (_player == nil) {
        return NO;
    }
    if (!_player.playing) {
        return NO;
    }
    return YES;
}

- (void)stopPlay
{
    if (_player != nil && _player.playing) {
        [_player stop];
    }
    if (_voiceTimer != nil) {
        [_voiceTimer invalidate];
        _voiceTimer = nil;
    }
    if (_animationButton != nil) {
        [_animationButton setImage:_playImage[2] forState:UIControlStateNormal];
    }
    if (_animationImageView != nil) {
        [_animationImageView setImage:_playImage[2]];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_animationButton != nil) {
        [_animationButton setImage:_playImage[2] forState:UIControlStateNormal];
    }
    if (_animationImageView != nil) {
        [_animationImageView setImage:_playImage[2]];
    }
    if (_voiceTimer != nil) {
        [_voiceTimer invalidate];
        _voiceTimer = nil;
    }
    if (_delegate != nil && [_delegate respondsToSelector:@selector(voiceDidFinishPlaying)]) {
        [_delegate voiceDidFinishPlaying];
    }
}

- (void)voicePlaying
{
    if (_animationButton != nil) {
        NSUInteger random = arc4random() % 3;
        [_animationButton setImage:_playImage[random] forState:UIControlStateNormal];
    }
    if (_animationImageView != nil) {
        NSUInteger random = arc4random() % 3;
        [_animationImageView setImage:_playImage[random]];
    }
}

- (void)addVolumeImageView:(UIImageView *)image
{
    _volumeImage = image;
    _volumeImages = @[[UIImage imageNamed:@"record_animate_01.png"],
                      [UIImage imageNamed:@"record_animate_02.png"],
                      [UIImage imageNamed:@"record_animate_03.png"],
                      [UIImage imageNamed:@"record_animate_04.png"],
                      [UIImage imageNamed:@"record_animate_05.png"],
                      [UIImage imageNamed:@"record_animate_06.png"],
                      [UIImage imageNamed:@"record_animate_07.png"],
                      [UIImage imageNamed:@"record_animate_08.png"],
                      [UIImage imageNamed:@"record_animate_09.png"],
                      [UIImage imageNamed:@"record_animate_10.png"],
                      [UIImage imageNamed:@"record_animate_11.png"],
                      [UIImage imageNamed:@"record_animate_12.png"],
                      [UIImage imageNamed:@"record_animate_13.png"],
                      [UIImage imageNamed:@"record_animate_14.png"]];
}

// =================
+ (NSString *)formatString:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"~" withString:@"\n"];
}

- (void)speakerModel
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    if(session == nil) {
        NSLog(@"Error creating session: %@", [session description]);
        return;
    } else {
        [session setActive:YES error:nil];
    }
}

- (void)recordModel
{
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil) {
        NSLog(@"Error creating session: %@", [sessionError description]);
        return;
    } else {
        [session setActive:YES error:nil];
    }
}

+ (float)recordTime:(NSString *)filePath
{
    AVURLAsset *audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:filePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

+ (NSString *)generateUserVoiceFilePath
{
    NSString *fileName = [LogicHelper randomFileName];
    NSString *voicePath = [[AppHelper sandboxPathVoiceSend] stringByAppendingPathComponent:fileName];
    NSString *result = [NSString stringWithFormat:@"%@.%@",voicePath,kFileSuffix];
    return result;
}

+ (NSString *)writeVoiceToFilePath:(NSString *)path
{
    NSString *voicePath = nil;
    if ([AppHelper isBlankOrNil:path]) {
        return voicePath;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *fileName = [LogicHelper randomFileName];
        NSString *newPath = [[AppHelper sandboxPathVoiceSend] stringByAppendingPathComponent:fileName];
        voicePath = [NSString stringWithFormat:@"%@.%@",newPath,kFileSuffix];
        ifLog {
            long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:voicePath error:NULL] fileSize];
            NSLog(@"voiceFileSize:%lld kb",fileSize / 1024);
        }
        [data writeToFile:voicePath atomically:YES];
    }
    return voicePath;
}

- (void)asynLoadMiChatVoice:(NSString *)url completion:(void(^)(NSString *path))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([AppHelper isBlankOrNil:url]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(url);
            });
            return;
        }
        
        if([url rangeOfString:[AppHelper sandboxPathVoiceSend]].location != NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(url);
            });
            return;
        }
        NSString *fileName = [MNCryptor md5:url];
        NSString *filePath = [[AppHelper sandboxPathVoiceRecv] stringByAppendingPathComponent:fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(filePath);
            });
            return;
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        NSURLSessionTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(location == nil || error != nil || [httpResponse statusCode] != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
                return;
            }
            NSData *data = [NSData dataWithContentsOfURL:location];
            [data writeToFile:filePath atomically:YES];
            ifLog {
                long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileSize];
                NSLog(@"voiceFileSize:%lld kb",fileSize / 1024);
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(filePath);
            });
        }];
        [task resume];
    });
}


@end

