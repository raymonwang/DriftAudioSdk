#include "HttpProcess_Win.h"
#include "network\HttpClient.h"
#include "DriftAudioSdk\RTChatSDKMain_Win.h"

using namespace cocos2d::network;

HttpProcess::HttpProcess(void)
{
}


HttpProcess::~HttpProcess(void)
{
}

bool HttpProcess::init()
{
	return true;
}

void HttpProcess::registerCallback(const CallBackFunc& func)
{
	_func = func;
}

void HttpProcess::httpReqFinished(HttpClient *sender, HttpResponse *response)
{
	CCLOG("in httpReqFinished");
	if (!response) {
        return;
    }

	if (!response->isSucceed()) {
        log("response failed");
        log("error buffer: %s",response->getErrorBuffer());
        return;
    }

	log("response code:%s", response->getHttpRequest()->getTag());
	std::vector<char>* buffer = response->getResponseData();
	char* userdata = (char*)response->getHttpRequest()->getUserData();
	int labelid = 0;
	if (userdata)
	{
		labelid = atoi(userdata);
		delete(userdata);
		userdata = NULL;
	}

	char* data = new char[buffer->size()+1];
	memset(data, 0, buffer->size()+1);
	memcpy(data, &(*buffer)[0], buffer->size());
	log("%s", data);

	if (!strncmp(response->getHttpRequest()->getTag(), "PostFile", 32))
	{
		StCallBackInfo info = StCallBackInfo(labelid, data, buffer->size());
		//_func(HttpDirection::Upload, info);
		rtchatsdk::RTChatSDKMain::sharedInstance().httpRequestCallBack(HttpDirection::Upload, info);
	}
	else if (!strncmp(response->getHttpRequest()->getTag(), "GetFile", 32))
	{
		StCallBackInfo info = StCallBackInfo(labelid, data, buffer->size());
		//_func(HttpDirection::Download, info);
		rtchatsdk::RTChatSDKMain::sharedInstance().httpRequestCallBack(HttpDirection::Download, info);
	}
}

void HttpProcess::postFile(const StRequestUrlInfo& urlinfo, const std::string& filepath, bool needcallback)
{
	CCLOG("in HttpProcess::postFile, threadid=%d", GetCurrentThreadId());
	HttpRequest* request= new HttpRequest;
	if (request)
	{
		char* userdata = new char[32];
		snprintf(userdata, 31, "%u", urlinfo.labelid);
		request->setTag("PostFile");
		request->setUrl(urlinfo.url.c_str());
		request->setRequestType(HttpRequest::Type::POST);
		request->setUserData(userdata);
		request->setResponseCallback(CC_CALLBACK_2(HttpProcess::httpReqFinished, this));
		HttpClient::getInstance()->addFormFile("file", filepath.c_str(), "application/octet-stream");
		HttpClient::getInstance()->send(request);
		//delete request;
		//request = NULL;
	}
	CCLOG("out HttpProcess::postFile");
}

void HttpProcess::getFile(const StRequestUrlInfo& urlinfo, bool needcallback)
{
	CCLOG("in HttpProcess::getFile, threadid=%d", GetCurrentThreadId());
	HttpRequest* request= new HttpRequest;
	if (request)
	{
		char* userdata = new char[32];
		snprintf(userdata, 31, "%u", urlinfo.labelid);
		request->setTag("GetFile");
		request->setUrl(urlinfo.url.c_str());
		request->setRequestType(HttpRequest::Type::GET);
		request->setUserData(userdata);
		request->setResponseCallback(CC_CALLBACK_2(HttpProcess::httpReqFinished, this));
		HttpClient::getInstance()->send(request);
	}
}

