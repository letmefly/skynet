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

------------------------ controllers ----------------------------
--local user = require "agent_s.user"
--local game = require "agent_s.game"


------------------------ helper function ------------------------
local function send_client_msg(msgname, msg)
	if 1 == PROTO_TYPE then
		local buff, size = netutil.pbencode(msgname, msg)
		print(size)
		socket.write(client_fd, buff, size)
	else
		local buff, size = netutil.jsonencode(msgname, msg)
		socket.write(client_fd, buff, size)
	end
end

local function client_msg_handler(msgname, msg)
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
end

function CLIENT_REQ.createRoom(msg)
end

function CLIENT_REQ.joinRoom(msg)
end

function CLIENT_REQ.leaveRoom(msg)
end

function CLIENT_REQ.ready(msg)
end

function CLIENT_REQ.grabLandlord(msg)
end

function CLIENT_REQ.playPokeInfo(msg)
end

function CLIENT_REQ.chat(msg)
end


--[[
function CLIENT_API.user_check_version(msg)
	local msg_ack = {version=1, packageURL="xxx", maintenanceTime=0}
	send_client_msg("user_check_version", msg_ack)
end

function CLIENT_API.user_register(msg)
	local msg_ack = user:register(msg)
	send_client_msg("user_register_ack", msg_ack)
end

function CLIENT_API.user_login(msg)
	local msg_ack = user:login(msg)
	send_client_msg("user_login_ack", msg_ack)
	if msg_ack["errno"] == 0 then
		print("skyent register agent:".."agent_"..tostring(msg_ack["userID"]))
		skynet.register("agent_"..tostring(msg_ack["userID"]))
	end
end

function CLIENT_API.user_change_nickname(msg)
	local msg_ack = user:change_nickname(msg)
	send_client_msg("user_change_nickname_ack", msg_ack)
end
]]

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
	skynet.exit()
end

function SERVICE_API.send_client(msgname, msg)
	send_client_msg(msgname, msg)
end


------------------------ service start! -----------------------------
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
