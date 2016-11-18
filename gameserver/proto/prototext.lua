local cjson = require "cjson"

local prototext = [[

message handshake {
  optional int32 sn = 1;
}

message gameLogin {
	optional string userId = 1;
	optional string authCode = 2;
	optional int32 version = 3;
}

message gameLogin_ack {
	// 0 success, -1 auth code invalid, -2 version too low
	optional int32 errno = 1;
}

message createRoom {
	optional int32 roomType = 1;
}

message createRoom_ack {
	// 0 success, -1 room card not enough
	optional int32 errno = 1;
	optional string roomNum = 2;
}

message joinRoom {
	optional string roomNum = 1;
}

message joinRoom_ack {
	// 0 success, -1 room number invalid
	optional int32 errno = 1;
}

message leaveRoom {
	// player 1, 2, 3
	optional int32 who = 1;
}

message leaveRoom_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
}

// when client load res ok and switch to game screen, 
// notify server that client is ready
message ready {
	optional int32 ready = 1;
}

message ready_ntf {
	message UserInfo {
		// player 1, 2, 3
		optional int32 who = 1;
		optional string nickname = 2;
		// 1 male or 2 female
		optional int32 sexType = 3;
		optional string iconUrl = 4;
		optional int32 level = 5;
		optional int32 roomCardNum = 6;
	}
	repeated UserInfo userInfoList = 1;
}

message start_ntf {
	// 17 poker
	repeated int32 pokerList = 1;
}

message whoGrabLandlord_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
}

message grabLandlord {
	// 1 grab, 2 skip
	optional int32 grabAction = 1;
}

message grabLandlord_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
	// 1 grab, 2 skip
	optional int32 grabAction = 2;
}

message landlord_ntf {
	optional int32 landlord = 1;
}

// whose token for choosing poker 
message whoPlay_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
}

message playPokeInfo {
	// 1 skip, 2 grab landlord, 3 skip
	optional int32 playAction = 1;
	// 1 - single, 2 - pair, 3 - joker boom, 4 - 3poker, 5 - boom, 6 - 3+1,
	// 7 - sequence, 8 - 4+2, 9 - pair sequence, 10 - airplane
	optional int32 pokerType = 2;
	repeated int32 pokerList = 3;
}

message playPokeInfo_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
	// 1 skip, 2 grab landlord, 3 skip
	optional int32 playAction = 2;
	optional int32 pokerType = 3;
	repeated int32 pokerList = 4;
}

message playTimeout_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
}

message last2Poker_ntf {
	optional int32 who = 1;
	// 2 or 1
	optional int32 pokerNum = 2;
}

message chat {
	optional int32 fastTalkId = 1;
	optional string talkText = 2;
}

message chat_ntf {
	// player 1, 2, 3
	optional int32 who = 1;
	optional int32 fastTalkId = 2;
	optional string talkText = 3;
}

message gameResult_ntf {
	optional int32 totalFactor = 1;
	optional int32 visiblePokeFactor = 2;
	optional int32 grapLandlordFactor = 3;
	optional int32 boomFactor = 4;
	optional int32 springFactor = 5;

	message GameResultInfo {
		optional int32 who = 1;
		// 1 win, 2 lose
		optional int32 result = 2;
		optional int32 isLandlord = 3;
		optional int32 totalFactor = 4;
		optional int32 score = 5;
	}
	repeated GameResultInfo resultList = 6;
}

message roomResult_ntf {

}

]]


local type2name_json = [[

{
	"1": "user_check_version",
	"10": "user_register",
	"2": "user_register_ack", 
	"3": "user_login", 
	"4": "user_login_ack",
	"5": "handshake",
	"6": "game_start",
	"7": "game_start_ack",
	"8": "game_result",
	"9": "game_result_ack"
}

]]

local errno2desp_json = [[

{
	"1000": "用户已存在",
	"1001": "数据库错误",
	"1002": "用户名或者密码错误",
	"2000": "好友已存在"
}

]]

PROTO_TYPE2NAME = {}

local type2name = cjson.decode(type2name_json)
for k, v in pairs(type2name) do
	PROTO_TYPE2NAME[tonumber(k)] = v
end

-- PROTO_TYPE2NAME = {
-- 	[1] = "user_register",
-- 	[2] = "user_register_ack", 
-- 	[3] = "user_login", 
-- 	[4] = "user_login_ack",
-- 	[5] = "handshake"
-- }

return prototext
