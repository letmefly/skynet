local skynet = require "skynet"
local nothing = require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local netutil = require "agent_s.netutil"
local cjson = require "cjson"

local WATCHDOG
local host
local send_request

local SERVICE_API = {}
local CLIENT_REQ = {}
local client_fd

-- 1 is protobuf, 2 is json
local PROTO_TYPE = 1

local my_room_sid = -1
local room_playerId = -1
local user_info = {}


------------------------ helper function ------------------------
local function send_client_msg(msgname, msg)
	print(msgname..": "..cjson.encode(msg))
	if 1 == PROTO_TYPE then
		local buff, size = netutil.pbencode(msgname, msg)
		socket.write(client_fd, buff, size)
	else
		local buff, size = netutil.jsonencode(msgname, msg)
		socket.write(client_fd, buff, size)
	end
end

local function client_msg_handler(msgname, msg)
	print(msgname..": "..cjson.encode(msg))
	local handler = CLIENT_REQ[msgname]
	if handler then
		handler(msg)
	else
		print("[agent]no msg handler for " .. msgname)
	end
end

------------------------ client request -------------------------
function CLIENT_REQ.handshake(msg)
	--skynet.error("handshake-"..msg.sn)
	send_client_msg("handshake", {sn = msg.sn})
end

function CLIENT_REQ.quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

function CLIENT_REQ.gameLogin(msg)
	local userId = msg.userId
	local authCode = msg.authCode
	local version = msg.version
	user_info.userId = "chris123"
	user_info.nickname = "chris"
	user_info.sexType = 1
	user_info.iconUrl = "http://"
	user_info.level = 1
	user_info.roomCardNum = 100
	user_info.playerId = 0
	-- verify user auth
	send_client_msg("gameLogin_ack", {errno = 1000, userInfo = user_info})
end

function CLIENT_REQ.createRoom(msg)
	-- first check if there is room card
	local roomType = msg.roomType
	local ret = skynet.call("roomManager_s", "lua", "createRoom", roomType)
	my_room_sid = ret.sid
	local roomNo = ret.roomNo
	send_client_msg("createRoom_ack", {errno = 1000, roomNo = roomNo})
end

function CLIENT_REQ.joinRoom(msg)
	local errno = -1
	local roomNo = msg.roomNo
	my_room_sid = skynet.call("roomManager_s", "lua", "queryRoom", roomNo)
	if my_room_sid ~= nil then
		errno = 1000
		room_playerId = skynet.call(my_room_sid, "lua", "joinRoom", {sid = skynet.self(), userInfo = user_info})
	end
	send_client_msg("joinRoom_ack", {errno = errno, playerId = room_playerId})
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
end

function CLIENT_REQ.leaveRoom(msg)
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
end

function SERVICE_API.disconnect()
	-- todo: do something before exit
	--skynet.call(my_room_sid, "lua", "leave", room_playerId)
	skynet.exit()
end

function SERVICE_API.sendClient(msgname, msg)
	send_client_msg(msgname, msg)
end


------------------------ service start! -----------------------------
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)