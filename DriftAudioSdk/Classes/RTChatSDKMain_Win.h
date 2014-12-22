//
//  RTChatSDKMain.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-7-29.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef __RTChat__RTChatSDKMain__
#define __RTChat__RTChatSDKMain__

#include <cocos2d.h>
#include <MMSystem.h>
#include <iostream>
#include <map>
#include <functional>
#include "RTChatCommonTypes.h"
#include "HttpProcess_Win.h"

namespace rtchatsdk {

	#define MAX_BUFFERS	3
    
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
    bool getAvater(unsigned int uid,int type,const char* imageUrl);
    
    /*******************需要暴露给用户的接口结束**********************/

	void StartRecording();

	void ProcessHeader(WAVEHDR * pHdr);
    
    void httpRequestCallBack(HttpDirection direction, const StCallBackInfo& info);
    
protected:
    
    //上传录制的语音数据
    void uploadVoiceData(const char *data, unsigned long datasize, unsigned int labelid);
    
    //录音超过最大时间回调
    void recordTimeExceed(int time);
    
    /// 构造JSON结构数据
	std::string constructJsonFromData(unsigned int labelid, const char* data, unsigned int size, unsigned int duration);

	///发送文件内容到服务器
	void sendFileToServer(const std::string& filename);

	/// 缓冲数据写入磁盘
	bool writeBufferToDisk(const StCallBackInfo& info);

private:
	void SetStatus(std::string lpszFormat, ...);
	void OpenDevice(std::string& wavfilename);
	void CloseDevice();
	void PrepareBuffers();
	void UnPrepareBuffers();
	int ChooseFirstRecordDevice();
	std::string StoreError(MMRESULT mRes,BOOL bDisplay,std::string lpszFormat, ...);

	std::string getMp3FileName(unsigned int labelid);
	std::string getFileName(unsigned int labelid);
    
private:
	HWAVEIN				m_hWaveIn;
	WAVEFORMATEX		m_stWFEX;
	WAVEHDR				m_stWHDR[MAX_BUFFERS];
	HMMIO				m_hOPFile;
	MMIOINFO			m_stmmIF;
	MMCKINFO			m_stckOut, m_stckOutRIFF;
	std::string			m_csErrorText;
	BOOL				m_bRun;
	HANDLE				m_hThread;

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
	unsigned int		_labelID;			//当前录音标签ID
	HttpProcess*		_httpProcess;
};
    
}

#endif /* defined(__RTChat__RTChatSDKMain__) */
