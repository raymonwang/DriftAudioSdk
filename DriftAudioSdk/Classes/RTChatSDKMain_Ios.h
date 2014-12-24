//
//  RTChatSDKMain.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-7-29.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef __RTChat__RTChatSDKMain__
#define __RTChat__RTChatSDKMain__

#include <iostream>
#include <map>
#include "RTChatCommonTypes.h"
#include "HttpProcess_Ios.h"

namespace rtchatsdk {
    
typedef std::function<void (SdkResponseCmd cmdType, SdkErrorCode error, const std::string& msgStr)> pMsgCallFunc;

class RTChatSDKMain {
public:
    RTChatSDKMain();
    virtual ~RTChatSDKMain();
    
    static RTChatSDKMain& sharedInstance();
    
    /*******************需要暴露给用户的接口开始**********************/
    
    //sdk初始化，只能调用一次(主线程)
    SdkErrorCode initSDK(const std::string& appid, const std::string& key, const char* uniqueid = NULL);
    
    //注册消息回调(主线程)
    void registerMsgCallback(const pMsgCallFunc& func);
    
    //获取SDK当前操作状态，用户发起操作前可以检测一下状态判断可否继续
    SdkOpState getSdkState();
    
    /// 开始录制麦克风数据(主线程)
    bool startRecordVoice(unsigned int labelid);
    
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
    bool getAvater(unsigned int uid, int type, const char* imageUrl);
    
    /*******************需要暴露给用户的接口结束**********************/
    
    /// 底层音量等级通知
    void voiceLevelNotify(float power);
    
    /// 底层播放结束通知
    void onVoicePlayOver();
    
    /// http请求回调函数
    void httpRequestCallBack(HttpDirection direction, const StCallBackInfo& info);
    
    /// 拍照上传回调接口
    void onImageUploadOver(bool issuccess, unsigned int uid, int type, const std::string& filename, const std::string& url);
    
    /// 图片取回接口
    void onImageDownloadOver(bool issuccess, unsigned int uid, int type, const std::string& fileName);
    
protected:
    
    //上传录制的语音数据
    void uploadVoiceData(const char *data, unsigned long datasize, unsigned int labelid, unsigned int duration);
    
    //录音超过最大时间回调
    void recordTimeExceed(int time);
    
    /// 构造JSON结构数据
    std::string constructJsonFromData(const StCallBackInfo& info);
    
private:
    std::string         _appid;
    std::string         _appkey;
    std::string         _uniqueid;
    std::string         _token;
    std::string         _gateWayIP;       //网关服务器IP
    uint32_t            _gateWayPort;     //网关服务器PORT
    
    SdkOpState          _sdkOpState;    //保存SDK操作状态
    
    pMsgCallFunc        _func;          //回调函数

    const char*             _downloadingfileurl; //临时存放下载中的文件名
    
    bool                _isrecording;       //录音标志
};
    
}

#endif /* defined(__RTChat__RTChatSDKMain__) */
