package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"
local util = require "util"
local socket = require "clientsocket"

local fd = assert(socket.connect("127.0.0.1", 8888))
--util.reg("gameLogin_ack", function(msg) end)

util.sendmsg(fd, "gameLogin", {userId = "13343461428", authCode = "123456", version = 1})

while true do
	local msgname, msg = util.recvmsg(fd)
	if msgname == "gameLogin_ack" then
		util.sendmsg(fd, "createRoom", {roomType = 1})
	elseif msgname == "createRoom_ack" then
		util.sendmsg(fd, "joinRoom", {roomNo = msg.roomNo})
	elseif msgname == "joinRoom_ack" then
		util.sendmsg(fd, "getReady", {status = 1})
	elseif msgname == "getReady_ntf" then
	elseif msgname == "whoGrabLandlord_ntf" then
		util.sendmsg(fd, "grabLandlord", {grabAction = 2})
	end
end

