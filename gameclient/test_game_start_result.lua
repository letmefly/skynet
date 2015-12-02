package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"
local util = require "util"
local socket = require "clientsocket"

local fd = assert(socket.connect("127.0.0.1", 8888))

util.sendmsg(fd, "user_login", {email = "chris.li@sky-mobi.com", password = "123456"})
local login_ack = util.recvmsg(fd)
if 0 == login_ack.errno then
	util.sendmsg(fd, "game_start", {userID=login_ack.userID, stageID=1, friendUserID=0, useItems={1,2,3}})
	local game_start_ack = util.recvmsg(fd)
end

