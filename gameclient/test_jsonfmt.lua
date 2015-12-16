package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"
local util = require "util"
local socket = require "clientsocket"

local fd = assert(socket.connect("127.0.0.1", 8888))

util.sendmsg2(fd, "user_login", {email = "chris.li@sky-mobi.com", password = "123456"})
local login_ack = util.recvmsg2(fd)

-- game start
if 0 == login_ack.errno then
util.sendmsg2(fd, "game_start", {userID=login_ack.userID, stageID=1, friendUserID=0, useItems={1,2,3}})
local game_start_ack = util.recvmsg2(fd)

-- game result
if 0 == game_start_ack.errno then
util.sendmsg2(fd, "game_result", {
	userID=login_ack.userID, 
	gainExp=1000, 
	gainMoney=888, 
	score=100, 
	maxCombo=2, 
	isClear=0, 
	isPerfect=1, 
	killCount= 10
})
local game_result_ack = util.recvmsg2(fd)


end
end

