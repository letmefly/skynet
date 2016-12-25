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
this.currPlayTimes = 0
this.maxPlayTimes = 6
this.playResultList = {}

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
this.isFirstOneGrab = false
this.firstGrabPlayerId = 0
-- all player's pokerList
this.allPlayerPokerSet = {}

function this.sendAllPlayer(msgname, msg)
	for k, v in pairs(this.playerInfoList) do
		if v and v.sid then
			local sid = v.sid
			skynet.call(sid, "lua", "sendClient", msgname, msg)
		end
	end
end

function this.sendPlayer(sid, msgname, msg)
	if sid then
		skynet.call(sid, "lua", "sendClient", msgname, msg)
	end
end

function this.sendAllAgent(cmd, msg)
	for k, v in pairs(this.playerInfoList) do
		if v and v.sid then
			local sid = v.sid
			skynet.call(sid, "lua", cmd, msg)
		end
	end
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
	this.unsetSecondTimer("s"..999)
	this.currPlayTimes = this.currPlayTimes + 1
	-- 1,2,3,4,means that heart-3,diamod-3,club-3,spade-3
	local factor1 = 54
	local factor2 = 17
	local factor3 = 3
	if this.maxPlayerNum == 4 then
		factor1 = 108
		factor2 = 25
		factor3 = 8
	end
	local pokerSet = {}
	for i = 1, factor1 do
		table.insert(pokerSet, i)
	end

	for i = 1, factor3 do
		local random = math.random(#pokerSet)
		this.bottomPokerList[i] = pokerSet[random]
		table.remove(pokerSet, random)
	end
	for k, v in ipairs(this.playerInfoList) do
		local sid = v.sid
		local playerId = v.playerId
		local pokerList = {}
		-- random choose poker
		for i=1, factor2 do
			local random = math.random(#pokerSet)
			table.insert(pokerList, pokerSet[random])
			table.remove(pokerSet, random)
		end
		pokerUtil.sortPoker(pokerList)
		this.allPlayerPokerSet[playerId] = pokerList
		--table.insert(allPokerList, pokerList)
		this.sendPlayer(sid, "startGame_ntf", {pokerList = pokerList, bottomList = this.bottomPokerList})
	end


	-- notify who grab landlord after 2s
	skynet.timeout(200, this.grabLandlord)
end

function this.getNextPlayer(playerId)
	playerId = playerId - 1
	if playerId == 0 then
		playerId = this.maxPlayerNum
	end
	return playerId
end

function this.grabLandlord()
	this.sendAllPlayer("whoGrabLandlord_ntf", {playerId = this.currWhoGrab})
	this.setSecondTimer("g"..this.currWhoGrab, 10, function(timerVal)
		if timerVal == 0 then
			this.grabTimeout(this.currWhoGrab)
		else
			this.alarmTimerNtf("g", this.currWhoGrab, timerVal)
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
	this.sendAllPlayer("grabLandlord_ntf", {playerId=playerId, grabAction=grabAction})
	this.unsetSecondTimerNtf("g", playerId)
	this.grabTimes = this.grabTimes + 1
	if grabAction - 1 >= this.currGrabLevel then
		this.currGrabLevel = grabAction - 1
		this.currLandlord = playerId
	end

	if this.firstGrabPlayerId == playerId and grabAction > 1 then
		this.isFirstOneGrab = true
	end

	local maxGrabTimes = this.maxPlayerNum
	if this.isFirstOneGrab and this.currLandlord ~= this.firstGrabPlayerId then
		maxGrabTimes = this.maxPlayerNum + 1
	end
	-- check if grab is over
	-- 1. random grab mode
	if this.grabLandlordMode == 1 then
		if this.currGrabLevel > 0 and this.grabTimes >= maxGrabTimes then
			-- now landlord is known
			this.grabLandlordOver(this.currLandlord)
			return
		end
	-- 2. score grab mode
	elseif this.grabLandlordMode == 2 then
		-- the one who give level 3 first get landlord
		if this.currGrabLevel == 3 or 
			(this.currGrabLevel>0 and this.grabTimes==maxGrabTimes) then
			-- now landlord is known
			this.grabLandlordOver(this.currLandlord)
			return
		end
	end

	-- now nobody want to grab landlord
	if this.grabTimes > maxGrabTimes then
		this.restartGame()
		return
	end

	this.currWhoGrab = this.getNextPlayer(this.currWhoGrab)
	skynet.timeout(10, this.grabLandlord)
end

function this.playPoker()
	this.sendAllPlayer("whoPlay_ntf", {playerId = this.currWhoPlay, prevPlayerId = this.prevPlayerId})
	this.setSecondTimer("p"..this.currWhoPlay, 15, function(timerVal)
		if timerVal == 0 then
			this.playTimeout(this.currWhoPlay)
		else
			this.alarmTimerNtf("p", this.currWhoPlay, timerVal)
		end
	end)
end

function this.playTimeout(playerId)
	local playPokerList = {}
	local playAction = 1
	if #this.prevPokerList == 0 then
		playAction = 2
		table.insert(playPokerList, this.allPlayerPokerSet[playerId][1])
	end
	this.playPokerHandler(playerId, playAction, playPokerList)
end

function this.playPokerHandler(playerId, playAction, pokerList)
	this.unsetSecondTimerNtf("p", playerId)

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
		local pokerType, level = pokerUtil.getPokerType(pokerList)
		if pokerType == 11 or pokerType == 12 then
			this.playerInfoList[playerId].boomNum = this.playerInfoList[playerId].boomNum + 1
		end
	end

	this.sendAllPlayer("playPoker_ntf", {playerId=playerId, playAction=playAction, pokerType=pokerType, pokerList=pokerList})

	-- update this player's pokers and previous pokers
	this.allPlayerPokerSet[playerId] = table_remove(this.allPlayerPokerSet[playerId], pokerList)
	-- according to player's newest pokers, check if game is over
	if #this.allPlayerPokerSet[playerId] == 0 then
		local isLandlordWin = false
		if this.currLandlord == playerId then
			isLandlordWin = true
		end
		local totalBoom = 0
		for k, v in pairs(this.playerInfoList) do
			totalBoom = totalBoom + this.playerInfoList[k].boomNum
		end
		local resultList = {}
		for i = 1, this.maxPlayerNum do
			local item = {}
			item.playerId = i
			item.leftPokerNum = #this.allPlayerPokerSet[i]
			item.boomNum = this.playerInfoList[i].boomNum
			if i == this.currLandlord then
				if isLandlordWin then
					item.result = 2
					item.score = 2*math_pow(2, totalBoom)
				else
					item.result = 1
					item.score = -2*math_pow(2, totalBoom)
				end
			else
				if isLandlordWin then
					item.result = 1
					item.score = -1*math_pow(2, totalBoom)
				else
					item.result = 2
					item.score = 1*math_pow(2, totalBoom)
				end
			end
			item.score = this.playerInfoList[i].spring *item.score
			table.insert(resultList, item)
		end
		this.sendAllPlayer("gameResult_ntf", {resultList = resultList})
		this.playResultList[this.currPlayTimes] = resultList

		-- all games are over, dismiss room
		if this.currPlayTimes >= this.maxPlayTimes then
			this.roomOver()
			return
		else
			this.resetGame()
			this.setSecondTimer("s"..999, 15, function(timerVal)
				if timerVal == 0 then
					this.restartGame()
				else
					this.alarmTimerNtf("s", 999, timerVal)
				end
			end)
		end
		return
	end

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

function this.calcRoomResult()
	print(cjson.encode(this.playResultList))
	local roomResultList = {}
	for k, v in pairs(this.playerInfoList) do
		local item = {}
		item.playerId = v.playerId
		item.nickname = v.userInfo.nickname
		item.totalBoom = 0
		item.maxScore = 0
		item.winTimes = 0
		item.totalScore = 0
		for kk, vv in pairs(this.playResultList) do
			for kkk, vvv in pairs(vv) do
				if vvv.playerId == item.playerId then
					item.totalBoom = item.totalBoom + vvv.boomNum
					if vvv.score > item.maxScore then
						item.maxScore = vvv.score
					end
					item.totalScore = item.totalScore + vvv.score
					if vvv.result == 2 then
						item.winTimes = item.winTimes + 1
					end
				end
			end
		end
		table.insert(roomResultList, item)
	end
	return roomResultList
end

function this.roomOver()
	local roomResultList = this.calcRoomResult()
	this.setTimer("roomResult", 100, function()
		this.sendAllPlayer("roomResult_ntf", {roomResultList = roomResultList})
	end)

	-- save user game data
	this.sendAllAgent("saveGameResult", roomResultList)
end

function this.resetGame()
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
	if 1 == this.grabLandlordMode or 2 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, this.maxPlayerNum)
	end
	this.firstGrabPlayerId = this.currWhoGrab
	this.isFirstOneGrab = false
	for k, v in pairs(this.playerInfoList) do
		v.status = 0
	end
end

function this.restartGame()
	this.resetGame()
	this.sendAllPlayer("restartGame_ntf", {errno = 1000})
end

function this.joinRoomOkNtf(playerId)
	local userInfoList = {}
	for k, v in ipairs(this.playerInfoList) do
		if v then
			local userInfo = {}
			userInfo.playerId = v.playerId
			userInfo.userId = v.userInfo.userId
			userInfo.nickname = v.userInfo.nickname
			userInfo.sexType = v.userInfo.sexType
			userInfo.iconUrl = v.userInfo.iconUrl
			userInfo.level = v.userInfo.level
			userInfo.roomCardNum = v.userInfo.roomCardNum
			table.insert(userInfoList, userInfo)
		end
	end
	this.sendAllPlayer("joinRoomOk_ntf", {userInfoList = userInfoList})
	this.setSecondTimer("r"..playerId, 15, function(timerVal)
		if timerVal == 0 then
			this.leaveRoom(playerId)
		else
			this.alarmTimerNtf("r", playerId, timerVal)
		end
	end)
end

function this.alarmTimerNtf(timerType, playerId, timerVal)
	this.sendAllPlayer("alarmTimer_ntf", {playerId = playerId, timerVal = timerVal, timerType = timerType})
end

function this.leaveRoom(playerId)
	this.sendAllPlayer("leaveRoom_ntf", {playerId = playerId})
	local playerInfo = this.playerInfoList[playerId]
	this.playerInfoList[playerId] = nil		
	this.currPlayerNum = this.currPlayerNum - 1
	local playerNum = 0
	for k, v in pairs(this.playerInfoList) do
		if v then
			playerNum = playerNum + 1
		end
	end

	if playerInfo.sid then
		skynet.timeout(100, function()
			skynet.kill(playerInfo.sid)
		end)
	end
	
	-- dismiss room
	if playerNum == 0 then
		skynet.timeout(100, function()
			skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
		end)
	end
end

----------------------------- sevevice api -------------------------------
function SAPI.init(conf)
	this.roomNo = conf.roomNo
	this.maxPlayerNum = conf.roomType
	this.maxPlayTimes = conf.playTimes
	this.grabLandlordMode = conf.grabMode
	this.maxBoom = conf.maxBoom

	this.currPlayTimes = 0
	this.roomOwner = 1
	this.readyPlayerNum = 0
	this.playResultList = {}
	if 1 == this.grabLandlordMode or 2 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, this.maxPlayerNum)
	end
	this.firstGrabPlayerId = this.currWhoGrab
	this.isFirstOneGrab = false

	this.startGameTimer()

	this.setTimer("destroyRoom", 2*3600*100, function() 
		skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
	end)
	return 0
end

function SAPI.joinRoom(agent)
	if this.maxPlayerNum == this.currPlayerNum then
		return {errno = -1}
	end
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
		boomNum = 0,
		spring = 1, -- 1 no spring, 2 spring
		userInfo = userInfo
	}

	-- notify all join user info
	--skynet.timeout(5, this.joinNtf)

	return {playerId=playerId, maxPlayTimes=this.maxPlayTimes, grabMode=this.grabLandlordMode, roomType = this.maxPlayerNum}
end

function SAPI.joinRoomOk(msg)
	local playerId = msg.playerId
	this.joinRoomOkNtf(playerId)
end

function SAPI.getReady(playerId)
	this.unsetSecondTimerNtf("r", playerId)
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
	if playerId == 1 then
		for k, v in pairs(this.playerInfoList) do
			if v then
				local tmpPlayerId = v.playerId
				this.leaveRoom(tmpPlayerId)
			end
		end
	else
		this.leaveRoom(playerId)
	end
end

function SAPI.chat(msg)
	this.sendAllPlayer("chat_ntf", msg)
end

function SAPI.rejoin(msg)
	local playerId = msg.playerId
	local sid = msg.sid
	this.playerInfoList[playerId].sid = sid
end

function SAPI.disconnect(playerId)
	if this.playerInfoList[playerId] then 
		this.playerInfoList[playerId].sid = nil
	end
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
