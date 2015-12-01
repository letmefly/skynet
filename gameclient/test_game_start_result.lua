package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local netutil = require "netutil"
local fd = assert(socket.connect("127.0.0.1", 8888))
local cjson = require "cjson"

local function sendmsg(msgname, msg)
	local msgdata, size = netutil.pbencode(msgname, msg)
	socket.send(fd, msgdata, size)
end

local function recvmsg()
	while true do
		local buff, size = socket.recv(fd)
		if size and size > 0 then
			-- print ("msg size:" .. size)
			local msgname, msg = netutil.pbdecode(buff, size)
			-- print(msgname .. ":" .. msg.errno)
			print(msgname..":"..cjson.encode(msg))
			return msg
		else
			socket.usleep(100)
		end
	end
end

-- test hand shake
-- sendmsg("user_register", {email = "chris.li@sky-mobi.com", password = "123456"})
sendmsg("user_login", {email = "chris.li@sky-mobi.com", password = "123456"})
local login_ack = recvmsg()
if 0 == login_ack.errno then
	sendmsg("game_start", {userID=login_ack.userID, stageID=1, friendUserID=0, useItems={1,2,3}})
	local game_start_ack = recvmsg()
end

