local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local SERVICE_API = {}
local room_seq = 100000
local rooms = {} 
local total_room = 0


function SERVICE_API.createRoom(roomType)
	room_seq = room_seq + 1
	if (room_seq > 900000) then
		room_seq = 100000
	end
	local roomNo = room_seq .. ""
	local sid = skynet.newservice("room_s")
	skynet.call(sid, "lua", "init", {roomNo = roomNo, grabMode = 1})
	rooms[roomNo] = sid
	total_room = total_room + 1
	return {sid = sid, roomNo = roomNo}
end

function SERVICE_API.queryRoom(roomNo)
	return rooms[roomNo]
end

function SERVICE_API.totalRoom()
	return total_room
end

function SERVICE_API.destroyRoom(roomNo)
	if nil ~= rooms[roomNo] then
		total_room = total_room - 1
		skynet.kill(rooms[roomNo])
	end
	rooms[roomNo] = nil
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = SERVICE_API[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register("roomManager_s")
end)
