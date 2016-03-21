//
//  DriftAudioSdkManager.hpp
//  DriftAudioSdk
//
//  Created by wangxin on 16/2/23.
//  Copyright © 2016年 wang3140@hotmail.com. All rights reserved.
//

#ifndef DriftAudioSdkManager_hpp
#define DriftAudioSdkManager_hpp

#include <stdio.h>
#include <string>
#include "RTChatSdk.h"

using namespace rtchatsdk;

extern "C"
{
    typedef void (*CallBackFunc)(int cmdType, int errorCode, char* msgstr);
}


class DriftAudioSdkManager {
public:
    DriftAudioSdkManager();
    virtual ~DriftAudioSdkManager();
    
    void registerCallBack(CallBackFunc func);
    
    void callBack(SdkResponseCmd cmdType, SdkErrorCode error, const std::string& msgStr);
    
private:
    CallBackFunc    _func;
};

#endif /* DriftAudioSdkManager_hpp */
