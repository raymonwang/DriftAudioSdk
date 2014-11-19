//
//  DriftAudioSdkCocos2dxHelper.cpp
//  DriftAudioSdk
//
//  Created by raymon_wang on 14-11-10.
//  Copyright (c) 2014年 wang3140@hotmail.com. All rights reserved.
//

#include "DriftAudioSdkCocos2dxHelper.h"
#include "cocos2d.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

using namespace std::placeholders;
using namespace cocos2d;

static DriftAudioSdkCocos2dxHelper* s_DriftAudioSdkCocos2dxHelper = NULL;

DriftAudioSdkCocos2dxHelper::DriftAudioSdkCocos2dxHelper()
{
    
}

DriftAudioSdkCocos2dxHelper::~DriftAudioSdkCocos2dxHelper()
{
    
}

DriftAudioSdkCocos2dxHelper& DriftAudioSdkCocos2dxHelper::instance()
{
    if (!s_DriftAudioSdkCocos2dxHelper) {
        s_DriftAudioSdkCocos2dxHelper = new DriftAudioSdkCocos2dxHelper();
    }
    
    return *s_DriftAudioSdkCocos2dxHelper;
}

SdkErrorCode DriftAudioSdkCocos2dxHelper::init(const std::string& appid, const std::string& key, const char* uniqueid)
{
    initCallBack();
    
    return RTChatSDKMain::sharedInstance().initSDK(appid, key, uniqueid);
}

void DriftAudioSdkCocos2dxHelper::initCallBack()
{
    RTChatSDKMain::sharedInstance().registerMsgCallback(std::bind(&DriftAudioSdkCocos2dxHelper::RTChatCallBack, this, _1, _2, _3));
}

void DriftAudioSdkCocos2dxHelper::setLuaCallBack(cocos2d::LUA_FUNCTION  luavoicecallback)
{
	mVoiceOperatCB = luavoicecallback;
}

void DriftAudioSdkCocos2dxHelper::MsgCallBack(CmdMsgObj *msg)
{
     	if(mVoiceOperatCB)
		{
			LuaStack *pStack = LuaEngine::getInstance()->getLuaStack();
			int cmdtype = msg->_cmdType;
			int error = msg->_cmdResult;
			std::string cmddata = msg->_cmdData;

			pStack->pushInt(cmdtype);
			pStack->pushInt(error);
			pStack->pushString(cmddata.c_str(), cmddata.length());
			pStack->executeFunctionByHandler(mVoiceOperatCB, 3);
		}

		delete(msg);
}

void DriftAudioSdkCocos2dxHelper::RTChatCallBack(rtchatsdk::SdkResponseCmd cmdType, rtchatsdk::SdkErrorCode error, const std::string &msgStr)
{
    Scheduler *sched = Director::getInstance()->getScheduler();
    sched->performFunctionInCocosThread( [=](){
        if(mVoiceOperatCB)
        {
            LuaStack *pStack = LuaEngine::getInstance()->getLuaStack();
            pStack->pushInt((int)cmdType);
            pStack->pushInt((int)error);
            pStack->pushString(msgStr.c_str(), msgStr.length());
            pStack->executeFunctionByHandler(mVoiceOperatCB, 3);
        }
    });
        
}

    //录音上传
bool DriftAudioSdkCocos2dxHelper::startVoiceRecording(unsigned int labelid)
{
   return RTChatSDKMain::sharedInstance().startRecordVoice(labelid);
}

    //stop recording
bool DriftAudioSdkCocos2dxHelper::stopVoiceRecording()
{
	 return RTChatSDKMain::sharedInstance().stopRecordVoice();
}

    //play remote voice recording
bool DriftAudioSdkCocos2dxHelper::startPlayRemoteVoiceRecord(unsigned int labelid, const char* voiceUrl)
{
	return RTChatSDKMain::sharedInstance().startPlayLocalVoice(labelid,voiceUrl);
}

    //stop play remote voice recording
bool DriftAudioSdkCocos2dxHelper::stopPlayRemoteVoiceRecord()
{
	return RTChatSDKMain::sharedInstance().stopPlayLocalVoice();
}

/// 取消当前录音
bool DriftAudioSdkCocos2dxHelper::cancelRecordedVoice()
{
    return RTChatSDKMain::sharedInstance().cancelRecordedVoice();
}



