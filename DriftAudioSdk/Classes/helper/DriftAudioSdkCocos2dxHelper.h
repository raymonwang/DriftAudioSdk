//
//  DriftAudioSdkCocos2dxHelper.h
//  DriftAudioSdk
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#ifndef __DriftAudioSdk__DriftAudioSdkCocos2dxHelper__
#define __DriftAudioSdk__DriftAudioSdkCocos2dxHelper__

#include <stdio.h>
#include "RTChatSdk.h"
#include <string>
#include "cocos2d.h"
#include "CCLuaValue.h"

using namespace rtchatsdk;

class DriftAudioSdkCocos2dxHelper {

	struct CmdMsgObj
	{
		CmdMsgObj(int cmdType,int cmdResult,std::string cmdData):_cmdType(cmdType),_cmdResult(cmdResult),_cmdData(cmdData)
		{

		}
		int  _cmdType;
		int  _cmdResult;
		std::string _cmdData;
	};

public:
    DriftAudioSdkCocos2dxHelper();
    virtual ~DriftAudioSdkCocos2dxHelper();
    
    static DriftAudioSdkCocos2dxHelper& instance();
    
    //帮助类初始化
    SdkErrorCode init(const std::string& appid, const std::string& key, const char* uniqueid = NULL);

    //设置lua 回调
    void setLuaCallBack(cocos2d::LUA_FUNCTION  luavoicecallback);
    
    //初始化回调函数
    void initCallBack();
    
    //语音引擎回调函数
    void RTChatCallBack(SdkResponseCmd cmdType, SdkErrorCode error, const std::string& msgStr);

    //录音上传
    bool startVoiceRecording(unsigned int labelid);

    //stop recording
    bool stopVoiceRecording();

    //play remote voice recording
    bool startPlayRemoteVoiceRecord(unsigned int labelid, const char* voiceUrl);

    //stop play remote voice recording
    bool stopPlayRemoteVoiceRecord();
    
    /// 取消当前录音
    bool cancelRecordedVoice();

        //设置头像
    bool setAvater(unsigned int uid,int type);

    //获取头像
    bool getAvater(unsigned int uid,int type,const char* imageUrl);

public:
	cocos2d::LUA_FUNCTION mVoiceOperatCB;
	void MsgCallBack(CmdMsgObj *msg);

};

#endif /* defined(__DriftAudioSdk__DriftAudioSdkCocos2dxHelper__) */
