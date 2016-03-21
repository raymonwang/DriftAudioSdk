//
//  DriftAudioSdkManager.cpp
//  DriftAudioSdk
//
//  Created by wangxin on 16/2/23.
//  Copyright © 2016年 wang3140@hotmail.com. All rights reserved.
//

#include "DriftAudioSdkManager.h"

DriftAudioSdkManager::DriftAudioSdkManager()
{
    RTChatSDKMain::sharedInstance().initSDK("", "");
    
    RTChatSDKMain::sharedInstance().registerMsgCallback(std::bind(&DriftAudioSdkManager::callBack, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3));
}

DriftAudioSdkManager::~DriftAudioSdkManager()
{
    
}

void DriftAudioSdkManager::registerCallBack(CallBackFunc func)
{
    _func = func;
}

void DriftAudioSdkManager::callBack(SdkResponseCmd cmdType, SdkErrorCode error, const std::string& msgStr)
{
    if (_func) {
        _func(cmdType, error, (char*)msgStr.c_str());
    }
}