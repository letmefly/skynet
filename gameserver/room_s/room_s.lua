local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local cjson = require "cjson"
local pokerUtil = require "room_s.pokerUtil"

local SAPI = {}

local this = {}

this.timerCallbackList = {}
this.secondsTimerCallbackList = {}
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
-- all player's pokerList
this.allPlayerPokerSet = {}

function this.sendAllPlayer(msgname, msg)
	for k, v in pairs(this.playerInfoList) do
		if v then
			local sid = v.sid
			skynet.call(sid, "lua", "sendClient", msgname, msg)
		end
	end
end

function this.sendPlayer(sid, msgname, msg)
	skynet.call(sid, "lua", "sendClient", msgname, msg)
end

--------------------------------game timer ----------------------------------
this.gameTimers = {}
function this.startGameTimer()
	local function tick()
		for k, v in pairs(this.gameTimers) do
			if v then
				local sec = v.sec
				local cb = v.cb
				local t = v.t
				if t == 2 and sec >= 0 and sec % 10 == 0 then
					cb(sec/10)
				elseif t == 1 and sec == 0 then
					cb()
				end
				v.sec = v.sec - 1
			end
		end
		skynet.timeout(10, tick)
	end
	skynet.timeout(10, tick)
end
function this.setTimer(name, time, callback)
	this.gameTimers[name] = {sec = time/10, cb = callback, t = 1}
end
function this.unsetTimer(name)
	this.gameTimers[name] = nil
end
function this.setSecondTimer(name, seconds, callback)
	this.gameTimers[name] = {sec = seconds*10, cb = callback, t = 2}
end
function this.unsetSecondTimer(name)
	this.gameTimers[name] = nil
end

-- send 17 poker to all player
function this.startGame()
	-- 1,2,3,4,means that heart-3,diamod-3,club-3,spade-3
	local pokerSet = {}
	for i = 1, 54 do
		pokerSet[i] = i
	end

	for i = 1, 3 do
		local random = math.random(#pokerSet)
		this.bottomPokerList[i] = pokerSet[random]
		table.remove(pokerSet, random)
	end
	for k, v in ipairs(this.playerInfoList) do
		local sid = v.sid
		local playerId = v.playerId
		local pokerList = {}
		-- random choose poker
		for i=1, 17 do
			local random = math.random(#pokerSet)
			table.insert(pokerList, pokerSet[random])
			table.remove(pokerSet, random)
		end
		this.allPlayerPokerSet[playerId] = pokerList
		--table.insert(allPokerList, pokerList)
		this.sendPlayer(sid, "startGame_ntf", {pokerList = pokerList, bottomList = this.bottomPokerList})
	end


	-- notify who grab landlord after 2s
	skynet.timeout(200, this.grabLandlord)
end

function this.getNextPlayer(playerId)
	return playerId % this.maxPlayerNum + 1
end

function this.grabLandlord()
	this.sendAllPlayer("whoGrabLandlord_ntf", {playerId = this.currWhoGrab})
	this.setSecondTimer("grab"..this.currWhoGrab, 10, function(timerVal)
		if timerVal == 0 then
			this.grabTimeout(this.currWhoGrab)
		else
			this.alarmTimerNtf("grab", this.currWhoGrab, timerVal)
		end
	end)
end

function this.grabLandlordOver(playerId)
	this.sendAllPlayer("landlord_ntf", {playerId = playerId, bottomPokerList = this.bottomPokerList})
	this.currWhoPlay = playerId
	skynet.timeout(20, this.playPoker)
end

function this.unsetSecondTimerNtf(timerType, playerId)
	this.unsetSecondTimer(timerType..playerId)
	this.sendAllPlayer("stopAlarmTimer_ntf", {playerId = playerId, timerType = timerType})
end

function this.grabTimeout(playerId)
	this.grabLandlordHandler(playerId, 1)
end

function this.grabLandlordHandler(playerId, grabAction)
	this.unsetSecondTimerNtf("grab", playerId)
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
	this.sendAllPlayer("whoPlay_ntf", {playerId = this.currWhoPlay, prevPlayerId = this.prevPlayerId})
	this.setSecondTimer("play"..this.currWhoPlay, 15, function(timerVal)
		if timerVal == 0 then
			this.playTimeout(this.currWhoPlay)
		else
			this.alarmTimerNtf("play", this.currWhoPlay, timerVal)
		end
	end)
end

function this.playTimeout(playerId)
	this.playPokerHandler(playerId, 1, {})
end

function this.playPokerHandler(playerId, playAction, pokerList)
	this.unsetSecondTimerNtf("play", playerId)
	-- check if game is over

	-- check client error
	if playAction == 1 then
		if #this.prevPokerList == 0 then
			skynet.error("ERR: the player that should play can not skip")
			return
		end
	elseif playAction == 2 then
		-- check curr player's poker bigger than prev one
		if pokerUtil.pokerCmp(pokerList, this.prevPokerList) == -1 then
			skynet.error("ERR: smaller pokerList is submmit")
			skynet.error(cjson.encode(pokerList))
			skynet.error(cjson.encode(this.prevPokerList))
			return
		end
	end

	this.sendAllPlayer("playPoker_ntf", {playerId=playerId, playAction=playAction, pokerType=pokerType, pokerList=pokerList})

	-- update this player's pokers and previous pokers
	this.allPlayerPokerSet[playerId] = table_remove(this.allPlayerPokerSet[playerId], pokerList)
	this.currWhoPlay = this.getNextPlayer(this.currWhoPlay)
	-- nobody can pay aginest prev player, clear prev play info
	if this.currWhoPlay == this.prevPlayerId then
		this.prevPlayerId = this.currWhoPlay
		this.prevPokerList = {}
	end

	skynet.timeout(10, function()
		this.playPoker()
	end)

	if #pokerList > 0 then
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

function this.joinRoomOkNtf(playerId)
	local userInfoList = {}
	for k, v in ipairs(this.playerInfoList) do
		if v then
			local userInfo = {}
			userInfo.playerId = v.playerId
			userInfo.nickname = v.userInfo.nickname
			userInfo.sexType = v.userInfo.sexType
			userInfo.iconUrl = v.userInfo.iconUrl
			userInfo.level = v.userInfo.level
			userInfo.roomCardNum = v.userInfo.roomCardNum
			table.insert(userInfoList, userInfo)
		end
	end
	this.sendAllPlayer("joinRoomOk_ntf", {userInfoList = userInfoList})
	local timerName = "ready".. playerId
	this.setSecondTimer(timerName, 15, function(timerVal)
		if timerVal == 0 then
			this.leaveRoom(playerId)
		else
			this.alarmTimerNtf("ready", playerId, timerVal)
		end
	end)
end

function this.alarmTimerNtf(timerType, playerId, timerVal)
	this.sendAllPlayer("alarmTimer_ntf", {playerId = playerId, timerVal = timerVal, timerType = timerType})
end

function this.leaveRoom(playerId)
	this.sendAllPlayer("leaveRoom_ntf", {playerId = playerId})
	this.playerInfoList[playerId] = nil
	this.currPlayerNum = this.currPlayerNum - 1
end

----------------------------- sevevice api -------------------------------
function SAPI.init(conf)
	this.roomNo = conf.roomNo
	this.roomOwner = 1
	this.readyPlayerNum = 0
	this.grabLandlordMode =  conf.grabMode
	if 1 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, 3)
	end
	this.startGameTimer()
	return 0
end

function SAPI.joinRoom(agent)
	local sid = agent.sid
	local userInfo = agent.userInfo
	this.currPlayerNum = this.currPlayerNum + 1
	local playerId = this.currPlayerNum
	for k, v in pairs(this.playerInfoList) do
		if v == nil then
			playerId = k
		end
	end
	
	this.playerInfoList[playerId] = {
		sid = sid,
		status = 0,
		playerId = playerId,
		userInfo = userInfo
	}

	-- notify all join user info
	--skynet.timeout(5, this.joinNtf)

	return playerId
end

function SAPI.joinRoomOk(msg)
	local playerId = msg.playerId
	this.joinRoomOkNtf(playerId)
end

function SAPI.getReady(playerId)
	this.unsetSecondTimerNtf("ready", playerId)
	local userInfo = this.playerInfoList[playerId]
	if userInfo.status == 1 then return end

	userInfo.status = 1 -- now ready
	local readyList = {}
	for k, v in pairs(this.playerInfoList) do
		if v and v.status == 1 then
			local readyPlayerId = v.playerId
			table.insert(readyList, readyPlayerId)
		end
	end

	-- check if all players get ready
	this.readyPlayerNum = #readyList
	if this.readyPlayerNum == this.maxPlayerNum then
		skynet.timeout(50, this.startGame)
	end
	this.sendAllPlayer("getReady_ntf", {readyList = readyList})
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
	local pokerList = msg.pokerList
	this.playPokerHandler(playerId, playAction, pokerList)
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
