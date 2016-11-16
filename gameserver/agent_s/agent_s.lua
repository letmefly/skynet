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
local CLIENT_API = {}
local client_fd

-- 1 is protobuf, 2 is json
local PROTO_TYPE = 2

------------------------ controllers ----------------------------
local user = require "agent_s.user"
local game = require "agent_s.game"


------------------------ helper function ------------------------
local function send_client_msg(msgname, msg)
	if 1 == PROTO_TYPE then
		local buff, size = netutil.pbencode(msgname, msg)
		socket.write(client_fd, buff, size)
	else
		local buff, size = netutil.jsonencode(msgname, msg)
		socket.write(client_fd, buff, size)
	end
end

local function client_msg_handler(msgname, msg)
	local handler = CLIENT_API[msgname]
	if handler then
		handler(msg)
	else
		print("[agent]no msg handler for " .. msgname)
	end
end


------------------------ common client request ------------------
function CLIENT_API:get()
	print("get", self.what)
	--local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function CLIENT_API:set()
	print("set", self.what, self.value)
	--local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function CLIENT_API:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function CLIENT_API:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end


------------------------ user controller ------------------------
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


------------------------ game controller ------------------------
function CLIENT_API:game_enterlobby(msg)
end

function CLIENT_API.game_start(msg)
	local msg_ack = game:start(msg)
	send_client_msg("game_start_ack", msg_ack)
end

function CLIENT_API.game_result(msg)
	local msg_ack = game:result(msg)
	send_client_msg("game_result_ack", msg_ack)
end

function CLIENT_API.game_lobby(msg)
	local msg_ack = game:result(msg)
	send_client_msg("game_lobby_ack", msg_ack)
end

function CLIENT_API.game_missions(msg)
	local msg_ack = game:missions(msg)
	send_client_msg("game_missions_ack", msg_ack)
end

-- function CLIENT_API.game_get_ranking(msg)
-- end

-- function CLIENT_API.game_get_achievements(msg)
-- end

-- function CLIENT_API.game_set_achievement(msg)
-- end

-- function CLIENT_API.game_get_achievement_info(msg)
-- end

-- function CLIENT_API.game_get_userdetail(msg)
-- end

-- function CLIENT_API.game_unlock_achievement(msg)
-- end

-- function CLIENT_API.game_tutorial(msg)
-- end


------------------------ shop controller ------------------------
function CLIENT_API.shop_pay_item(msg)
end

function CLIENT_API.shop_buy_item(msg)
end

function CLIENT_API.shop_buy_character(msg)
end

function CLIENT_API.shop_buy_skill(msg)
end

function CLIENT_API.shop_buy_treasure(msg)
end

function CLIENT_API.shop_sell_treasure(msg)
end

function CLIENT_API.shop_buy_skillslot(msg)
end

function CLIENT_API.shop_buy_treasureslot(msg)
end

function CLIENT_API.shop_buy_treasure_inventory(msg)
end

function CLIENT_API.shop_buy_instant_item(msg)
end

function CLIENT_API.shop_get_lottery(msg)
end


------------------------ shop controller ------------------------
function CLIENT_API.friend_get_friends(msg)
end

function CLIENT_API.friend_get_suggest_friends(msg)
end

function CLIENT_API.friend_find(msg)
end

function CLIENT_API.friend_add(msg)
end

function CLIENT_API.friend_accept(msg)
end

function CLIENT_API.friend_remove(msg)
end

function CLIENT_API.friend_send_gift(msg)
end

function CLIENT_API.friend_get_invitations(msg)
end

function CLIENT_API.friend_invite(msg)
end


------------------------ register client dispatch -----------------
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (data, sz)
		print("fuck!!!! sz:"..sz)
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

	-- skynet.fork(function()
	-- 	while true do
	-- 		send_package(send_request "heartbeat")
	-- 		skynet.sleep(500)
	-- 	end
	-- end)
end

function SERVICE_API.has_new_mail(mail)
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

