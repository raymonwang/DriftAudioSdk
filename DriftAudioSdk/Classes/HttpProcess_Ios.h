//
//  HttpProcess.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-9-2.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef __RTChat__HttpProcess__
#define __RTChat__HttpProcess__

#include <iostream>
#include <map>

namespace rtchatsdk {

    enum HttpDirection {
        HttpProcess_DownLoad,
        HttpProcess_Upload,
    };
    
    enum DownloadDataType {
        VoiceType = 1,
        VideoType = 2,
        PictureType = 3,
    };
    
    struct StRequestUrlInfo {
        StRequestUrlInfo(unsigned int id, const char* str, DownloadDataType inType) {
            labelid = id;
            url = str;
            type = inType;
        }
        unsigned int labelid;
        std::string url;
        DownloadDataType type;
    };
    
    struct StCallBackInfo {
        StCallBackInfo(const char* p1, size_t p2, unsigned int p3, const char* cUrl, unsigned int p4 = 0, DownloadDataType inType = VoiceType) {
            ptr = p1;
            size = p2;
            labelid = p3;
            url = cUrl;
            duration = p4;
            type = inType;
        }
        const char* ptr;
        size_t size;
        unsigned int labelid;
        std::string url;
        unsigned int duration;
        DownloadDataType type;
    };

    typedef std::function<void (HttpDirection direction, const StCallBackInfo& info)> CallBackFunc;

    class HttpProcess {
    public:
        HttpProcess();
        virtual ~HttpProcess();
        
        static HttpProcess& instance();
        
        void registerCallBack(const CallBackFunc& func);
        
        void postContent(const char* urlstr, const StCallBackInfo& urlinfo, std::map<const char*, const char*>& params, bool needcallback = true);
        
        void requestContent(const StRequestUrlInfo& urlinfo);
        
    private:
        bool            _isrunning;
        CallBackFunc    _func;
};
    
}

#endif /* defined(__RTChat__HttpProcess__) */
