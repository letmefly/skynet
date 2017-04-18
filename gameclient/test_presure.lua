package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"
local util = require "util"
local socket = require "clientsocket"
local netpack = require "netpack"
local cjson = require "cjson"
local pokerUtil = require "pokerUtil"

local play_count = 0

---------------------------------------------------------------------------
local WATCHDOG
local host
local send_request

local SERVICE_API = {}
local CLIENT_REQ = {}
local AI = {}
AI.maxPlayerNum = 3
local client_fd

-- 1 is protobuf, 2 is json
local PROTO_TYPE = 1
local client_is_alive = true

local my_room_sid = -1
local my_room_no = 0
local my_room_type = 0
local my_room_maxplaytimes = 0
local room_playerId = -1
local user_info = {}

function test_start(conf)
	local version = conf.version
	local userId =  conf.userId
	local authCode = conf.authCode
	print("Now create AI for "..userId)
	AI.gameLogin({version = version, userId = userId, authCode = authCode})
end

function test_sleep(n)
   os.execute("sleep " .. n/100)
end

------------------------ helper function ------------------------
local function send_client_msg(msgname, msg)
	if msgname ~= "alarmTimer_ntf" and msgname ~= "clientHandshake" and msgname ~= "handshake"then
		print(msgname..": "..cjson.encode(msg))
	end
	local cb = AI[msgname]
	if cb then
		cb(msg)
	end
end

local function client_msg_handler(msgname, msg)
	client_is_alive = true
	if msgname ~= "alarmTimer_ntf" and msgname ~= "clientHandshake" and msgname ~= "handshake"then
		print(msgname..": "..cjson.encode(msg))
	end
	util.sendmsg(client_fd, msgname, msg)
	--[[
	local handler = CLIENT_REQ[msgname]
	if handler then
		handler(msg)
	else
		print("[agent]no msg handler for " .. msgname)
	end
	]]
end

local function on_client_disconnect()
	-- todo: do something before exit
	if my_room_sid then
		skynet.call(my_room_sid, "lua", "disconnect", room_playerId)
	end
	skynet.exit()
end

---------------------------- AI Functions ---------------------------
function AI.isMe(playerId)
	return playerId == AI.playerId
end
function AI.isMeLandlord()
	return AI.gameData.landlord == AI.playerId
end
function AI.isFriend(playerId)
	if AI.gameData.landlord == AI.playerId then
		if AI.isMe(playerId) == false then
			return false
		else
			return true
		end
	else
		if playerId == AI.gameData.landlord then
			return false
		else
			return true
		end
	end
end

function AI.calcIsGrabLandlord()
	return pokerUtil.ai_isGrabLandlord(AI.gameData.pokerList, AI.gameData.bottomList)
end

function AI.calcPlayPoker()
	local ret = {}
	local prevPlayerId, prevPokerList = AI.getPrevPokerList()
	local isFriendPlay = AI.isFriend(prevPlayerId)
	if AI.gameData and AI.gameData.pokerList then
		ret = pokerUtil.ai_getPlayPoker(AI.gameData.pokerList, prevPokerList, isFriendPlay)
		--print("1. "..cjson.encode(next1Info))
		print("1. "..cjson.encode(prevPokerList))
		print("2. "..cjson.encode(ret))
	end
	return ret
end

function AI.getWaitTime()
	return math.random(5, 20)*10
end

function AI.getNextPlayer(playerId)
	playerId = playerId + 1
	if playerId > AI.maxPlayerNum then
		playerId = 1
	end
	return playerId
end

function AI.getPrevPlayerId(playerId)
    local prevPlayerId = playerId - 1
    if prevPlayerId == 0 then
        prevPlayerId = AI.maxPlayerNum
    end
    return prevPlayerId
end

function AI.getPrevPokerList()
	if AI.gameData.prevPokerListRecord == nil then 
		return -1, {} 
	end
	local playerId = AI.getPrevPlayerId(AI.playerId)
	while AI.playerId ~= playerId do
		if AI.gameData.prevPokerListRecord[playerId] and #AI.gameData.prevPokerListRecord[playerId] > 0 then
			return playerId, AI.gameData.prevPokerListRecord[playerId]
		end
		playerId = AI.getPrevPlayerId(playerId)
	end
	return -1, {}
end

function AI.killMyself()
	print("-----killMyself----")
	--AI.leaveRoom({})
end

---------------------------- AI STUB API 2 Server ---------------------------
function AI.gameLogin(msg)
	client_msg_handler("gameLogin", msg)
end

function AI.joinRoom(msg)
	client_msg_handler("joinRoom", msg)
end

function AI.rejoinRoom(msg)
	client_msg_handler("rejoinRoom", msg)
end

function AI.joinRoomOk(msg)
	client_msg_handler("joinRoomOk", msg)
end

function AI.leaveRoom(msg)
	client_msg_handler("leaveRoom", msg)
end

function AI.getReady(msg)
	AI.isReady = true
	AI.gameData = {}
	client_msg_handler("getReady", msg)
end

function AI.getReadystartGame(msg)
	client_msg_handler("getReadystartGame", msg)
end

function AI.grabLandlord(msg)
	client_msg_handler("grabLandlord", msg)
end

function AI.grabLandlord(msg)
	client_msg_handler("grabLandlord", msg)
end

function AI.playPoker(msg)
	client_msg_handler("playPoker", msg)
end

function AI.chat(msg)
	client_msg_handler("chat", msg)
end

function AI.dismissRoom(msg)
	client_msg_handler("dismissRoom", msg)
end

function AI.scoreRaceGetRoomNo(msg)
	client_msg_handler("scoreRaceGetRoomNo", msg)
end

function AI.getRedPack(msg)
	client_msg_handler("getRedPack", msg)
end

function AI.changeRoom(msg)
	client_msg_handler("changeRoom", msg)
end

function AI.handshake(msg)
	local sn = msg.sn
    client_msg_handler("handshake", {sn = sn})
end

function AI.gameLogin_ack(msg)
	if msg.errno == 1000 then
		AI.userInfo = msg.userInfo
		-- 2. get room number
		AI.scoreRaceGetRoomNo({maxPlayerNum=AI.maxPlayerNum})
	end
end

function AI.scoreRaceGetRoomNo_ack(msg)
	if msg.errno == 1000 then
		local roomNo = msg.roomNo
		-- 3. join room
		AI.joinRoom({roomNo = roomNo})
	else
		AI.killMyself()
	end
end

function AI.joinRoom_ack(msg)
	if msg.errno == 1000 then
		local waitTime = 2*AI.getWaitTime()
		AI.playerId = msg.playerId
		AI.joinRoomOk({playerId = AI.playerId})
	else
		AI.killMyself()
	end
end

function AI.joinRoomOk_ntf(msg)
	AI.userInfoList = msg.userInfoList
	if AI.isReady == nil or AI.isReady == false then
		AI.getReady({playerId = AI.playerId, status = 1})
	end
end

function AI.startGame_ntf(msg)
	AI.gameData.pokerList = msg.pokerList
	AI.gameData.bottomList = msg.bottomList
end

function AI.whoGrabLandlord_ntf(msg)
	if AI.isMe(msg.playerId) then
		test_sleep(AI.getWaitTime())
		local actionType = 1
		if AI.calcIsGrabLandlord() then
			actionType = 2
		end
		AI.grabLandlord({playerId = AI.playerId, grabAction = actionType})
	end
end

function AI.alarmTimer_ntf(msg)
	local timerType = msg.timerType
	local playerId = msg.playerId
	if timerType == "r" then
		if AI.isMe(playerId) then
			--AI.getReady({playerId = AI.playerId, status = 1})
		end
	end
end

function AI.grabLandlord_ntf(msg)
	AI.gameData.grabLevel = msg.grabLevel
end

function AI.stopAlarmTimer_ntf(msg)
end

function AI.landlord_ntf(msg)
	AI.gameData.landlord = msg.playerId
	if AI.isMe(AI.gameData.landlord) then
		for i = 1, #AI.gameData.bottomList do
			table.insert(AI.gameData.pokerList, AI.gameData.bottomList[i])
		end
		table.sort(AI.gameData.pokerList)
	end
end

function AI.whoPlay_ntf(msg)
	if AI.isMe(msg.playerId) then
		local extWaitTime = 0
		if AI.gameData.isPlay == nil and AI.isMeLandlord() then
			extWaitTime = 150
		end

		local pokerList = AI.calcPlayPoker()
		extWaitTime = #pokerList * 40 + extWaitTime
		local randomVal = math.random(50, 100)
		if extWaitTime < randomVal then
			extWaitTime = randomVal
		end
		test_sleep(extWaitTime)
		local playAction = 2
	    if pokerList == nil or #pokerList == 0 then
	        playAction = 1
	    end
	    AI.gameData.isPlay = 1
		AI.playPoker({playerId = AI.playerId, playAction = playAction, pokerList = pokerList})
	end
end

function AI.playPoker_ntf(msg)
	local playerId = msg.playerId
    local playAction = msg.playAction
    local pokerList = msg.pokerList
    if AI.gameData.prevPokerListRecord == nil then
    	AI.gameData.prevPokerListRecord = {}
    end
    AI.gameData.prevPokerListRecord[playerId] = pokerList
    if AI.isMe(playerId) and #pokerList > 0 then
    	AI.gameData.pokerList = table_remove(AI.gameData.pokerList, pokerList)
    end
end

function AI.gameResult_ntf(msg)
	AI.isGamePlaying = false
	local time = math.random(4, 8)*100
	AI.getReady({playerId = AI.playerId, status = 1})
end

function AI.restartGame_ntf(msg)
	AI.getReady({playerId = AI.playerId, status = 1})
end

function AI.roomResult_ntf(msg)
end

function AI.chat_ntf(msg)
end

function AI.leaveRoom_ntf(msg)
end

function AI.reJoinRoomOk_ack(msg)
end

function AI.dismissRoom_ntf(msg)
end

function AI.redPackStart_ack(msg)
end

function AI.redPackOver_ack(msg)
end

function AI.getRedPack_ack(msg)
end

function AI.changeRoom_ack(msg)
end

-----------------------------------------------------------------------
local function get_userid()
      local file = io.open("gameclient/userid.txt", "r")
      assert(file)
      local userIdStr = file:read("*a")
      if userIdStr == "" then userIdStr = "1" end
      local userId = tonumber(userIdStr)
      local ret = userIdStr
      local newUserIdStr = (userId+1)..""
      print(newUserIdStr)
      file:close()
      file = io.open("gameclient/userid.txt", "w")
      file:write(newUserIdStr)
      file:close()
      return ret
end
client_fd = assert(socket.connect("115.231.81.96", 8888))
--client_fd = assert(socket.connect("127.0.0.1", 8888))
test_start({version=1, userId="test_race_"..get_userid(), authCode="123456"})
while true do
	local msgname, msg = util.recvmsg(client_fd)
	if msgname and msg then
		send_client_msg(msgname, msg)
	end
end

