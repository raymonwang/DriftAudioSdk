//
//  RTChatSdkAndroidImpl.h
//  RTChat
//
//  Created by yibin on 14-8-14.
//  Copyright (c) 2014年 yunwei. All rights reserved.
//
#include "RTChatSdkAndroidIpml.h"
#include "RTChatCommonTypes.h"

#include <android/log.h>
#include <jni.h>
#include <string>
#include "cocos2d.h"
//#include "cocos2dx/platform/android/jni/JniHelper.h"
//#include "../libs/cocos2dx/platform/android/jni/JniHelper.h"
#include "cocos/platform/android/jni/JniHelper.h"

#define MAX_BUFFER_SIZE 1024

template <class T>
inline void constructDynamic(T *ptr) {
    new ((void*)ptr) T();
};

#define BUFFER_CMD(cmd, name, len) char buffer##name[len]; \
    cmd* name = (cmd*)buffer##name; \
    constructDynamic(name); \



 #define LOGD(msg) \
     __android_log_print(ANDROID_LOG_ERROR, "RTChatSDK", "%s:%d: %s", __FILE__, \
                        __LINE__, msg); \

#define JVOEOBSERVER(rettype, name)                                             \
  extern "C" rettype JNIEXPORT JNICALL Java_com_lw_RecordImage_GameVoiceManager_##name

#define JAVATAROBSERVER(rettype, name)                                             \
  extern "C" rettype JNIEXPORT JNICALL Java_com_lw_RecordImage_GameAvatar_##name

#define  CLASS_NAME "com/lw/RecordImage/GameVoiceManager"
#define  AVATAR_CLASS_NAME "com/lw/RecordImage/GameAvatar"

namespace rtchatsdk {
    static  RTChatSDKMain* s_RTChatSDKMain = NULL;
    static jobject evoeObject = NULL;


    RTChatSDKMain& RTChatSDKMain::sharedInstance()
    {
        if (!s_RTChatSDKMain) {
            s_RTChatSDKMain = new RTChatSDKMain();
            //得到java 对象实例VoiceChannelEngineObserver
            
        }
        
        return *s_RTChatSDKMain;
    }

    jobject RTChatSDKMain::GetEVOEObject()
    {
        cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "GetIntance", "()Lcom/ztgame/embededvoice/VoiceChannelEngine;"))
        {
          return NULL;
        }
        
        jobject evoe = voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID);

        return evoe;
    }


    SdkErrorCode RTChatSDKMain::initSDK(const std::string& appid, const std::string& key,const char* uniqueid)
    {
       
       //  cocos2d::JniMethodInfo voemethodInfo;
       //  if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME,"Init","(Ljava/lang/String;)V"))
       //  {
       //    return OPERATION_FAILED;
       //  }

       //  jstring jappid = voemethodInfo.env->NewStringUTF(appid.c_str());
       // voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID,jappid);

        return OPERATION_OK;
    }

        //注册消息回调
    void RTChatSDKMain::registerMsgCallback(const pMsgCallFunc& func)
    {
       callbackfunc = func;
    }


    /// 设置自定义参数
    void RTChatSDKMain::setParams(const std::string& voiceUploadUrl, const char* xunfeiAppID)
    {
        cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "SetParams", "(Ljava/lang/String;Ljava/lang/String;)V"))
        {
            return NULL;
        }
        
        jstring jurl;
        jurl = voemethodInfo.env->NewStringUTF(voiceUploadUrl.c_str());
        
        jstring jXunfei;
        if (xunfeiAppID != NULL) {
            jXunfei = voemethodInfo.env->NewStringUTF(xunfeiAppID);
        }
        voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID, jurl, jXunfei);
        
        return true;
    }
     
        //开始录制麦克风数据
    bool RTChatSDKMain::startRecordVoice(unsigned int labelid)
    {


        cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "startRecordWithIndex", "(I)V"))
        {
          return NULL;
        }
        
        voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID,labelid);

        return true;
    }
        
        //停止录制麦克风数据
    bool RTChatSDKMain::stopRecordVoice()
    {
        cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "stopRecording", "()V"))
        {
          return NULL;
        }
        
        voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID);

        return true;
    }
        
    //开始播放录制数据
    bool RTChatSDKMain::startPlayLocalVoice(unsigned int labelid, const char* voiceUrl)
    {


         cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "startPlayingWithIndex", "(ILjava/lang/String;)V"))
        {
          return NULL;
        }
        
        jstring jurl;
        if(voiceUrl != NULL)
            jurl = voemethodInfo.env->NewStringUTF(voiceUrl);
        voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID,labelid,jurl);

        return true;
    }
        
        //停止播放数据
    bool RTChatSDKMain::stopPlayLocalVoice()
    {
       return true;
    }


    //取消录音
    bool RTChatSDKMain::cancelRecordedVoice()
    {

         cocos2d::JniMethodInfo voemethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(voemethodInfo,CLASS_NAME, "cancelRecordingVoice", "()V"))
        {
          return NULL;
        }
        
        voemethodInfo.env->CallStaticObjectMethod(voemethodInfo.classID, voemethodInfo.methodID);

        return true;
    }

        //设置头像
    bool RTChatSDKMain::setAvater(unsigned int uid,int type)
    {   
      
      cocos2d::JniMethodInfo imgmethodInfo;
      if (! cocos2d::JniHelper::getStaticMethodInfo(imgmethodInfo,AVATAR_CLASS_NAME, "setAvaterWithUid", "(II)V"))
        {
          return NULL;
        }
        
        imgmethodInfo.env->CallStaticObjectMethod(imgmethodInfo.classID, imgmethodInfo.methodID,uid,type);
      return true;
    }

        //获取头像
    bool RTChatSDKMain::getAvater(unsigned int uid,int type,const char* imageUrl)
    {

        cocos2d::JniMethodInfo imgmethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(imgmethodInfo,AVATAR_CLASS_NAME, "GetAvaterWithUid", "(IILjava/lang/String;)V"))
        {
          return NULL;
        }
        
        jstring jurl;
        if(imageUrl != NULL)
            jurl = imgmethodInfo.env->NewStringUTF(imageUrl);
        imgmethodInfo.env->CallStaticObjectMethod(imgmethodInfo.classID, imgmethodInfo.methodID,uid,type,jurl);

        return true;
    }
        
    ///开始语音识别
    bool RTChatSDKMain::startVoiceToText()
    {
        
        cocos2d::JniMethodInfo imgmethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(imgmethodInfo,CLASS_NAME, "startVoiceToText", "()V"))
        {
            return NULL;
        }
        
        imgmethodInfo.env->CallStaticObjectMethod(imgmethodInfo.classID, imgmethodInfo.methodID);
        return true;
    }

    ///停止语音识别
    bool RTChatSDKMain::stopVoiceToText()
    {
        
        cocos2d::JniMethodInfo imgmethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(imgmethodInfo,CLASS_NAME, "stopVoiceToText", "()V"))
        {
            return NULL;
        }
        
        imgmethodInfo.env->CallStaticObjectMethod(imgmethodInfo.classID, imgmethodInfo.methodID);
        return true;
    }
        
    ///开始GPS定位获取地理位置
    bool RTChatSDKMain::startQueryGeoInfo()
    {
        cocos2d::JniMethodInfo imgmethodInfo;
        if (! cocos2d::JniHelper::getStaticMethodInfo(imgmethodInfo, CLASS_NAME, "startQueryGeoInfo", "()V"))
        {
            return NULL;
        }
        
        imgmethodInfo.env->CallStaticObjectMethod(imgmethodInfo.classID, imgmethodInfo.methodID);
        return true;
    }
    
    uint64_t RTChatSDKMain::convertJstring2Uint64(jstring longstring)
    {
        std::string sTempID = cocos2d::JniHelper::jstring2string(longstring);
        uint64_t  temp64id = strtoull(sTempID.c_str(),NULL,10);
        return temp64id;
    }


    JVOEOBSERVER(int,RecordingStop)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      return 0;
    }

    JVOEOBSERVER(int,RecordingUploadEnd)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
      std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enRequestRec, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enRequestRec, OPERATION_FAILED, cResult);
      }
      return 0;
    }

    JVOEOBSERVER(int,RecordingVoiceDownloadBegin)(JNIEnv* jni,jobject thiz,jboolean isok,jstring result)
    {
      LOGD("---------------------");
      return 0;
    }

    JVOEOBSERVER(int,RecordingVoiceDownloadEnd)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enRequestPlay, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enRequestPlay, OPERATION_FAILED, cResult);
      }
      return 0;
    }

    JVOEOBSERVER(int,RecordingPlayVoiceOnStop)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enNotifyPlayOver, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enNotifyPlayOver, OPERATION_FAILED, cResult);
      }
      return 0;
    }


    JVOEOBSERVER(int,RecordingVoiceOnVolume)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enNotifyRecordPower, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enNotifyRecordPower, OPERATION_FAILED, cResult);
      }
      return 0;
    }



    JAVATAROBSERVER(void,setAvaterCallback)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enReqSetAvaterResult, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enReqSetAvaterResult, OPERATION_FAILED, cResult);
      }
      
    }

    JAVATAROBSERVER(void,getAvaterCallback)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
      LOGD("---------------------");
       std::string cResult = cocos2d::JniHelper::jstring2string(result);
      if(isok)
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enReqGetAvaterResult, OPERATION_OK,cResult);

      }else
      {
        RTChatSDKMain::sharedInstance().callbackfunc(enReqGetAvaterResult, OPERATION_FAILED, cResult);
      }
      
    }
        
    JVOEOBSERVER(void,OnReceiveVoiceText)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
        LOGD("---------------------");
        std::string cResult = cocos2d::JniHelper::jstring2string(result);
        if(isok)
        {
            RTChatSDKMain::sharedInstance().callbackfunc(enNotifyVoiceTextResult, OPERATION_OK,cResult);
            
        }else
        {
            RTChatSDKMain::sharedInstance().callbackfunc(enNotifyVoiceTextResult, OPERATION_FAILED, cResult);
        }
        
    }

    JVOEOBSERVER(void,OnReceiveGeoInfoText)(JNIEnv* jni,jobject thiz ,jboolean isok,jstring result)
    {
        LOGD("---------------------");
        std::string cResult = cocos2d::JniHelper::jstring2string(result);
        if(isok)
        {
            RTChatSDKMain::sharedInstance().callbackfunc(enNotifyCoodinateInfo, OPERATION_OK,cResult);
            
        }else
        {
            RTChatSDKMain::sharedInstance().callbackfunc(enNotifyCoodinateInfo, OPERATION_FAILED, cResult);
        }
        
    }
}

