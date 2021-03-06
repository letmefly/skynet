local cjson = require "cjson"

local prototext = [[
message userInfo_t {
    // player 1, 2, 3
    optional string userId = 1;
    optional string nickname = 2;
    // 1 male or 2 female
    optional int32 sexType = 3;
    optional string iconUrl = 4;
    optional int32 level = 5;
    optional int32 roomCardNum = 6;
    optional int32 playerId = 7;
    optional int32 win = 8;
    optional int32 lose = 9;
    optional int32 score = 10;
    optional string ip = 11;
    optional int32 status = 12;
    optional int32 isLandlord = 13;
    optional int32 boom = 14;
    optional int32 leftPoker = 15;
    optional int32 hasPlay = 16;
    optional int32 userno = 17;
    optional int32 redPackVal = 18;
}
message handshake {
  optional int32 sn = 1;
}
message clientHandshake {
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
    optional userInfo_t userInfo = 2;
}
message createRoom {
    // 3, or 4 
    optional int32 roomType = 1;
    optional int32 playTimes = 2;
    // 1 - roll mode, 2 - score mode
    optional int32 grabMode = 3;
    optional int32 maxBoom = 4;
    optional int32 isFree = 5;
}
message createRoom_ack {
    // 0 success, -1 room card not enough
    optional int32 errno = 1;
    optional string roomNo = 2;
}
message joinRoom {
    optional string roomNo = 1;
}
message joinRoom_ack {
    // 0 success, -1 room number invalid
    optional int32 errno = 1;
    optional int32 playerId = 2;
    optional int32 currPlayTimes = 3;
    optional int32 maxPlayTimes = 4;
    optional int32 grabMode = 5;
    optional int32 roomType = 6;
    optional int32 maxBoom = 7;
}

message rejoinRoom {
    optional string roomNo = 1;
    optional int32 playerId = 2;
}

message rejoinRoom_ack {
    optional int32 errno = 1;
}

message joinRoomOk {
    optional int32 playerId = 1;
}
message joinRoomOk_ntf {
    repeated userInfo_t userInfoList = 1;
}
message reJoinRoomOk_ack {
    repeated userInfo_t userInfoList = 1;
    repeated int32 pokerList = 2;
    repeated int32 bottomList = 3;
    optional int32 prevPlayerId = 4;
    repeated int32 prevPlayPokerList = 5;
    optional int32 currPlayTimes = 6;
    optional int32 grabLevel = 7;
}
message leaveRoom {
    // player 1, 2, 3
    optional int32 playerId = 1;
}
message leaveRoom_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    optional int32 t = 2;
}
// when client load res ok and switch to game screen, 
// notify server that client is ready
message getReady {
    optional int32 status = 1;
    optional int32 playerId = 2;
}
message getReady_ntf {
    repeated int32 readyList = 1;
}
message startGame {
    optional int32 playerId = 1;
}
message startGame_ntf {
    // 17 poker
    repeated int32 pokerList = 1;
    repeated int32 bottomList = 2;
    optional int32 status = 3;
    optional int32 currPlayTimes = 4;
}
message restartGame_ntf {
    optional int32 errno = 1;
}
message whoGrabLandlord_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
}
message alarmTimer_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    optional int32 timerVal = 2;
    optional string timerType = 3;    
}
message stopAlarmTimer_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    optional string timerType = 2;    
}
message grabLandlord {
    // player 1, 2, 3
    optional int32 playerId = 1;
    // 1, skip, 2 grab level 1, 3 grab level 2
    optional int32 grabAction = 2;
}
message grabLandlord_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    // 1, skip, 2 grab level 1, 3 grab level 2
    optional int32 grabAction = 2;
    optional int32 grabLevel = 3;
}
message landlord_ntf {
    optional int32 playerId = 1;
    repeated int32 bottomPokerList = 2;
}
// whose token for choosing poker 
message whoPlay_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    optional int32 prevPlayerId = 2;
}
message playPoker {
    optional int32 playerId = 1;
    // 1 skip, 2 play poker
    optional int32 playAction = 2;
    // 1 - single, 2 - pair, 3 - joker boom, 4 - 3poker, 5 - boom, 6 - 3+1,
    // 7 - sequence, 8 - 4+2, 9 - pair sequence, 10 - airplane
    optional int32 pokerType = 3;
    repeated int32 pokerList = 4;
}
message playPoker_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
    // 1 skip, 2 grab landlord, 3 skip
    optional int32 playAction = 2;
    optional int32 pokerType = 3;
    repeated int32 pokerList = 4;
    optional int32 grabLevel = 5;
}
message playTimeout_ntf {
    // player 1, 2, 3
    optional int32 playerId = 1;
}
message lastPoker_ntf {
    optional int32 playerId = 1;
    // 2 or 1
    optional int32 pokerNum = 2;
}
message chat {
    optional int32 playerId = 1;
    optional string t = 2;
    optional string v = 3;
}
message chat_ntf {
    optional int32 playerId = 1;
    optional string t = 2;
    optional string v = 3;
}
message gameResult_ntf {
    //optional int32 totalFactor = 1;
    //optional int32 visiblePokeFactor = 2;
    //optional int32 grapLandlordFactor = 3;
    //optional int32 boomFactor = 4;
    //optional int32 springFactor = 5;
    message GameResultInfo {
        optional int32 playerId = 1;
        // 1 lose, 2 win
        optional int32 result = 2;
        optional int32 leftPokerNum = 3;
        optional int32 boomNum = 4;
        optional int32 score = 5;
        optional string nickname = 6;
        optional int32 isSpring = 7;
        optional int32 totalScore = 8;
    }
    message PokerList_t {
        optional int32 playerId = 1;
        repeated int32 pokerList = 2;
    }
    repeated GameResultInfo resultList = 1;
    repeated PokerList_t allPlayerPokerSet = 2;
}
message roomResult_ntf {
    message RoomResultItem_t {
        optional int32 playerId = 1;
        optional int32 totalBoom = 2;
        optional int32 maxScore = 3;
        optional int32 winTimes = 4;
        optional int32 totalScore = 5;
        optional string nickname = 6;
        optional int32 loseTimes = 7;
    }
    repeated RoomResultItem_t roomResultList = 1;
}
message dismissRoom_ntf {
    message DismissInfo_t {
        optional int32 playerId = 1;
        optional int32 result = 2;
    }
    repeated DismissInfo_t dismissInfoList = 1;
    optional int32 whoDismiss = 2;
}
message dismissRoom {
    optional int32 playerId = 1;
    optional int32 result = 2; // 1 refuse, 2 agree
}
message scoreRaceGetRoomNo {
    optional int32 maxPlayerNum = 1;
}
message scoreRaceGetRoomNo_ack {
    optional string roomNo = 1;
    optional int32 errno = 2;
}
message redPackStart_ack {
    optional int32 playerId = 1;
    optional int32 redPackVal = 2;
}
message redPackOver_ack {
    optional int32 playerId = 1;
}
message getRedPack {
    optional int32 playerId = 1;
}
message getRedPack_ack {
    optional int32 result = 1;
    optional int32 redPackVal = 2;
}
message changeRoom {
    optional int32 playerId = 1;
    optional int32 maxPlayerNum = 2;
}
message changeRoom_ack {
    optional string roomNo = 1;
    optional int32 errno = 2;
}

]]


local type2name_json = [[
{
    "1": "handshake",
    "2": "gameLogin",
    "3": "gameLogin_ack", 
    "4": "createRoom", 
    "5": "createRoom_ack",
    "6": "joinRoom",
    "7": "joinRoom_ack",
    "8": "leaveRoom",
    "9": "leaveRoom_ntf",
    "10": "getReady",
    "11": "getReady_ntf",
    "12": "startGame_ntf",
    "13": "restartGame_ntf",
    "14": "whoGrabLandlord_ntf",
    "15": "grabLandlord_ntf",
    "16": "landlord_ntf",
    "17": "grabLandlord",
    "18": "whoPlay_ntf",
    "19": "playPoker",
    "20": "playPoker_ntf",
    "21": "playTimeout_ntf",
    "22": "lastPoker_ntf",
    "23": "chat",
    "24": "chat_ntf",
    "25": "gameResult_ntf",
    "26": "roomResult_ntf",
    "27": "joinRoomOk_ntf",
    "28": "joinRoomOk",
    "29": "alarmTimer_ntf",
    "30": "stopAlarmTimer_ntf",
    "31": "reJoinRoomOk_ack",
    "32": "clientHandshake",
    "33": "dismissRoom_ntf",
    "34": "dismissRoom",
    "35": "scoreRaceGetRoomNo",
    "36": "scoreRaceGetRoomNo_ack",
    "37": "redPackStart_ack",
    "38": "redPackOver_ack",
    "39": "getRedPack",
    "40": "getRedPack_ack",
    "41": "changeRoom",
    "42": "changeRoom_ack"
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
--  [1] = "user_register",
--  [2] = "user_register_ack", 
--  [3] = "user_login", 
--  [4] = "user_login_ack",
--  [5] = "handshake"
-- }

return prototext