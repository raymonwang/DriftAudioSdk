//
//  RTChatCommonTypes.h
//  RTChat
//
//  Created by wang3140@hotmail.com on 14-8-7.
//  Copyright (c) 2014年 RTChatTeam. All rights reserved.
//

#ifndef RTChat_RTChatCommonTypes_h
#define RTChat_RTChatCommonTypes_h

#include <strings.h>
#include <stdint.h>

namespace rtchatsdk {

enum enRoomType
{
    ROOM_TYPE_MIN = 0,
    ROOM_TYPE_QUEUE = 1, /// 单人队列排麦模式(只能一个人拿麦)
	ROOM_TYPE_FREE = 2,  /// 自由模式(最多4个人)
	ROOM_TYPE_TWO = 3,   /// 二人模式
	ROOM_TYPE_ONLY = 4,   /// 抢麦模式
    ROOM_TYPE_MAX = 5,
};

/// 创建房间的理由
enum enRoomReason
{
	ROOM_REASON_MIN = 0,
	ROOM_REASON_NORMAL = 1,
	ROOM_REASON_RANDCHAT = 2,
	ROOM_REASON_MAX = 3,
};

/// 房间权限类型
enum enPowerType
{
	POWER_TYPE_NORMAL = 1, /// 普通的人
	POWER_TYPE_MASTER = 2, /// 房主
	POWER_TYPE_ADMIN = 3, /// 管理员(房主分配的)
};

enum enAssignResult
{
    ASSIGN_RESULT_NOPOWER,
    ASSIGN_RESULT_TYPEERR,
    ASSIGN_RESULT_NOUSER,
    ASSIGN_RESULT_SYSERR,
};


enum SdkOpState {
    SdkControlUnConnected = 0,
    SdkControlConnecting,
    SdkControlConnected,
    SdkWaitingGateWayInfo,
    SdkGateWaySocketUnConnected,
    SdkGateWaySocketConnecting,
    SdkGateWaySocketConnected,
    SdkUserLogining,
    SdkUserLogined,
    SdkUserCreatingRoom,
//    SdkUserCreatedRoom,
    SdkUserjoiningRoom,
    SdkUserJoinedRoom,
    SdkUserWaitingToken,
    SdkUserSpeaking,
};

enum SdkResponseCmd {
    enNone = 0,
    
	/// 请求逻辑服务器信息
	enRequestLogicInfo = 1,
    
	/// 返回需要连接的逻辑服务器信息
	enNotifyLogicInfo = 2,
    
	/// 请求登录
	enRequestLogin = 3,
    
	/// 返回登录结果
	enNotifyLoginResult = 4,
    
	/// 创建房间
	enRequestCreateRoom = 5,
    
	/// 创建房间返回
	enNotifyCreateResult = 6,
    
	/// 加入房间
	enRequestEnterRoom = 7,
    
	/// 加入房间返回
	enNotifyEnterResult = 8,
    
	/// 申请房间列表
	enRequestRoomList = 9,
    
	/// 返回房间列表
	enNotifyRoomList = 10,
    
	/// 增加收听通道
	enNotifyAddVoiceUser = 11,
    
	/// 加入麦序
	enJoinMicQueue = 12,
    
	/// 离开麦序
	enLeaveMicQueue = 13,
    
	/// 返回麦序
	enNotifyMicQueue = 14,
    
	/// 到某人聊天了
	enNotifyTakeMic = 15,
    
	/// 离开房间
	enRequestLeaveRoom = 16,
    
    /// 删除一个通道
	enNotifyDelVoiceUser = 17,
    
    /// 通知有人进入房间
	enNotifySomeEnterRoom = 18,
    
    /// 有人离开房间
	enNotifySomeLeaveRoom = 19,
    
	/// 有人想和你随机聊天
	enNotifyRandChat = 21,
    
	/// 返回是否要随机聊天
	enReturnRandChat = 22,
    
    /// 更新权限
	enRequestUpdatePower = 23,
    
	/// 通知更新权限
	enNotifyUpdatePower = 24,
    
	/// 请求录音
	enRequestRec = 25,
    
	/// 请求播放
	enRequestPlay = 26,
    
    /// 请求漂流瓶
	enRequestRandPlay = 27,
    
	/// 通知漂流瓶
	enNotifyRandPlay = 28,
    
	/// 分配麦
	enRequestAssignMic = 29,
    
	/// 分配返回结果
	enNotifyAssignResult = 30,
    
	/// 更新权限结果
	enNotifyUpdatePowerResult = 31,
    
    /// 设置头像回调
    enReqSetAvaterResult = 32,
    
    /// 设置头像回调
    enReqGetAvaterResult = 33,
    
    /// 通知即时录音音量
    enNotifyRecordPower = 34,
    
    /// 通知播放停止
    enNotifyPlayOver = 35,
    
    /// 通知视频回调
    enNotifyRecordVideoOver = 36,
    
    ///通知语音识别文本结果回调
    enNotifyVoiceTextResult = 37,
    
    ///通知经纬度定位回调
    enNotifyCoodinateInfo = 38,
};

enum SdkErrorCode {
    OPERATION_OK = 0,   //通用成功消息
    OPERATION_FAILED,   //通用失败消息
    OPERATION_VERSION_LOW,  //操作系统版本号低

    /* 异步回调消息错误码开始 */
    LOGIC_RESULT_APPID_NOEXITS,
    LOGIC_RESULT_KEY_ERROR,
    LOGIC_RESULT_SYS_ERROR,
    LOGIC_RESULT_OK,
    
    LOGIN_RESULT_TOKEN_ERROR,
    LOGIN_RESULT_OK,
    
    ENTER_RESULT_NOEXITS,
    ENTER_RESULT_FULL,
    ENTER_RESULT_OK,
    ENTER_RESULT_ERROR,
    /* 异步回调消息错误码结束 */
    
};

struct StNotifyLoginResult {
    StNotifyLoginResult(bool res, uint64_t id) {
        isok = res;
        tempid = id;
    }
    bool isok;
    uint64_t tempid;
};

struct StNotifyCreateResult {
    StNotifyCreateResult(bool ok, uint64_t id, enRoomType type) {
        isok = ok;
        roomid = id;
        roomtype = type;
    }
    bool isok;
    uint64_t roomid;
    enRoomType roomtype;
};

struct StNotifyEnterResult {
    StNotifyEnterResult(uint64_t id, enRoomType type) {
        roomid = id;
        roomtype = type;
    };
    uint64_t roomid;
    enRoomType roomtype;
};

struct StRoomInfo {
    uint64_t roomid;
    enRoomType roomtype;
    uint32_t num;
};

struct StNotifyRoomList {
    uint32_t size;
    StRoomInfo roominfo[0];
    uint32_t getSize() const {return sizeof(StNotifyRoomList)+ sizeof(StRoomInfo)*size;}
};

//收听用户信息
struct StVoiceUserInfo
{
	uint64_t userid;
};

//增加收听用户，即房间进入新用户
struct StNotifyAddVoiceUser {
    uint32_t size;
    StVoiceUserInfo userinfo[0];
    uint32_t getSize() const {return sizeof(StNotifyAddVoiceUser)+ sizeof(StVoiceUserInfo)*size;}
};

struct StMicInfo {
    StMicInfo() {
        tempid = 0;
    }
    uint64_t tempid;     //SDK内部用户ID
    char uniqueid[64];  //应用侧用户ID
};

struct StNotifyMicQueue {
    StNotifyMicQueue() {
        bzero(this, sizeof(*this));
    }
    uint32_t size;
    StMicInfo micinfo[0];
    uint32_t getSize() const {return sizeof(StNotifyMicQueue)+ sizeof(StMicInfo)*size;}
};

struct StNotifyTakeMic {
    StNotifyTakeMic(uint64_t id, const char* uniqueidstr, uint32_t time) {
        tempid = id;
        bzero(uniqueid, sizeof(uniqueid));
        bcopy(uniqueidstr, uniqueid, sizeof(uniqueid));
        mtime = time;
    }
    uint64_t tempid;    //持有麦的用户SDKID;
    char uniqueid[64];  //应用侧用户ID
    uint32_t mtime; //麦序持续时间
};

//删除收听用户，即房间进入新用户
struct StNotifyDelVoiceUser {
    uint32_t size;
    StVoiceUserInfo userinfo[0];
    uint32_t getSize() const {return sizeof(StNotifyDelVoiceUser)+ sizeof(StVoiceUserInfo)*size;}
};

struct stRoomUserInfo {
    uint64_t tempid;     //SDK内部用户ID
    char uniqueid[64];  //应用侧用户ID
    enPowerType power;  //用户权限
};

//通知有人进入房间
struct StNotifySomeEnterRoom {
    StNotifySomeEnterRoom(){
        size = 0;
        needClearOld = false;
    }
    uint32_t    size;
    bool        needClearOld;
    stRoomUserInfo userinfo[0];
    uint32_t getSize() const {return sizeof(StNotifySomeEnterRoom)+ sizeof(stRoomUserInfo)*size;}
};

//通知有人离开房间
struct StNotifySomeLeaveRoom {
    uint64_t tempid;
};

//有人想和你随机聊天
struct StNotifyRandChat {
    StNotifyRandChat(uint64_t id, const char* uniqueidstr, uint64_t rid) {
        tempid = id;
        bzero(uniqueid, sizeof(uniqueid));
        bcopy(uniqueidstr, uniqueid, sizeof(uniqueid));
        roomid = rid;
    }
    uint64_t tempid;    //对方SDK唯一ID
	char uniqueid[64];  //对方应用或昵称ID
	uint64_t roomid;    //已建立好的房间ID
};

/// 告知发起随机聊天结果
struct StReturnRandChat {
    StReturnRandChat(bool res, uint64_t id) {
        isok = res;
        tempid = id;
    }
    bool isok;
    uint64_t tempid;
};

/// 请求录音结果
struct StRequestRec {
    StRequestRec(){
        bzero(this, sizeof(*this));
    }
    bool isok;
    char urlbuf[256];    //返回录音文件获取url
    uint64_t voicetime;     //录音文件时长
};

/// 通知更新权限(更新显示)
struct StNotifyUpdatePower {
    StNotifyUpdatePower(uint64_t id, enPowerType type) {
        tempid = id;
        power = type;
    }
	uint64_t tempid;
	enPowerType power;
};

/// 分配麦返回结果
struct StNotifyAssignResult {
    StNotifyAssignResult(enAssignResult reason) {
        result = reason;
    }
	enAssignResult result;
};

/******************回调字符串JSON格式******************/

// enNotifyLoginResult, 返回登录结果
// Json: {"data":{sdkid:"111"}}

// enNotifyCreateResult, 创建房间返回
// Json: {"data":{res:"true",roomid:"111",ip:"192.168.1.1",port:"8080"}}

// enEnterResult, 加入房间返回
// Json: {"data":{res:"true",ip:"192.168.1.1",port:"8080"}}

// enNotifyRoomList, 返回房间列表
// Json: {"data":[{roomid:"111"},{roomid:"222"}]}

// enNotifyRoomList, 返回返回麦序
// Json: {"data":[{sdkid:"111"},{sdkid:"222"}]}

// enTakeMic, 谁拿到了当前的麦
// Json: {"data":{"tempid":"1111", "mtime"="300"}}

// enNotifyRecordPower
// Json:  {"isok":"true", "power":"0.342392"} power范围为0.0-1.0
    
}

#endif
