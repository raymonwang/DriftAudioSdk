//
//  RTChatSdk.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-7-29.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef RTChat_RTChatSdk_h
#define RTChat_RTChatSdk_h

#include "RTChatCommonTypes.h"
#include <functional>

namespace rtchatsdk {

typedef std::function<void (SdkResponseCmd cmdType, SdkErrorCode error, const std::string& msgStr)> pMsgCallFunc;

class RTChatSDKMain {
public:
    static RTChatSDKMain& sharedInstance();
    
    //sdk初始化，只能调用一次(主线程)
    SdkErrorCode initSDK(const std::string& appid, const std::string& key, const char* uniqueid = NULL);
    
    //注册消息回调(主线程)
    void registerMsgCallback(const pMsgCallFunc& func);
    
    /// 设置自定义参数
    void setParams(const std::string& voiceUploadUrl, const char* xunfeiAppID);
    
    //获取SDK当前操作状态，用户发起操作前可以检测一下状态判断可否继续
    SdkOpState getSdkState();
    
    /// 开始录制麦克风数据(主线程)
    bool startRecordVoice(unsigned int labelid, bool needTranslate = false);
    
    /// 停止录制麦克风数据(主线程)
    bool stopRecordVoice();
    
    /// 开始播放录制数据(主线程)
    bool startPlayLocalVoice(unsigned int labelid, const char* voiceUrl);
    
    /// 停止当前播放录制数据()
    bool stopPlayLocalVoice();
    
    /// 取消当前录音
    bool cancelRecordedVoice();
    
    /// 设置头像
    bool setAvater(unsigned int uid, int type);
    
    /// 获取头像
    bool getAvater(unsigned int uid,int type,const char* imageUrl);
    
    ///开始摄像
    bool startRecordVideo(unsigned int labelid, int type);
    
    ///播放视频
    bool playVideo(unsigned int labelid, const char* videoUrl);
    
    ///开始语音识别
    bool startVoiceToText();
    
    ///停止语音识别
    bool stopVoiceToText();
    
    /// 获取当前地理位置信息
    bool startGetCurrentCoordinate();
};
    
}

#endif
