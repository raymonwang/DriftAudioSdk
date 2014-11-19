//
//  SoundView.m
//  Sound
//
//  Created by wang3140@hotmail.com on 14-7-29.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#import "SoundObject.h"
#import "lame.h"
#import "RTChatSDKMain.h"

@interface SoundObject ()

@property(nonatomic, strong)NSTimer *timerForPitch;

@end

@implementation SoundObject

+(SoundObject *)sharedInstance
{
    static SoundObject *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (BOOL)transferPCMtoMP3
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:self.current_recordedFile_mp3 error:nil])
    {
        NSLog(@"删除老的录制文件");
    }
    
    @try {
        NSLog(@"启动mp3压缩");
        size_t read, write;
        
        FILE *pcm = fopen([self.current_recordedFile_caf cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([self.current_recordedFile_mp3 cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0);
        lame_set_num_channels(lame, 1);
        lame_set_brate(lame, 8);
        lame_set_mode(lame, MONO);
        lame_set_quality(lame, 7);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), (size_t)PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, (int)read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
}

-(instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.recordFileDic = [[NSMutableDictionary alloc] init];
    
    [self clearAllCachedFile];
    
    return self;
}

- (void)playPause
{
    //If the track is playing, pause and achange playButton text to "Play"
    if([_player isPlaying])
    {
        [_player pause];
    }
    //If the track is not player, play the track and change the play button to "Pause"
    else
    {
        [_player play];
    }
}

/// 开始录音
-(BOOL)beginRecord:(NSInteger)labelid
{
    NSLog(@"in beginRecord");
    if (_opstate != SoundOpReady) {
        NSLog(@"状态不对，返回");
        return NO;
    }
    
    _opstate = SoundOpRecording;
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    session.delegate = self;
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    /*
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                                        [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                         [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                                        nil];
     */
    //录音设置
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatAMR] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:16000.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    [settings setValue :[NSNumber numberWithInt:8] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    NSString* filename_caf = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"recordfile_%ld.caf", (long)labelid]];
    self.current_recordedFile_mp3 = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"recordfile_%ld.mp3", (long)labelid]];
    self.current_recordedFile_caf = filename_caf;
    [_recordFileDic setObject:self.current_recordedFile_mp3 forKey:[NSNumber numberWithInteger:labelid]];
    NSURL* url = [NSURL URLWithString:filename_caf];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
    if (_recorder) {
        NSLog(@"启动录音");
        [_recorder setMeteringEnabled:YES];
        self.current_record_labelid = labelid;
        [_recorder prepareToRecord];
        [_recorder record];
        
        self.timerForPitch = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    }
    
    return YES;
}

- (void)levelTimerCallback:(NSTimer *)timer
{
    [_recorder updateMeters];
    float power = pow (10, [_recorder averagePowerForChannel:0] / 20);
    if (power > 0.03) {
        
        power = power + .20;//pow (10, [audioRecorder averagePowerForChannel:0] / 20);//[audioRecorder peakPowerForChannel:0];
    }
    else {
        power = 0.0;
    }
    
    rtchatsdk::RTChatSDKMain::sharedInstance().voiceLevelNotify(power);
}

/// 停止录音
-(NSInteger)stopRecord:(NSString**)filename
{
    NSLog(@"in stopRecord");
    if (_opstate == SoundOpRecording) {
        [_recorder stop];
        
        [self transferPCMtoMP3];
        _recorder = nil;
        
        [_timerForPitch invalidate];
        _timerForPitch = nil;
        
        _opstate = SoundOpReady;
        NSLog(@"out stopRecord");
        
        *filename = self.current_recordedFile_caf;
        
        return self.current_record_labelid;
    }
    else {
        NSLog(@"不在录音状态，stopRecord直接返回");
        return -1;
    }
}

/// 开始播放内存中的音频
-(BOOL)beginPlay:(NSData *)data
{
    NSLog(@"in beginPlay");
    if (_opstate != SoundOpReady) {
        NSLog(@"当前操作状态错误%d", _opstate);
        return NO;
    }
    if (!data) {
        NSLog(@"传入的数据指针为空");
        return NO;
    }
    
    NSError *playerError;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
    if (_player) {
        [_player setDelegate:self];
        [_player setVolume:1.0];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        [_player play];
        NSLog(@"播放开始");
    }
    else {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    
    return YES;
}

/// 停止当前播放
-(void)stopPlay
{
    if (_player) {
        [_player  stop];
    }
    
    _opstate = SoundOpReady;
}

/// 是否已经下载过对应标签的文件
-(NSString*)haveLabelId:(NSInteger)labelid
{
    if (!_recordFileDic) {
        return nil;
    }
    
    return [_recordFileDic objectForKey:[NSNumber numberWithInteger:labelid]];
}

/// 根据标签ID获取录音时长
-(NSInteger)getRecordDuration:(NSInteger)labelid
{
    NSString* filepath = [_recordFileDic objectForKey:[NSNumber numberWithInteger:labelid]];
    if (filepath) {
        AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filepath] error:nil];
        if (player) {
            return [player duration];
        }
    }
    
    return 0;
}

/// 播放本地文件
-(void)beginPlayLocalFile:(NSString*)filename
{
    if (!filename) {
        return;
    }
    
    NSData* data = [NSData dataWithContentsOfFile:filename];
    [self beginPlay:data];
}

/// 保存内存录音数据为本地磁盘文件
-(BOOL)saveCacheToDiskFile:(NSInteger)labelid data:(NSData *)data
{
    NSString* filepath = [self haveLabelId:labelid];
    if (filepath) {
        return YES;
    }
    else {
        NSString* path = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"recordfile_%ld.mp3", (long)labelid]];
        NSLog(@"内存写入磁盘文件%@", path);
        return [data writeToFile:path atomically:YES];
    }
}

/// 清除缓冲的录音文件
-(void)clearAllCachedFile
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    for (id name in _recordFileDic) {
        if([fileManager removeItemAtPath:name error:nil])
        {
            NSLog(@"删除老的录制文件: %@", name);
        }
    }
    [_recordFileDic removeAllObjects];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for (NSString* path in array) {
        NSString* extenstion = [path pathExtension];
        if ([extenstion isEqualToString:@"mp3"] || [extenstion isEqualToString:@"caf"]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _opstate = SoundOpReady;
    NSLog(@"播放完成");
}

@end
