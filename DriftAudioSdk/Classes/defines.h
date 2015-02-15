//
//  SdkPublic.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-8-5.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef RTChat_SdkPublic_h
#define RTChat_SdkPublic_h

namespace rtchatsdk {

#define SAFE_DELETE(p) if(p) {delete p; p = NULL;}

#define SAFE_DELETEARRAY(p) if(p) {delete [] p; p = NULL;}

#define MAX_BUFFER_SIZE 1024

typedef unsigned int DWORD;
typedef unsigned short WORD;

template <class T>
inline void constructDynamic(T *ptr) {
    new ((void*)ptr) T();
};

#define BUFFER_CMD(cmd, name, len) char buffer##name[len]; \
    cmd* name = (cmd*)buffer##name; \
    constructDynamic(name); \

#define VoiceUpLoadUrlHead  "http://uploadchat.ztgame.com.cn:10000/wangpan.php"

#define LogUpLoadUrlHead  "http://uploadchat.ztgame.com.cn:10000/uplog.php"

#ifdef DEBUG
    #define ControlServerAddr   "rtchat.ztgame.com.cn:18000"
//    #define ControlServerAddr   "180.168.126.249:18000"
#else
    #define ControlServerAddr   "rtchatrelease.ztgame.com.cn:18000"
#endif
    
#define VoiceToTextAppStr    @"appid=54acafe7,timeout=200000"
}

#endif
