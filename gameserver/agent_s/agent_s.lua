local skynet = require "skynet"
local nothing = require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local netutil = require "agent_s.netutil"
local httpc = require "http.httpc"
local dns = require "dns"
local cjson = require "cjson"

local WATCHDOG
local host
local send_request

local SERVICE_API = {}
local CLIENT_REQ = {}
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
		--print(msgname..": "..cjson.encode(msg))
	end
	if 1 == PROTO_TYPE then
		local buff, size = netutil.pbencode(msgname, msg)
		socket.write(client_fd, buff, size)
	else
		local buff, size = netutil.jsonencode(msgname, msg)
		socket.write(client_fd, buff, size)
	end
end
 
local function client_msg_handler(msgname, msg)
	client_is_alive = true
	if msgname ~= "alarmTimer_ntf" and msgname ~= "clientHandshake" and msgname ~= "handshake"then
		--print(msgname..": "..cjson.encode(msg))
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
	if skynet.queryservice(true, my_room_sid) then
		skynet.call(my_room_sid, "lua", "disconnect", room_playerId)
	end
	skynet.exit()
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
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

function CLIENT_REQ.gameLogin(msg)
	local onlineUserNum = msg.onlineUserNum
	local userId = msg.userId
	local authCode = msg.authCode
	local version = msg.version
	if string.sub(userId, 1, 10) == "test_race_" then
		userId = "test_race_"..onlineUserNum
	end
	local status, body = netutil.http_post("service_getUser.php", {unionid=userId})
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
	user_info.ip = userData['ip']
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
	local isFree = msg.isFree
	if playTimes == 6 or playTimes == 1 then
		if user_info.roomCardNum > 2 or isFree == 1 then
			--user_info.roomCardNum = user_info.roomCardNum - 2
		else
			send_client_msg("createRoom_ack", {errno = 1007, roomNo = 0})
			return
		end
	elseif playTimes == 12 or playTimes == 2 or isFree == 1 then
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
		local ret = skynet.call(my_room_sid, "lua", "joinRoom", {sid = skynet.self(), userInfo = user_info, userType = 1})
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
	local ret = skynet.call("roomManager_s", "lua", "scoreRaceGetRoomNo", {userId = user_info.userId, maxPlayerNum=maxPlayerNum, excludeRoomNo=my_room_no})
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

------------------------ register client dispatch -----------------
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (data, sz)
		if sz == 0 then return end
		if 1 == PROTO_TYPE then
			local msgname, msg = netutil.pbdecode(data, sz)
			return msgname, msg
		else
			local msgname, msg = netutil.jsondecode(data, sz)
			return msgname, msg			
		end
	end,
	dispatch = function (_, _, msgname, ...)
		client_msg_handler(msgname, ...)
	end
}


------------------------ service API -------------------------------
function SERVICE_API.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
	skynet.fork(function()
		local sn = 0
		while true do
			skynet.sleep(10*100)
			if client_is_alive == false then
				--print("clinet handshake timeout, now disconnect")
				on_client_disconnect()
			end
			sn = sn + 1
			client_is_alive = false
			send_client_msg("handshake",{sn=sn})
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
		local status, body = netutil.http_post("service_updateUser.php", postData)
	end
end

function SERVICE_API.costRoomCard(msg)
	local costRoomCardNum = msg.costRoomCardNum
	local postData = {}
	local userData = {}
	userData.unionid = user_info.userId
	userData.roomCardNum = user_info.roomCardNum - costRoomCardNum
	postData.userData = userData
	local status, body = netutil.http_post("service_updateUser.php", postData)
end

function SERVICE_API.getRedPack_ack(msg)
	local result = msg.result
	local redPackVal = msg.redPackVal
	if result == 2 and (redPackVal == 40 or redPackVal == 80 or redPackVal == 120) then
		local postData = {}
		local userData = {}
		userData.unionid = user_info.userId
		userData.redPackVal = user_info.redPackVal + redPackVal
		postData.userData = userData
		local status, body = netutil.http_post("service_updateUser.php", postData)
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