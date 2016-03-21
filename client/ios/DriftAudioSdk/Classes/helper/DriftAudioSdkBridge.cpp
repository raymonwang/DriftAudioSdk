//
//  DriftAudioSDKBridge.cpp
//  DriftAudioSdk
//
//  Created by wangxin on 16/2/22.
//  Copyright © 2016年 wang3140@hotmail.com. All rights reserved.
//

#include <stdio.h>
#include <string>
#include "RTChatSdk.h"
#include "DriftAudioSdkManager.h"

using namespace rtchatsdk;

static DriftAudioSdkManager s_driftAudioSdkManager;

extern "C"
{
    /// 注册回调函数
    void registerMsgCallBack(CallBackFunc func)
    {
        printf("inregisterMsgCallBack");
        s_driftAudioSdkManager.registerCallBack(func);
    }
    
    /// 设置自定义参数
    void setDriftAudioSdkParams(const char* uploadUrl, const char* xunfeiAppID)
    {
        RTChatSDKMain::sharedInstance().setParams(uploadUrl, xunfeiAppID);
    }
    
    /// 开始录制麦克风数据(主线程)
    bool startRecordVoice(unsigned int labelid, bool needTranslate = false)
    {
        printf("instartRecordVoice");
        return RTChatSDKMain::sharedInstance().startRecordVoice(labelid, needTranslate);
    }
    
    /// 停止录制麦克风数据(主线程)
    bool stopRecordVoice()
    {
        return RTChatSDKMain::sharedInstance().stopRecordVoice();
    }
    
    /// 开始播放录制数据(主线程)
    bool startPlayLocalVoice(unsigned int labelid, const char* voiceUrl)
    {
        return RTChatSDKMain::sharedInstance().startPlayLocalVoice(labelid, voiceUrl);
    }
    
    /// 停止当前播放录制数据()
    bool stopPlayLocalVoice()
    {
        return RTChatSDKMain::sharedInstance().stopPlayLocalVoice();
    }
    
    /// 取消当前录音
    bool cancelRecordedVoice()
    {
        return RTChatSDKMain::sharedInstance().cancelRecordedVoice();
    }
}



