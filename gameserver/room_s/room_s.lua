local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local SERVICE_API = {}
local timer_callback_list = {}
local player_info_list = {}
local room_no = nil
local max_player_num = 3
local grab_landlord_mode = 1 --1 random mode, 2 score mode
local curr_player_num = 0

-- game state data
local last_poker = {}
local curr_who_grab = 1
local grab_times = 0
local curr_who_play = 1
local curr_landlord = 0
local curr_grab_level = 0

local function send_all_player(msgname, msg)
	for k, v in ipairs(player_info_list) do
		local sid = v.sid
		skynet.send(sid, "lua", "send_client", msgname, msg)
	end
end

local function send_player(sid, msgname, msg)
	skynet.send(sid, "lua", "send_client", msgname, msg)
end

local function set_timer(name, time, callback)
	timer_callback_list[name] = callback
	skynet.timeout(time, function()
		local callback = timer_callback_list[name]
		if nil ~= callback then
			callback()
			timer_callback_list[name] = nil
		end
	end)
end

local function unset_timer(name)
	if nil ~= timer_callback_list[name] then
		timer_callback_list[name] = nil
	end
end

-- send 17 poker to all player
local function start_play_poker()
	local pokerSet = {
		103,104,105,106,107,108,109,110,111,112,113,114,115, -- heart
		203,204,205,206,207,208,209,210,211,212,213,214,215, -- diamod
		303,304,305,306,307,308,309,310,311,312,313,314,315, -- club
		403,404,405,406,407,408,409,410,411,412,413,414,415, -- spade
		516,517												 -- small joker and big joker
	}
	--local allPokerList = {}
	for k, v in ipairs(player_info_list) do
		local sid = v.sid
		local pokerList = {}
		-- random choose poker
		for i=1, 17 do
			local random = math.random(#pokerSet)
			table.insert(pokerList, pokerSet[random])
			table.remove(pokerSet, random)
		end
		--table.insert(allPokerList, pokerList)
		send_player(sid, "start_ntf", {pokerList = pokerList})
	end
	for i = 1, 3 do
		last_poker[i] = pokerSet[i]
	end

	-- notify who grab landlord after 2s
	skynet.timeout(200, grab_landlord)
end

local function get_next_player(playerId)
	return (playerId + 1) % 3 + 1
end

local function grab_landlord()
	send_all_player("whoGrabLandlord_ntf", {playerId = curr_who_grab})
	set_timer("play_timer", 1500, function()
		grab_landlord_handler(curr_who_grab, 0)
	end)
end

local function grab_landlord_over(playerId)
	send_all_player("landlord_ntf", {playerId = playerId})
	curr_who_play = playerId
	skynet.timeout(10, play_poker)
end

local function grab_landlord_handler(playerId, grabAction)
	unset_timer("play_timer")
	grab_times = grab_times + 1

	if grabAction > curr_grab_level then
		curr_grab_level = grabAction
		curr_landlord = playerId
	end
	-- check if grab is over
	-- 1. random grab mode
	if grab_landlord_mode == 1 then
		if curr_grab_level > 0 then
			-- now landlord is known
			grab_landlord_over(curr_landlord)
			return
		end
	-- 2. score grab mode
	else if grab_landlord_mode == 2 then
		-- the one who give level 3 first get landlord
		if curr_grab_level == 3 then
			-- now landlord is known
			grab_landlord_over(curr_landlord)
			return
		end
	end

	-- now nobody want to grab landlord
	if grab_times >= 3 then
		if curr_landlord > 0 then
			grab_landlord_over(curr_landlord)
		else
			restart_game()
		end
		return
	end

	curr_who_grab = get_next_player(curr_who_grab)
	send_all_player("grabLandlord_ntf", {playerId=playerId, grabAction=grabAction})
	skynet.timeout(10, function()
		grab_landlord()
	end)
end

local function play_poker()
	send_all_player("whoPlay_ntf", {playerId = curr_who_play})
	set_timer("play_timer", 1500, function()
		play_poker_handler(curr_who_play, 2, nil, nil)
	end)
end

local function play_poker_handler(playerId, playAction, pokerType, pokerList)
	unset_timer("play_timer")

	-- check if game is over

	curr_who_play = get_next_player(curr_who_play)
	send_all_player("playPoker_ntf", {playerId=playerId, playAction=playAction, pokerType=pokerType, pokerList=pokerList})
	skynet.timeout(10, function()
		play_poker()
	end)
end

local function restart_game()
	last_poker = {}
	curr_who_grab = 1
	grab_times = 0
	curr_who_play = 1

	send_all_player("restartGame_ntf", {errno = 0})
	skynet.timeout(50, start_play_poker)
end

function SERVICE_API.init(conf)
	room_no = conf.roomNo
	grab_landlord_mode =  conf.grabMode
	if 1 == grab_landlord_mode then
		curr_who_grab = math.random(1, 3)
	end
end

function SERVICE_API.join(agent)
	local sid = agent.sid
	local userInfo = agent.userInfo
	curr_player_num = curr_player_num + 1
	local playerId = curr_player_num
	player_info_list[curr_player_num] = {
		sid = sid,
		status = 0,
		playerId = playerId,
		userInfo = userInfo
	}
	return playerId
end

function SERVICE_API.getReady(playerId)
	local userInfo = player_info_list[playerId]
	userInfo.status = 1 // now ready

	local readyNum = 0
	local readyUserList = {}
	for k, v in ipairs(player_info_list) do
		if v.status == 1 then
			readyNum = readyNum + 1
			local readyUser = {}
			readyUser.playerId = playerId
			readyUser.nickname = v.userInfo.nickname
			readyUser.sexType = v.userInfo.sexType
			readyUser.iconUrl = v.userInfo.iconUrl
			readyUser.level = v.userInfo.level
			readyUser.roomCardNum = v.userInfo.roomCardNum
			table.insert(readyUserList, readyUser)
		end
	end
	send_all_player("getReady_ntf", readyUserList)

	-- check if all players get ready
	if readyNum == max_player_num then
		skynet.timeout(100, start_play_poker)
	end
end

function SERVICE_API.grabLandlord(msg)
	local playerId = msg.playerId
	local grabAction = msg.grabAction
	grab_landlord_handler(playerId, grabAction)
end

function SERVICE_API.playPoker(msg)
	local playerId = msg.playerId
	local playAction = msg.playAction
	local pokerType = msg.pokerType
	local pokerList = msg.pokerList
	play_poker_handler(playerId, playAction, pokerType, pokerList)
end

function SERVICE_API.leave(playerId)
	local playerInfo = player_info_list[playerId]
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
	math.randomseed(skynet.now()/100)
end)
