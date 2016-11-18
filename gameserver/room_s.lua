local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local SAPI = {}
local room_no = nil
local max_player_num = 3
local curr_player_num = 0
local player_info_list = {}


function SAPI.init(conf)
	room_no = conf.roomNo
end

function SAPI.join(playerInfo)
	curr_player_num = curr_player_num + 1
	player_info_list[curr_player_num] = {
		agentsid = playerInfo.agent,
		id = curr_player_num,
	}
	return {errno = 0}
end

function SAPI.leave(playerId)
	local playerInfo = player_info_list[playerId]
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = SAPI[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	--skynet.register("roomManager_s")
end)