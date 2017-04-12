local skynet = require "skynet"
local nothing = require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local netutil = require "agent_s.netutil"
local httpc = require "http.httpc"
local dns = require "dns"
local cjson = require "cjson"
local pokerUtil = require "room_s.pokerUtil"

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
local http_server_addr = "127.0.0.1:80"
local doc_root_dir = "/php_01/html/v0/"


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
	local handler = CLIENT_REQ[msgname]
	if handler then
		handler(msg)
	else
		print("[agent]no msg handler for " .. msgname)
	end
end

local function on_client_disconnect()
	-- todo: do something before exit
	if my_room_sid then
		skynet.call(my_room_sid, "lua", "disconnect", room_playerId)
	end
	skynet.exit()
end

---------------------------- AI Functions ---------------------------
function AI.getAllPlayerPokerList()
	return skynet.call(my_room_sid, "lua", "ai_getAllPokerList", {})
end
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
		local next1Info = {}
		local next2Info = {}
		local next1PlayerId = AI.getNextPlayer(AI.playerId)
		local next2PlayerId = AI.getNextPlayer(next1PlayerId)
		next1Info.isFriend = AI.isFriend(next1PlayerId)
		next2Info.isFriend = AI.isFriend(next2PlayerId)
		next1Info.pokerList = AI.gameData.allPlayerPokerList[next1PlayerId].pokerList
		next2Info.pokerList = AI.gameData.allPlayerPokerList[next2PlayerId].pokerList
		if next1Info.isFriend == true and next2Info.isFriend == false then
			if AI.gameData.allPlayerPokerList[next1PlayerId].userType == 1 and
				AI.gameData.allPlayerPokerList[next2PlayerId].userType == 2 then
				next1Info = nil
				next2Info = nil
				--isFriendPlay = false
			end
		elseif next1Info.isFriend == false and next2Info.isFriend == true then
			if AI.gameData.allPlayerPokerList[next1PlayerId].userType == 2 and
				AI.gameData.allPlayerPokerList[next2PlayerId].userType == 1 then
				next1Info = nil
				next2Info = nil
				--isFriendPlay = false
			end
		end

		ret = pokerUtil.ai_getPlayPoker(AI.gameData.pokerList, prevPokerList, isFriendPlay, next1Info, next2Info)
		--print("1. "..cjson.encode(next1Info))
		--print("2. "..cjson.encode(next2Info))
		--print("3. "..cjson.encode(ret))
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
	print("---killMyself---"..user_info.userId)
	local ret = skynet.call("aiManager_s", "lua", "releaseAIUser", user_info.userId)
	AI.leaveRoom({})
	skynet.timeout(50, function() skynet.exit() end)
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
	--client_msg_handler("leaveRoom", msg)
	skynet.call(my_room_sid, "lua", "leave", room_playerId, 3)
end

function AI.getReady(msg)
	AI.isReady = true
	AI.gameData = {}
	client_msg_handler("getReady", msg)
	skynet.timeout(20*100, function()
		if AI.gameData.pokerList == nil then
			AI.killMyself()
		end
	end)
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
end

function AI.gameLogin_ack(msg)
	if msg.errno == 1000 then
		AI.isLogin = true
		AI.userInfo = msg.userInfo
		-- 2. get room number
		AI.scoreRaceGetRoomNo({maxPlayerNum=AI.maxPlayerNum})
	else
		AI.killMyself()
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
		skynet.timeout(0, function()
			AI.playerId = msg.playerId
			AI.joinRoomOk({playerId = AI.playerId})
		end)
	else
		AI.killMyself()
	end
end

function AI.joinRoomOk_ntf(msg)
	AI.userInfoList = msg.userInfoList
	if AI.isReady == nil or AI.isReady == false then
		skynet.timeout(100, function()
			AI.getReady({playerId = AI.playerId, status = 1})
		end)
	end
end

function AI.startGame_ntf(msg)
	AI.gameData.pokerList = msg.pokerList
	AI.gameData.bottomList = msg.bottomList
	AI.gameData.allPlayerPokerList = AI.getAllPlayerPokerList()
end

function AI.whoGrabLandlord_ntf(msg)
	if AI.isMe(msg.playerId) then
		skynet.timeout(AI.getWaitTime(), function()
			local actionType = 1
			if AI.calcIsGrabLandlord() then
				actionType = 2
			end
			AI.grabLandlord({playerId = AI.playerId, grabAction = actionType})
		end)
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
		skynet.timeout(extWaitTime, function()
			local playAction = 2
		    if pokerList == nil or #pokerList == 0 then
		        playAction = 1
		    end
		    AI.gameData.isPlay = 1
			AI.playPoker({playerId = AI.playerId, playAction = playAction, pokerList = pokerList})
		end)
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
    if #pokerList > 0 then
    	AI.gameData.allPlayerPokerList[playerId].pokerList = table_remove(AI.gameData.allPlayerPokerList[playerId].pokerList, pokerList)
	end
end

function AI.gameResult_ntf(msg)
	AI.isGamePlaying = false
	local time = math.random(4, 8)*100
	skynet.timeout(time, function()
		AI.killMyself()
	end)
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


------------------------ client request -------------------------
function CLIENT_REQ.handshake(msg)
	--skynet.error("handshake-"..msg.sn)
	--send_client_msg("handshake", {sn = msg.sn})
end

function CLIENT_REQ.clientHandshake(msg)
	send_client_msg("clientHandshake", {sn = msg.sn})
end

function CLIENT_REQ.quit()
	--skynet.call(WATCHDOG, "lua", "close", client_fd)
end

function CLIENT_REQ.gameLogin(msg)
	local userId = msg.userId
	local authCode = msg.authCode
	local version = msg.version

	local status, body = httpc.post2(http_server_addr, doc_root_dir.."service_getUser.php", cjson.encode({unionid=userId}))
	local userData = cjson.decode(body)
	user_info.userId = userData['unionid']
	user_info.nickname = userData['nickname']
	user_info.sexType = userData['sex']
	user_info.iconUrl = userData['headimgurl']
	user_info.level = userData['level']
	user_info.roomCardNum = userData['roomCardNum']
	user_info.playerId = 0
	user_info.win = userData['win']
	user_info.lose = userData['lose']
	user_info.score = userData['score']
	user_info.ip = math.random(1,999999)..""
	user_info.userno = userData['userno']
	user_info.redPackVal = userData['redPackVal']
	-- verify user auth
	send_client_msg("gameLogin_ack", {errno = 1000, userInfo = user_info})
end

function CLIENT_REQ.createRoom(msg)
	-- first check if there is room card
	local roomType = msg.roomType
	local playTimes = msg.playTimes
	local grabMode = msg.grabMode
	local maxBoom = msg.maxBoom
	if playTimes == 6 or playTimes == 1 then
		if user_info.roomCardNum > 2 then
			--user_info.roomCardNum = user_info.roomCardNum - 2
		else
			send_client_msg("createRoom_ack", {errno = 1007, roomNo = 0})
			return
		end
	elseif playTimes == 12 or playTimes == 2 then
		if user_info.roomCardNum > 3 then
			--user_info.roomCardNum = user_info.roomCardNum - 3
		else
			send_client_msg("createRoom_ack", {errno = 1007, roomNo = 0})
			return
		end
	else
		send_client_msg("createRoom_ack", {errno = 1007, roomNo = 0})
		return
	end

	local ret = skynet.call("roomManager_s", "lua", "createRoom", {
		roomType = roomType,
		playTimes = playTimes,
		grabMode = grabMode,
		maxBoom = maxBoom
	})
	my_room_sid = ret.sid
	local roomNo = ret.roomNo
	send_client_msg("createRoom_ack", {errno = 1000, roomNo = roomNo})
end

function CLIENT_REQ.joinRoom(msg)
	local errno = -1
	local roomNo = msg.roomNo
	local maxPlayTimes = 6
	local grabMode = 1
	local roomType = 3
	local maxBoom = 3
	my_room_sid = skynet.call("roomManager_s", "lua", "queryRoom", roomNo)
	if my_room_sid ~= nil then
		errno = 1000
		local ret = skynet.call(my_room_sid, "lua", "joinRoom", {sid = skynet.self(), userInfo = user_info, userType = 2})
		if ret.errno == -1 then
			errno = 1009
		else
			room_playerId = ret.playerId
			maxPlayTimes = ret.maxPlayTimes
			grabMode = ret.grabMode
			roomType = ret.roomType
			maxBoom = ret.maxBoom

			my_room_no = roomNo
			my_room_type = roomType
			my_room_maxplaytimes = maxPlayTimes
		end
	end
	send_client_msg("joinRoom_ack", {
		errno = errno, 
		playerId = room_playerId, 
		maxPlayTimes = maxPlayTimes, 
		currPlayTimes = 0, 
		grabMode = grabMode,
		roomType = roomType,
		maxBoom = maxBoom
	})
end

function CLIENT_REQ.joinRoomOk(msg)
	local playerId = msg.playerId
	skynet.call(my_room_sid, "lua", "joinRoomOk", {playerId = playerId})
end

function CLIENT_REQ.getReady(msg)
	local status = msg.status
	skynet.call(my_room_sid, "lua", "getReady", room_playerId)
end

function CLIENT_REQ.startGame(msg)
	local playerId = msg.playerId
	skynet.call(my_room_sid, "lua", "startGame", room_playerId)
end

function CLIENT_REQ.grabLandlord(msg)
	local playerId = room_playerId
	local grabAction = msg.grabAction
	skynet.call(my_room_sid, "lua", "grabLandlord", {playerId = playerId, grabAction = grabAction})
end

function CLIENT_REQ.playPoker(msg)
	local playerId = msg.playerId
	local playAction = msg.playAction
	local pokerList = msg.pokerList
	skynet.call(my_room_sid, "lua", "playPoker", {playerId = playerId, playAction =playAction, pokerList=pokerList})
end

function CLIENT_REQ.chat(msg)
	local playerId = msg.playerId
	local t = msg.t
	local v = msg.v
	skynet.call(my_room_sid, "lua", "chat", {playerId = playerId, t = t, v = v})
end

function CLIENT_REQ.leaveRoom(msg)
	skynet.call(my_room_sid, "lua", "leave", room_playerId, 3)	
	---on_client_disconnect()
end

function CLIENT_REQ.dismissRoom(msg)
	skynet.call(my_room_sid, "lua", "dismissRoom", msg)
end

function CLIENT_REQ.rejoinRoom(msg)
	local errno = -1
	my_room_sid = skynet.call("roomManager_s", "lua", "queryRoom", msg.roomNo)
	if my_room_sid ~= nil then
		errno = 1000
		skynet.call(my_room_sid, "lua", "rejoin", {playerId=msg.playerId, sid=skynet.self()})
	end
	send_client_msg("rejoinRoom_ack", {errno = 1000})
end

function CLIENT_REQ.scoreRaceGetRoomNo(msg)
	local maxPlayerNum = msg.maxPlayerNum
	local errno = 1000
	if user_info.score < 24 then
		send_client_msg("scoreRaceGetRoomNo_ack", {errno = 1001, roomNo = -1})
		return
	end
	local ret = skynet.call("roomManager_s", "lua", "scoreRaceGetRoomNo", {maxPlayerNum=maxPlayerNum, excludeRoomNo=my_room_no})
	local roomNo = ret.roomNo
	send_client_msg("scoreRaceGetRoomNo_ack", {errno = errno, roomNo = roomNo})
end

function CLIENT_REQ.getRedPack(msg)
	local playerId = msg.playerId
	if my_room_sid ~= nil then
		skynet.call(my_room_sid, "lua", "getRedPack", {playerId = playerId})
	end
end

function CLIENT_REQ.changeRoom(msg)
	local playerId = msg.playerId
	local maxPlayerNum = msg.maxPlayerNum
	if user_info.score < 24 then
		send_client_msg("changeRoom_ack", {errno = 1001, roomNo = -1})
		return
	end
	local ret = skynet.call("roomManager_s", "lua", "scoreRaceGetRoomNo", {maxPlayerNum=maxPlayerNum, excludeRoomNo=my_room_no})
	local roomNo = ret.roomNo
	send_client_msg("changeRoom_ack", {errno = 1000, roomNo = roomNo})	

	skynet.call(my_room_sid, "lua", "leave", room_playerId, 2)	
end

------------------------ service API -------------------------------
function SERVICE_API.start(conf)
	local version = conf.version
	local userId =  conf.userId
	local authCode = conf.authCode
	--print("Now create AI for "..userId)
	AI.gameLogin({version = version, userId = userId, authCode = authCode})
	skynet.timeout(20*100, function()
		if AI.isLogin == nil then
			AI.killMyself()
		end
	end)
end

function SERVICE_API.disconnect()
	on_client_disconnect()
end

function SERVICE_API.sendClient(msgname, msg)
	send_client_msg(msgname, msg)
end

function SERVICE_API.saveGameResult(msg)
	local roomResultList = msg
	local postData = {}
	postData.userData = {}
	postData.roomResult = {}
	postData.roomResult.roomNo = my_room_no
	postData.roomResult.roomType = my_room_type
	postData.roomResult.history = {}

	local isAllZero = true
	for k, v in pairs(roomResultList) do
		if v.totalScore ~= 0 then
			isAllZero = false
		end
		if v.playerId == room_playerId then
			postData.userData.unionid = user_info.userId
			if v.totalScore >= 0 then
				postData.userData.win = user_info.win + 1
			else 
				postData.userData.lose = user_info.lose + 1
			end
			postData.userData.score = user_info.score + v.totalScore
		end
		table.insert(postData.roomResult.history, {n=v.nickname, s=v.totalScore})
	end
	if isAllZero == false then
		local status, body = httpc.post2(http_server_addr, doc_root_dir.."service_updateUser.php", cjson.encode(postData))
	end
end

function SERVICE_API.costRoomCard(msg)
	local costRoomCardNum = msg.costRoomCardNum
	local postData = {}
	local userData = {}
	userData.unionid = user_info.userId
	userData.roomCardNum = user_info.roomCardNum - costRoomCardNum
	postData.userData = userData
	local status, body = httpc.post2(http_server_addr, doc_root_dir.."service_updateUser.php", cjson.encode(postData))
end

function SERVICE_API.getRedPack_ack(msg)
	local result = msg.result
	local redPackVal = msg.redPackVal
	if result == 2 then
		local postData = {}
		local userData = {}
		userData.unionid = user_info.userId
		userData.redPackVal = user_info.redPackVal + redPackVal
		postData.userData = userData
		local status, body = httpc.post2(http_server_addr, doc_root_dir.."service_updateUser.php", cjson.encode(postData))
	end
	send_client_msg("getRedPack_ack", {result = result, redPackVal = redPackVal})
end

------------------------ service start! -----------------------------
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)


