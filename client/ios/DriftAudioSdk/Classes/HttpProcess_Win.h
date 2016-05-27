#pragma once
#ifndef __RTChat__HttpProcess__
#define __RTChat__HttpProcess__

#include <cocos2d.h>
#include "network\HttpClient.h"
#include <functional>
  
USING_NS_CC;
using namespace cocos2d::network;

enum HttpDirection {
	Download,
	Upload,
};

struct StRequestUrlInfo
{
	StRequestUrlInfo(unsigned int id, const char* ptr) {
		labelid = id;
		url = ptr;
	};
	unsigned int labelid;
	std::string url;
};

struct StCallBackInfo
{
	StCallBackInfo() {
		labelid = 0;
		ptr = NULL;
		datasize = 0;
	};
	StCallBackInfo(unsigned int id, const char* p, size_t size) {
		labelid = id;
		ptr = p;
		datasize = size;
	};
	~StCallBackInfo() {
		if (ptr)
		{
			delete(ptr);
			ptr = NULL;
		}
	}
	unsigned int labelid;
	const char* ptr;
	size_t datasize; 
};

typedef std::function<void (HttpDirection direction, const StCallBackInfo& info)> CallBackFunc;

class HttpProcess : public Ref
{
public:
	HttpProcess(void);
	virtual ~HttpProcess(void);

	CREATE_FUNC(HttpProcess);

	virtual bool init();

	void registerCallback(const CallBackFunc& func);

	void httpReqFinished(HttpClient *sender, HttpResponse *response);

	void postFile(const StRequestUrlInfo& urlinfo, const std::string& filepath, bool needcallback = true);

	void getFile(const StRequestUrlInfo& urlinfo, bool needcallback = true);

private:
	CallBackFunc		_func;
};

#endif

