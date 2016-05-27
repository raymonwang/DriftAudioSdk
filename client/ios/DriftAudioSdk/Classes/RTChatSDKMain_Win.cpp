//
//  RTChatSDKMain.cpp
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-7-29.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

//#include "stdafx.h"
#include "RTChatSDKMain_Win.h"
#include <sys/types.h>
#include <vector>
#include "DriftAudioSdk\VoiceConvert\amrwapper\amrFileCodec_win.h"

using namespace std::placeholders;

namespace rtchatsdk {

	static  RTChatSDKMain* s_RTChatSDKMain = NULL;

#define MaxBufferSize   1024

#define SendProtoMsg(MSG, TypeID)   \
	char buff[MaxBufferSize] = {0}; \
	MSG.SerializeToArray(buff, msg.ByteSize()); \
	BUFFER_CMD(stBaseCmd, basecmd, MaxBufferSize);  \
	basecmd->cmdid = TypeID;    \
	basecmd->cmdlen = MSG.ByteSize();   \
	memcpy(basecmd->data, buff, msg.ByteSize());    \
	if (_netDataManager) {  \
	_netDataManager->sendClientMsg((const unsigned char*)basecmd, basecmd->getSize());  \
	}   \


	DWORD WINAPI ThFunc(LPVOID pDt)
	{
		RTChatSDKMain *pOb = (RTChatSDKMain*)pDt;
		pOb->StartRecording();
		return 0;
	}

	void CALLBACK waveInProc(HWAVEIN hwi,UINT uMsg,DWORD dwInstance,DWORD dwParam1,DWORD dwParam2)
	{
		WAVEHDR *pHdr=NULL;
		switch(uMsg)
		{
		case WIM_CLOSE:
			break;

		case WIM_DATA:
			{
				RTChatSDKMain *pDlg=(RTChatSDKMain*)dwInstance;
				pDlg->ProcessHeader((WAVEHDR *)dwParam1);
			}
			break;

		case WIM_OPEN:
			break;

		default:
			break;
		}
	}

	bool transferPcmToAmr(const std::string& filename)
	{
		std::string wavfilename = filename + ".wav";
		std::string amrfilename = filename + ".amr";
		EncodeWAVEFileToAMRFile(wavfilename.c_str(), amrfilename.c_str(), 2, 16);
		return true;
	}

	bool transferAmrToPcm(const std::string& filename)
	{
		std::string wavfilename = filename + ".wav";
		std::string amrfilename = filename + ".amr";
		DecodeAMRFileToWAVEFile(amrfilename.c_str(), wavfilename.c_str());
		return true;
	}

	const char* avar(const char* pszFmt, ...)
	{
		static char buffer[1024];
		va_list ap;
		va_start(ap, pszFmt);
		vsnprintf(buffer, 1024, pszFmt, ap);
		va_end(ap);
		return buffer;
	}

	RTChatSDKMain::RTChatSDKMain() :
		_sdkOpState(SdkControlUnConnected),
		_appid(""),
		_appkey(""),
		_token(""),
		_uniqueid(""),
		_gateWayIP(""),
		_gateWayPort(0),
		//_func(NULL),
		_isrecording(false),
		_httpProcess(NULL)
	{
		m_bRun=FALSE;
		m_hThread=NULL;
		m_hWaveIn=NULL;
		ZeroMemory(&m_stWFEX,sizeof(WAVEFORMATEX));
		ZeroMemory(m_stWHDR,MAX_BUFFERS*sizeof(WAVEHDR));
		_httpProcess = HttpProcess::create();
	}

	RTChatSDKMain::~RTChatSDKMain()
	{

	}

	RTChatSDKMain& RTChatSDKMain::sharedInstance()
	{
		if (!s_RTChatSDKMain) {
			s_RTChatSDKMain = new RTChatSDKMain();
		}

		return *s_RTChatSDKMain;
	}

	SdkErrorCode RTChatSDKMain::initSDK(const std::string &appid, const std::string &key, const char* uniqueid)
	{
		_appid = appid;
		_appkey = key;

		if (uniqueid != NULL) {
			_uniqueid = uniqueid;
		}

		//if (_httpProcess)
		//{
		//	_httpProcess->registerCallback(std::bind(&RTChatSDKMain::httpRequestCallBack, this, std::placeholders::_1, std::placeholders::_2));
		//}

		return OPERATION_OK;
	}

	//注册消息回调
	void RTChatSDKMain::registerMsgCallback(const pMsgCallFunc& func)
	{
	    _func = func;
	}

	/// 开始录制麦克风数据
	bool RTChatSDKMain::startRecordVoice(unsigned int labelid)
	{
		CCLOG("in RTChatSDKMain::startRecordVoice, threadid = %d", GetCurrentThreadId());
		m_bRun = TRUE;
		_labelID = labelid;
		m_hThread = CreateThread(NULL,0,ThFunc,this,0,NULL);

		return true;
	}

	bool RTChatSDKMain::stopRecordVoice()
	{
		CCLOG("in RTChatSDKMain::stopRecordVoice");
		m_bRun = FALSE;
		while(m_hThread)
		{
			SleepEx(100,FALSE);
		}

		return true;
	}

	/// 开始播放录制数据
	bool RTChatSDKMain::startPlayLocalVoice(unsigned int labelid, const char *voiceUrl)
	{
		static unsigned int id = 1000;
		_httpProcess->getFile(StRequestUrlInfo(id++, voiceUrl));
		//std::string filename = getMp3FileName(labelid);
		//if (FileUtils::getInstance()->isFileExist(filename))
		//{
		//	CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic(filename.c_str());
		//}
		//else
		//{
		//	_httpProcess->getFile(StRequestUrlInfo(labelid, voiceUrl));
		//}
		//if (NSString* filename = [[SoundObject sharedInstance] haveLabelId:labelid]) {
		//    [[SoundObject sharedInstance] beginPlayLocalFile:filename];
		//    _func(enRequestPlay, OPERATION_OK, "");
		//}
		//else {
		//    StRequestUrlInfo info(labelid, voiceUrl);
		//    HttpProcess::instance().requestContent(info);
		//}

		return true;
	}


	/// 停止当前播放录制数据()
	bool RTChatSDKMain::stopPlayLocalVoice()
	{
		CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();
		return true;
	}

	/// 取消当前录音
    bool RTChatSDKMain::cancelRecordedVoice()
	{
		return true;
	}

	/// 设置头像
    bool RTChatSDKMain::setAvater(unsigned int uid, int type)
	{
		return true;
	}

	/// 获取头像
    bool RTChatSDKMain::getAvater(unsigned int uid,int type,const char* imageUrl)
	{
		return true;
	}

	void RTChatSDKMain::StartRecording()
	{
		CCLOG("in RTChatSDKMain::StartRecording");
		MMRESULT mRes;

		std::string filename;
		try
		{
			OpenDevice(filename);
			PrepareBuffers();
			mRes = waveInStart(m_hWaveIn);
			if(mRes!=0)
			{
				StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
				throw m_csErrorText;
			}
			while(m_bRun)
			{
				SleepEx(100,FALSE);
			}
		}
		catch(PCHAR pErrorMsg)
		{
			//AfxMessageBox(pErrorMsg);
		}
		CloseDevice();
		CloseHandle(m_hThread);
		m_hThread=NULL;
		SetStatus("Recording stopped...");

		//transferPcmToMp3(filename);
		transferPcmToAmr(filename);

		sendFileToServer(filename);
	}

	void RTChatSDKMain::ProcessHeader(WAVEHDR * pHdr)
	{
		MMRESULT mRes=0;

		//TRACE("%d",pHdr->dwUser);
		if(WHDR_DONE==(WHDR_DONE &pHdr->dwFlags))
		{
			mmioWrite(m_hOPFile,pHdr->lpData,pHdr->dwBytesRecorded);
			mRes = waveInAddBuffer(m_hWaveIn,pHdr,sizeof(WAVEHDR));
			if(mRes != 0)
				StoreError(mRes,TRUE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
		}
	}


	//上传录制的语音数据
	void RTChatSDKMain::uploadVoiceData(const char *data, unsigned long datasize, unsigned int labelid)
	{
		std::map<const char*, const char*> param;
		//HttpRequest* request = new HttpRequest();
		//request->setRequestType(HttpRequest::Type::POST);
		//request->setUrl("http://uploadchat.ztgame.com.cn:10000/wangpan.php");  
		//request->setTag("FirstNet"); 
		//HttpProcess::instance().postContent(VoiceUpLoadUrlHead, StCallBackInfo(data, datasize, labelid), param);
	}

	//录音超过最大时间回调
	void RTChatSDKMain::recordTimeExceed(int time)
	{
		stopRecordVoice();
	}

	/// 构造JSON结构数据
	std::string RTChatSDKMain::constructJsonFromData(unsigned int labelid, const char* data, unsigned int size, unsigned int duration)
	{
		static char buff[1024] = {0};
		memset(buff, 0, 1024);
		
		snprintf(buff, 1023, "{\"isok\":\"true\", \"url\":\"%s\", \"duration\":\"%u\", \"labelid\":\"%u\"}", data, duration, labelid);

		return buff;
	}

	///发送文件内容到服务器
	void RTChatSDKMain::sendFileToServer(const std::string& filename)
	{
		CCLOG("in RTChatSDKMain::sendFileToServer, threadid = %d", GetCurrentThreadId());
		std::string mp3filename = filename + ".amr";
		long filesize = 0;

		if (_httpProcess)
		{
			_httpProcess->postFile(StRequestUrlInfo(_labelID, "http://uploadchat.ztgame.com.cn:10000/wangpan.php"), mp3filename, true);
		}

		/*FILE* fp_mp3 = fopen(mp3filename.c_str(), "rb");
		if (fp_mp3)
		{
			fseek (fp_mp3 , 0 , SEEK_END);  
			filesize = ftell (fp_mp3);  
			rewind (fp_mp3);

			char* buffer = (char*) malloc (sizeof(char)*filesize);
			size_t result = fread (buffer, 1, filesize, fp_mp3);
			if (result != filesize)
			{
				printf("文件长度读取错误");
			}

			if (_httpProcess)
			{
				StCallBackInfo info;
				info.labelid = 100;
				std::map<const char*, const char*> params;
				_httpProcess->postFile("http://uploadchat.ztgame.com.cn:10000/wangpan.php", info, mp3filename, true);
			}

			fclose(fp_mp3);
			free(buffer);
		}*/
	}

	/// 缓冲数据写入磁盘
	bool RTChatSDKMain::writeBufferToDisk(const StCallBackInfo& info)
	{
		if (info.labelid == 0 || info.datasize == 0)
		{
			return false;
		}

		std::string mp3filename = getMp3FileName(info.labelid);
		remove(mp3filename.c_str());

		FILE* fp_mp3 = fopen(mp3filename.c_str(), "wb");
		if (!fp_mp3)
		{
			return false;
		}

		size_t num = fwrite(info.ptr, sizeof(char), info.datasize, fp_mp3);
		if (num != info.datasize)
		{
			fclose(fp_mp3);
			return false;
		}
		fclose(fp_mp3);

		return true;
	}

	void RTChatSDKMain::SetStatus(std::string lpszFormat, ...)
	{
		//std::string csT1;
		//va_list args;

		//va_start(args, lpszFormat);
		//csT1.FormatV(lpszFormat,args);
		//va_end(args);
		//if(IsWindow(m_hWnd) && GetDlgItem(IDC_STATUS))
		//	GetDlgItem(IDC_STATUS)->SetWindowText(csT1);
	}

	void RTChatSDKMain::OpenDevice(std::string& filename)
	{
		int nT1=0;
		std::string csT1;
		double dT1=0.0;
		MMRESULT mRes=0;
		//CComboBox *pDevices=(CComboBox*)GetDlgItem(IDC_DEVICES);
		//CComboBox *pFormats=(CComboBox*)GetDlgItem(IDC_FORMATS);

		//nT1=pFormats->GetCurSel();
		//if(nT1==-1)
		//	throw "";
		//pFormats->GetLBText(nT1,csT1);
		//sscanf((PCHAR)(LPCTSTR)csT1,"%lf",&dT1);
		//dT1=dT1*1000;
		m_stWFEX.nSamplesPerSec = (int)16000;
		m_stWFEX.nChannels = 1;
		//csT1=csT1.Right(csT1.GetLength()-csT1.Find(',')-1);
		//csT1.Trim();
		//if(csT1.Find("mono")!=-1)
		//	m_stWFEX.nChannels=1;
		//if(csT1.Find("stereo")!=-1)
		//	m_stWFEX.nChannels=2;
		//csT1=csT1.Right(csT1.GetLength()-csT1.Find(',')-1);
		//csT1.Trim();
		//sscanf((PCHAR)(LPCTSTR)csT1,"%d",&m_stWFEX.wBitsPerSample);
		m_stWFEX.wBitsPerSample = 16;
		m_stWFEX.wFormatTag = WAVE_FORMAT_PCM;
		m_stWFEX.nBlockAlign = m_stWFEX.nChannels*m_stWFEX.wBitsPerSample/8;
		m_stWFEX.nAvgBytesPerSec = m_stWFEX.nSamplesPerSec*m_stWFEX.nBlockAlign;
		m_stWFEX.cbSize = sizeof(WAVEFORMATEX);
		int deveiceID = ChooseFirstRecordDevice();
		mRes = waveInOpen(&m_hWaveIn, deveiceID, &m_stWFEX, (DWORD_PTR)waveInProc, (DWORD_PTR)this, CALLBACK_FUNCTION);
		if(mRes!=MMSYSERR_NOERROR)
		{
			StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			throw m_csErrorText;
		}

		//std::stringstream ss;
		//std::string strtemp;
		//ss << _labelID;
		//ss >> strtemp;

		//csT1 = "D:\\SoundRec\\Release\\SoundRec" + strtemp + ".wav";
		filename = getFileName(_labelID);
		csT1 = filename + ".wav";

		ZeroMemory(&m_stmmIF,sizeof(MMIOINFO));
		remove((PCHAR)(LPCTSTR)csT1.c_str());

		std::wstring ww = std::wstring(csT1.begin(), csT1.end());
		m_hOPFile = mmioOpen((LPWSTR)(ww.c_str()),&m_stmmIF,MMIO_WRITE | MMIO_CREATE);
		//m_hOPFile = mmioOpen((PCHAR)(LPCTSTR)csT1.c_str(),&m_stmmIF,MMIO_WRITE | MMIO_CREATE);
		if(m_hOPFile==NULL)
			throw "Can not open file...";

		ZeroMemory(&m_stckOutRIFF,sizeof(MMCKINFO));
		m_stckOutRIFF.fccType = mmioFOURCC('W', 'A', 'V', 'E'); 
		mRes=mmioCreateChunk(m_hOPFile, &m_stckOutRIFF, MMIO_CREATERIFF);
		if(mRes!=MMSYSERR_NOERROR)
		{
			StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			throw m_csErrorText;
		}
		ZeroMemory(&m_stckOut,sizeof(MMCKINFO));
		m_stckOut.ckid = mmioFOURCC('f', 'm', 't', ' ');
		m_stckOut.cksize = sizeof(m_stWFEX);
		mRes=mmioCreateChunk(m_hOPFile, &m_stckOut, 0);
		if(mRes!=MMSYSERR_NOERROR)
		{
			StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			throw m_csErrorText;
		}
		nT1=mmioWrite(m_hOPFile, (HPSTR) &m_stWFEX, sizeof(m_stWFEX));
		if(nT1!=sizeof(m_stWFEX))
		{
			m_csErrorText = avar("Can not write Wave Header..File: %s ,Line Number:%d", __FILE__, __LINE__);
			throw m_csErrorText;
		}
		mRes=mmioAscend(m_hOPFile, &m_stckOut, 0);
		if(mRes!=MMSYSERR_NOERROR)
		{
			StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			throw m_csErrorText;
		}
		m_stckOut.ckid = mmioFOURCC('d', 'a', 't', 'a');
		mRes=mmioCreateChunk(m_hOPFile, &m_stckOut, 0);
		if(mRes!=MMSYSERR_NOERROR)
		{
			StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			throw m_csErrorText;
		}
	}

	void RTChatSDKMain::CloseDevice()
	{
		MMRESULT mRes=0;

		if(m_hWaveIn)
		{
			UnPrepareBuffers();
			mRes=waveInClose(m_hWaveIn);
		}
		if(m_hOPFile)
		{
			mRes=mmioAscend(m_hOPFile, &m_stckOut, 0);
			if(mRes!=MMSYSERR_NOERROR)
			{
				StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			}
			mRes=mmioAscend(m_hOPFile, &m_stckOutRIFF, 0);
			if(mRes!=MMSYSERR_NOERROR)
			{
				StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
			}
			mmioClose(m_hOPFile,0);
			m_hOPFile=NULL;
		}
		m_hWaveIn=NULL;
	}

	void RTChatSDKMain::PrepareBuffers()
	{
		MMRESULT mRes=0;
		int nT1=0;

		for(nT1=0; nT1<MAX_BUFFERS; ++nT1)
		{
			m_stWHDR[nT1].lpData = (LPSTR)HeapAlloc(GetProcessHeap(),8,m_stWFEX.nAvgBytesPerSec);
			m_stWHDR[nT1].dwBufferLength = m_stWFEX.nAvgBytesPerSec;
			m_stWHDR[nT1].dwUser = nT1;
			mRes = waveInPrepareHeader(m_hWaveIn,&m_stWHDR[nT1],sizeof(WAVEHDR));
			if(mRes!=0)
			{
				StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
				throw m_csErrorText;
			}
			mRes=waveInAddBuffer(m_hWaveIn,&m_stWHDR[nT1],sizeof(WAVEHDR));
			if(mRes!=0)
			{
				StoreError(mRes,FALSE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
				throw m_csErrorText;
			}
		}
	}

	void RTChatSDKMain::UnPrepareBuffers()
	{
		MMRESULT mRes=0;
		int nT1=0;

		if(m_hWaveIn)
		{
			mRes = waveInStop(m_hWaveIn);
			for(nT1=0 ;nT1<3; ++nT1)
			{
				if(m_stWHDR[nT1].lpData)
				{
					mRes = waveInUnprepareHeader(m_hWaveIn,&m_stWHDR[nT1],sizeof(WAVEHDR));
					HeapFree(GetProcessHeap(),0,m_stWHDR[nT1].lpData);
					ZeroMemory(&m_stWHDR[nT1],sizeof(WAVEHDR));
				}
			}
		}
	}

	int RTChatSDKMain::ChooseFirstRecordDevice()
	{
		UINT nDevices,nC1;
		WAVEINCAPS stWIC={0};
		MMRESULT mRes;

		nDevices = waveInGetNumDevs();	//获取设备数量

		for(nC1=0; nC1 < nDevices; ++nC1)
		{
			ZeroMemory(&stWIC,sizeof(WAVEINCAPS));
			mRes=waveInGetDevCaps(nC1,&stWIC,sizeof(WAVEINCAPS));
			if(mRes == 0)
				return nC1;
			else
				StoreError(mRes,TRUE,"File: %s ,Line Number:%d",__FILE__,__LINE__);
		}

		return -1;
	}

	std::string RTChatSDKMain::StoreError(MMRESULT mRes,BOOL bDisplay,std::string lpszFormat, ...)
	{
		MMRESULT mRes1=0;
		char szErrorText[1024]={0};
		char szT1[2*MAX_PATH]={0};

		va_list args;
		va_start(args, lpszFormat);
		//vsntprintf(szT1, MAX_PATH, lpszFormat, args);
		snprintf(szT1, MAX_PATH, lpszFormat.c_str(), args);
		va_end(args);

		//m_csErrorText.Empty();
		m_csErrorText.clear();
		if(m_bRun)
		{
			std::string kk = szErrorText;
			std::wstring ww = std::wstring(kk.begin(), kk.end());
			mRes1 = waveInGetErrorText(mRes,(LPWSTR)ww.c_str(),1024);
			if(mRes1!=0) {
				//wsprintf(szErrorText,"Error %d in querying the error string for error code %d",mRes1,mRes);
				sprintf(szErrorText,"Error %d in querying the error string for error code %d",mRes1,mRes);
			}
			//m_csErrorText.Format("%s: %s",szT1,szErrorText);
			m_csErrorText = avar("%s: %s",szT1,szErrorText);
			//if(bDisplay)
				//AfxMessageBox(m_csErrorText);
		}
		return m_csErrorText;
	}

	std::string RTChatSDKMain::getMp3FileName(unsigned int labelid)
	{
		std::stringstream ss;
		std::string strtemp;
		ss << labelid;
		ss >> strtemp;

		std::string path = FileUtils::getInstance()->getWritablePath();
		std::string mp3filename = path + "/SoundRec" + strtemp + ".amr";

		return mp3filename;
	}

	std::string RTChatSDKMain::getFileName(unsigned int labelid)
	{
		std::stringstream ss;
		std::string strtemp;
		ss << labelid;
		ss >> strtemp;

		std::string path = FileUtils::getInstance()->getWritablePath();
		std::string filename = path + "SoundRec" + strtemp;

		return filename;
	}

	//http请求回调函数(主线程工作)
	void RTChatSDKMain::httpRequestCallBack(HttpDirection direction, const StCallBackInfo& info)
	{
		CCLOG("in RTChatSDKMain::httpRequestCallBack");
		if (direction == HttpDirection::Upload) {
	        if (!info.ptr) {
	            //失败
	            _func(enRequestRec, OPERATION_FAILED, "");
	        }
	        else {
	            //NSInteger duration = [[SoundObject sharedInstance] getRecordDuration:info.labelid];
				std::string jsondata = constructJsonFromData(info.labelid, info.ptr, info.datasize, 5);
	            _func(enRequestRec, OPERATION_OK, jsondata);
	        }
	    }
	    else {
	        if (!info.ptr) {
	            //失败
	            //Todo...
	            _func(enRequestPlay, OPERATION_FAILED, "");
	        }
	        else {
	            /*NSData* data = [NSData dataWithBytes:info.ptr length:info.size];
	            
	            [[SoundObject sharedInstance] saveCacheToDiskFile:info.labelid data:data];
	            
	            [[SoundObject sharedInstance] beginPlay:data];*/
				writeBufferToDisk(info);
				std::string filename = getFileName(info.labelid);
				transferAmrToPcm(filename);
				CocosDenshion::SimpleAudioEngine::getInstance()->stopBackgroundMusic();
				CocosDenshion::SimpleAudioEngine::getInstance()->playBackgroundMusic((filename+".wav").c_str());
	            //_func(enRequestPlay, OPERATION_OK, "");
	        }
	    }
		CCLOG("in RTChatSDKMain::httpRequestCallBack");
	}


}




