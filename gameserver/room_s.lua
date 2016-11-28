local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local this = {}
local SAPI = {}
this.timerCallbackList = {}
this.playerInfoList = {}
this.roomNo = nil
this.maxPlayerNum = 3
this.grabLandlordMode = 1 --1 random mode, 2 score mode
this.currPlayerNum = 0
this.roomOwner = 0

-- game state data
this.bottomPokerList = {}
this.currWhoGrab = 1
this.grabTimes = 0
this.currWhoPlay = 1
this.currLandlord = 0
this.currGrabLevel = 0
this.prevPlayerId = 0
this.prevPokerList = {}
this.readyPlayerNum = 0

function this.sendAllPlayer(msgname, msg)
	for k, v in ipairs(this.playerInfoList) do
		local sid = v.sid
		skynet.call(sid, "lua", "sendClient", msgname, msg)
	end
end

function this.sendPlayer(sid, msgname, msg)
	skynet.call(sid, "lua", "sendClient", msgname, msg)
end

function this.setTimer(name, time, callback)
	this.timerCallbackList[name] = callback
	skynet.timeout(time, function()
		local callback = this.timerCallbackList[name]
		if nil ~= callback then
			callback()
			this.timerCallbackList[name] = nil
		end
	end)
end

function this.unsetTimer(name)
	if nil ~= this.timerCallbackList[name] then
		this.timerCallbackList[name] = nil
	end
end

-- return 1 pokerList1 > pokerList2, 0 pokerList1 == pokerList2, -1 pokerList1 < pokerList2
function this.pokerCmp(pokerList1, pokerList2)
	return 1
end

-- send 17 poker to all player
function this.startGame()
	--[[
	local pokerSet = {
		103,104,105,106,107,108,109,110,111,112,113,114,115, -- heart
		203,204,205,206,207,208,209,210,211,212,213,214,215, -- diamod
		303,304,305,306,307,308,309,310,311,312,313,314,315, -- club
		403,404,405,406,407,408,409,410,411,412,413,414,415, -- spade
		516,517												 -- small joker and big joker
	}
	]]
	-- 1,2,3,4,means that heart-3,diamod-3,club-3,spade-3
	local pokerSet = {}
	for i = 1, 54 do
		pokerSet[i] = i
	end

	--local allPokerList = {}
	for k, v in ipairs(this.playerInfoList) do
		local sid = v.sid
		local pokerList = {}
		-- random choose poker
		for i=1, 17 do
			local random = math.random(#pokerSet)
			table.insert(pokerList, pokerSet[random])
			table.remove(pokerSet, random)
		end
		--table.insert(allPokerList, pokerList)
		this.sendPlayer(sid, "startGame_ntf", {pokerList = pokerList})
	end
	for i = 1, 3 do
		this.bottomPokerList[i] = pokerSet[i]
	end

	-- notify who grab landlord after 2s
	skynet.timeout(200, this.grabLandlord)
end

function this.getNextPlayer(playerId)
	return playerId % this.maxPlayerNum + 1
end

function this.grabLandlord()
	this.sendAllPlayer("whoGrabLandlord_ntf", {playerId = this.currWhoGrab})
	this.setTimer("play_timer", 500, function()
		this.grabLandlordHandler(this.currWhoGrab, 1)
	end)
end

function this.grabLandlordOver(playerId)
	this.sendAllPlayer("landlord_ntf", {playerId = playerId, bottomPokerList = this.bottomPokerList})
	this.currWhoPlay = playerId
	skynet.timeout(20, this.playPoker)
end

function this.grabLandlordHandler(playerId, grabAction)
	this.unsetTimer("play_timer")
	this.grabTimes = this.grabTimes + 1

	if grabAction - 1 > this.currGrabLevel then
		this.currGrabLevel = grabAction - 1
		this.currLandlord = playerId
	end
	-- check if grab is over
	-- 1. random grab mode
	if this.grabLandlordMode == 1 then
		if this.currGrabLevel > 0 then
			-- now landlord is known
			this.grabLandlordOver(this.currLandlord)
			return
		end
	-- 2. score grab mode
	elseif this.grabLandlordMode == 2 then
		-- the one who give level 3 first get landlord
		if this.currGrabLevel == 3 then
			-- now landlord is known
			this.grabLandlordOver(this.currLandlord)
			return
		end
	end

	-- now nobody want to grab landlord
	if this.grabTimes >= 3 then
		if this.currLandlord > 0 then
			this.grabLandlordOver(this.currLandlord)
		else
			this.restartGame()
		end
		return
	end

	this.currWhoGrab = this.getNextPlayer(this.currWhoGrab)
	this.sendAllPlayer("grabLandlord_ntf", {playerId=playerId, grabAction=grabAction})
	skynet.timeout(10, this.grabLandlord)
end

function this.playPoker()
	this.sendAllPlayer("whoPlay_ntf", {playerId = this.currWhoPlay})
	this.setTimer("play_timer", 1500, function()
		this.playPokerHandler(this.currWhoPlay, 1, nil, nil)
	end)
end

function this.playPokerHandler(playerId, playAction, pokerType, pokerList)
	this.unsetTimer("play_timer")

	-- check if game is over

	-- check client error
	if playAction == 1 then
		if this.prevPokerList == {} then
			skynet.error("ERR: the player that should play can not skip")
			return
		end
	elseif playAction == 2 then
		-- check curr player's poker bigger than prev one
		if this.pokerCmp(pokerList, this.prevPokerList) <= 0 then
			skynet.error("ERR: smaller pokerList is submmit")
			return
		end
	end

	this.sendAllPlayer("playPoker_ntf", {playerId=playerId, playAction=playAction, pokerType=pokerType, pokerList=pokerList})
	
	this.currWhoPlay = this.getNextPlayer(this.currWhoPlay)
	
	-- nobody can pay aginest prev player, clear prev play info
	if this.currWhoPlay == this.prevPlayerId then
		this.prevPlayerId = this.currWhoPlay
		this.prevPokerList = {}
	end

	skynet.timeout(10, function()
		this.playPoker()
	end)

	if pokerList ~= {} and pokerList ~= nil then
		this.prevPlayerId = playerId
		this.prevPokerList = pokerList
	end
end

function this.restartGame()
	this.bottomPokerList = {}
	this.currWhoGrab = 1
	this.grabTimes = 0
	this.currWhoPlay = 1

	this.sendAllPlayer("restartGame_ntf", {errno = 0})
	skynet.timeout(50, this.startGame)
end

function SAPI.init(conf)
	this.roomNo = conf.roomNo
	this.roomOwner = 1
	this.grabLandlordMode =  conf.grabMode
	if 1 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, 3)
	end
end

function SAPI.join(agent)
	local sid = agent.sid
	local userInfo = agent.userInfo
	this.currPlayerNum = this.currPlayerNum + 1
	local playerId = this.currPlayerNum
	this.playerInfoList[this.currPlayerNum] = {
		sid = sid,
		status = 0,
		playerId = playerId,
		userInfo = userInfo
	}
	return playerId
end

function SAPI.getReady(playerId)
	local userInfo = this.playerInfoList[playerId]
	userInfo.status = 1 -- now ready

	local readyUserList = {}
	for k, v in ipairs(this.playerInfoList) do
		if v.status == 1 then
			this.readyPlayerNum = this.readyPlayerNum + 1
			local readyUser = {}
			readyUser.playerId = v.playerId
			readyUser.nickname = v.userInfo.nickname
			readyUser.sexType = v.userInfo.sexType
			readyUser.iconUrl = v.userInfo.iconUrl
			readyUser.level = v.userInfo.level
			readyUser.roomCardNum = v.userInfo.roomCardNum
			table.insert(readyUserList, readyUser)
		end
	end
	this.sendAllPlayer("getReady_ntf", {userInfoList = readyUserList})

	-- check if all players get ready
	--if this.readyPlayerNum == this.maxPlayerNum then
	--	skynet.timeout(100, this.startGame)
	--end
end

function SAPI.startGame(msg)
	if this.readyPlayerNum == this.maxPlayerNum then
		this.startGame()
	end
end

function SAPI.grabLandlord(msg)
	local playerId = msg.playerId
	local grabAction = msg.grabAction
	this.grabLandlordHandler(playerId, grabAction)
end

function SAPI.playPoker(msg)
	local playerId = msg.playerId
	local playAction = msg.playAction
	local pokerType = msg.pokerType
	local pokerList = msg.pokerList
	this.playPokerHandler(playerId, playAction, pokerType, pokerList)
end

function SAPI.leave(playerId)
	print ("player "..playerId.." leave room")
	local playerInfo = this.playerInfoList[playerId]
	this.playerInfoList[playerId] = nil
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
	math.randomseed(skynet.now()/100)
end)
