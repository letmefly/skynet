local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
-- local sproto = require "sproto"
-- local sprotoloader = require "sprotoloader"
local netutil = require "netutil"


local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

function REQUEST:get()
	print("get", self.what)
	--local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	--local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function msg_handler(msgname, msg)
	print (msgname .. ": sn = " .. msg.sn)
	return msg.sn
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (data, sz)
		local msgname, msg = netutil.pbdecode(data, sz)
		return msgname, msg
	end,
	dispatch = function (_, _, msgname, ...)
		local sn = msg_handler(msgname, ...)
		local buff, size = netutil.pbencode("handshake", {sn = sn})
		for i = 1, 100 do
			local buff, size = netutil.pbencode("handshake", {sn = sn})
			socket.write(client_fd, buff, size)
		end
		
		-- if type == "REQUEST" then
		-- 	local ok, result  = pcall(request, ...)
		-- 	if ok then
		-- 		if result then
		-- 			send_package(result)
		-- 		end
		-- 	else
		-- 		skynet.error(result)
		-- 	end
		-- else
		-- 	assert(type == "RESPONSE")
		-- 	error "This example doesn't support request client"
		-- end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog

	-- skynet.fork(function()
	-- 	while true do
	-- 		send_package(send_request "heartbeat")
	-- 		skynet.sleep(500)
	-- 	end
	-- end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)

