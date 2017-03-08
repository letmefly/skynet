local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local this = {}
local SERVICE_API = {}
local room_seq = 100000
local rooms = {} 
local total_room = 0

this.scoreRace_rooms = {}
this.scoreRace_roomseq = 600000

function this.scoreRace_findPrevRoom(userId)
	for k, v in pairs(this.scoreRace_rooms) do
		if v then
			local roomNo = k
			local sid = v
			local ret = skynet.call(sid, "lua", "findByUserId", userId)
			if ret == 1 then
				return roomNo, sid
			end
		end
	end 
	return -1, -1	
end

function this.scoreRace_findRoom(maxPlayerNum, excludeRoomNo)
	for k, v in pairs(this.scoreRace_rooms) do
		if v then
			local roomNo = k
			local sid = v 
			local playerNum = skynet.call(sid, "lua", "getCurrPlayerNum", {})
			if playerNum < maxPlayerNum and excludeRoomNo ~= roomNo then
				return roomNo, sid
			end
		end
	end
	return -1,-1
end

function this.scoreRace_createRoom(roomType)
	local roomType = roomType
	local playTimes = 9999
	local grabMode = 1
	local maxBoom = 2

	this.scoreRace_roomseq = this.scoreRace_roomseq + 1
	if (this.scoreRace_roomseq > 799998) then
		this.scoreRace_roomseq = 600000
	end
	local roomNo = this.scoreRace_roomseq .. ""
	local sid = skynet.newservice("room_s")
	skynet.call(sid, "lua", "init", {
		roomNo = roomNo, 
		roomType =roomType,
		playTimes = playTimes,
		grabMode = grabMode,
		maxBoom = maxBoom
	})
	this.scoreRace_rooms[roomNo] = sid
	return roomNo, sid 
end

function SERVICE_API.createRoom(msg)
	local roomType = msg.roomType
	local playTimes = msg.playTimes
	local grabMode = msg.grabMode
	local maxBoom = msg.maxBoom

	room_seq = room_seq + 1
	if (room_seq > 299998) then
		room_seq = 100001
	end
	local roomNo = room_seq .. ""
	local sid = skynet.newservice("room_s")
	skynet.call(sid, "lua", "init", {
		roomNo = roomNo, 
		roomType =roomType,
		playTimes = playTimes,
		grabMode = grabMode,
		maxBoom = maxBoom
	})
	rooms[roomNo] = sid
	total_room = total_room + 1
	return {sid = sid, roomNo = roomNo}
end

function SERVICE_API.queryRoom(roomNo)
	local sid = rooms[roomNo]
	if sid == nil then
		sid = this.scoreRace_rooms[roomNo]
	end
	return sid
end

function SERVICE_API.totalRoom()
	return total_room
end

function SERVICE_API.destroyRoom(roomNo)
	print("[roomManager_s]destroy roomNo "..roomNo)	
	if nil ~= rooms[roomNo] then
		total_room = total_room - 1
		skynet.kill(rooms[roomNo])
		rooms[roomNo] = nil
	elseif nil ~= this.scoreRace_rooms[roomNo] then
		skynet.kill(this.scoreRace_rooms[roomNo])
		this.scoreRace_rooms[roomNo] = nil
	end
end

function SERVICE_API.scoreRaceGetRoomNo(msg)
	local maxPlayerNum = msg.maxPlayerNum
	local excludeRoomNo = msg.excludeRoomNo
	local userId = msg.userId
	--print("------flll-excludeRoomNo--"..excludeRoomNo)
	local roomNo, sid = this.scoreRace_findPrevRoom(userId)
	if roomNo ~= -1 then
		return {roomNo = roomNo, sid = sid}
	end
	roomNo, sid = this.scoreRace_findRoom(maxPlayerNum, excludeRoomNo)
	if roomNo == -1 or sid == -1 then
		roomNo, sid =  this.scoreRace_createRoom(maxPlayerNum)
	end
	return {roomNo = roomNo, sid = sid}
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
