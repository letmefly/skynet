local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local cjson = require "cjson"
local pokerUtil = require "room_s.pokerUtil"
local netutil = require "agent_s.netutil"
local httpc = require "http.httpc"
local http_server_addr = "127.0.0.1:80"
local doc_root_dir = "/php_01/html/v0/"

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
this.isCostRoomCard = false
this.playResultList = {}

-- game state data
this.bottomPokerList = {}
this.currWhoGrab = 1
this.grabTimes = 0
this.currWhoPlay = 1
this.currLandlord = 0
this.currLevel = 1
this.currGrabLevel = 0
this.prevPlayerId = 0
this.prevPokerList = {}
this.readyPlayerNum = 0
this.isFirstOneGrab = false
this.firstGrabPlayerId = 0
this.dispatchRedPackVal = 0
-- all player's pokerList
this.allPlayerPokerSet = {{},{},{}}
this.dismissInfo = {}
this.startGameTime = os.clock()
this.getRedPackPlayTiems = 0

this.roomTimerTicks = 5

this.testPokers = {
	{1,5,9,13,17,49,50,51,2,3,4,45,46,47,48,16,24},
	{42, 43, 44,30,31,32,34,	35,	36, 18,	19,	38,	39,	26,	27,	28,	41},
	{21,	25,	29,	33,	37,	6,	7,	8,	10,	11,	12,	14,	15,	22,	23,	20,	40},
	{52,53,	54}
}

this.testPokers = nil

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

function this.saveGameResult(userInfo, playerId, roomNo, roomType, roomResultList)
	local cmdData = {}
	cmdData.roomResult = {}
	cmdData.roomResult.roomNo = roomNo
	cmdData.roomResult.roomType = roomType
	cmdData.roomResult.coinType = this.coinType
	cmdData.roomResult.duringTime = os.clock() - this.startGameTime
	cmdData.roomResult.history = {}
	if this.dispatchRedPackVal > 0 then
		cmdData.dispatchRedPackVal = this.dispatchRedPackVal
		this.dispatchRedPackVal = 0
	end

	local isAllZero = true
	for k, v in pairs(roomResultList) do
		if v.totalScore ~= 0 then
			isAllZero = false
		end
		if v.playerId == playerId then
			cmdData.unionid = userInfo.userId
			if this.isScoreRace() then
				if this.coinType == 1 then
					if v.totalScore > 0 then
						cmdData.addCoin = math.ceil(v.totalScore*2/3)
					else
						cmdData.addCoin = v.totalScore
					end
				else
					--postData.userData.score2 = userInfo.score2
				end
			end
		end
		table.insert(cmdData.roomResult.history, {n=v.nickname, s=v.totalScore})
	end

	if isAllZero == false then
		if this.isScoreRace() then
			--postData.roomResult.history = {}
		end
		--print(cjson.encode(postData))
		local status, body = netutil.http_do_cmd("cmd_submitGameResult", cmdData)
	end
end
function this.costRoomCard(userInfo, msg)
	local costRoomCard = msg.costRoomCardNum
	local cmdData = {}
	cmdData.unionid = userInfo.userId
	cmdData.costRoomCard = costRoomCard
	local status, body = netutil.http_do_cmd("cmd_costRoomCard", cmdData)
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
		if this.gameTimers then
			for k, v in pairs(this.gameTimers) do
				if v then
					local sec = v.sec
					local cb = v.cb
					local t = v.t
					if t == 2 and sec >= 0 and sec % 10 == 0 then
						cb(sec/10)
					elseif t == 1 and sec == 0 then
						cb()
					elseif t == 3 and math.abs(sec) % 10 == 0 then
						cb(sec/10)
					end
					v.sec = v.sec - 1
				end
			end
		end
		skynet.timeout(this.roomTimerTicks, tick)
	end
	skynet.timeout(this.roomTimerTicks, tick)
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
function this.setTickTimer(name, seconds, callback)
	if this.gameTimers then
		this.gameTimers[name] = {sec = seconds*10, cb = callback, t = 3}
	end
end
function this.unsetTickTimer(name)
	if this.gameTimers then
		this.gameTimers[name] = nil
	end
end

-- send 17 poker to all player
function this.startGame()
	this.startGameTime = os.clock()
	if this.isStartCheckRedPack == nil then
		this.checkRedPack()
	end
	this.unsetTickTimer("s"..999)
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
		v.userInfo.status = 3
		v.userInfo.hasPlay = 1
		v.userInfo.leftPoker = factor2
		local sid = v.sid
		local playerId = v.playerId
		local pokerList = {}
		-- random choose poker
		for i=1, factor2 do
			local random = math.random(#pokerSet)
			table.insert(pokerList, pokerSet[random])
			table.remove(pokerSet, random)
		end
		-- just for testing
		if this.testPokers and #this.testPokers > 0 then
			pokerList = this.testPokers[k]
			this.bottomPokerList = this.testPokers[4]
		end
		pokerUtil.sortPoker(pokerList)
		this.allPlayerPokerSet[playerId] = pokerList
		--table.insert(allPokerList, pokerList)
		--this.sendPlayer(sid, "startGame_ntf", {pokerList=pokerList, bottomList=this.bottomPokerList, status=3, currPlayTimes=v.userInfo.gameOverTimes})
	end
	for k, v in ipairs(this.playerInfoList) do
		local sid = v.sid
		local playerId = v.playerId
		local pokerList = this.allPlayerPokerSet[playerId]
		this.sendPlayer(sid, "startGame_ntf", {pokerList=pokerList, bottomList=this.bottomPokerList, status=3, currPlayTimes=v.userInfo.gameOverTimes})
	end
	this.testPokers = nil
	-- notify who grab landlord after 2s
	skynet.timeout(200, this.grabLandlord)
end

function this.getNextPlayer(playerId)
	playerId = playerId + 1
	if playerId > this.maxPlayerNum then
		playerId = 1
	end
	return playerId
end

function this.grabLandlord()
	this.sendAllPlayer("whoGrabLandlord_ntf", {playerId = this.currWhoGrab})
	this.setTickTimer("g"..this.currWhoGrab, 10, function(timerVal)
		if timerVal == 0 then
			if this.isScoreRace() then
				this.grabTimeout(this.currWhoGrab)
			end
		else
			local playerInfo = this.playerInfoList[this.currWhoGrab]
			if playerInfo.sid then
				this.alarmTimerNtf("g", this.currWhoGrab, timerVal)
			else
				this.grabTimeout(this.currWhoGrab)
			end
		end
	end)
end

function this.grabLandlordOver(playerId)
	-- cost room owner's room card
	if this.isCostRoomCard == false and this.isScoreRace() == false then
		local costRoomCardNum = 2
		if this.maxPlayTimes == 12 then
			costRoomCardNum = 3
		end
		local sid = this.playerInfoList[1].sid
		local userInfo = this.playerInfoList[1].userInfo
		if sid then
			--skynet.call(sid, "lua", "costRoomCard", {costRoomCardNum = costRoomCardNum})
			this.costRoomCard(userInfo, {costRoomCardNum = costRoomCardNum})
			this.isCostRoomCard = true
		end
	end
	if this.isGrabOver == true then return end
	this.isGrabOver = true
	local playerInfo = this.playerInfoList[playerId]
	playerInfo.userInfo.isLandlord = 2
	this.sendAllPlayer("landlord_ntf", {playerId = playerId, bottomPokerList = this.bottomPokerList})
	this.allPlayerPokerSet[playerId] = table_insert(this.allPlayerPokerSet[playerId], this.bottomPokerList)
	this.currWhoPlay = playerId
	skynet.timeout(20, this.playPoker)
	this.currLevel = this.currGrabLevel
end

function this.unsetTickTimerNtf(timerType, playerId)
	this.unsetTickTimer(timerType..playerId)
	this.sendAllPlayer("stopAlarmTimer_ntf", {playerId = playerId, timerType = timerType})
end

function this.grabTimeout(playerId)
	this.grabLandlordHandler(playerId, 1)
end

function this.grabLandlordHandler(playerId, grabAction)
	if this.currWhoGrab ~= playerId then return end
	local userInfo = this.playerInfoList[playerId].userInfo
	userInfo.grabRecord = grabAction
	this.unsetTickTimerNtf("g", playerId)
	this.grabTimes = this.grabTimes + 1
	if this.grabLandlordMode == 1 then
		if this.isScoreRace() then
			if grabAction > 1 then
				this.currGrabLevel = 3
				this.currLandlord = playerId
			end
		else
			if grabAction > 1 then
				if this.currGrabLevel == 0 then
					this.currGrabLevel = 1
				else
					this.currGrabLevel = this.currGrabLevel*2
				end
				this.currLandlord = playerId
			end
		end
	else
		if grabAction - 1 >= this.currGrabLevel then
			this.currGrabLevel = grabAction - 1
			this.currLandlord = playerId
		end
	end
	this.sendAllPlayer("grabLandlord_ntf", {playerId=playerId, grabAction=grabAction, grabLevel=this.currGrabLevel})
	
	if this.firstGrabPlayerId == 0 and grabAction > 1 then
		this.firstGrabPlayerId = playerId
	end
	if this.firstGrabPlayerId == playerId and grabAction > 1 then
		this.isFirstOneGrab = true
	end

	local maxGrabTimes = this.maxPlayerNum
	if this.isFirstOneGrab and this.currLandlord ~= this.firstGrabPlayerId and this.grabLandlordMode == 1 then
		maxGrabTimes = this.maxPlayerNum + 1
	end
	-- check if grab is over
	-- 1. random grab mode
	if this.grabLandlordMode == 1 then
		if this.isScoreRace() then
			if grabAction > 1 or this.grabTimes >= 3 then
				this.currGrabLevel = 3
				if this.currLandlord == 0 then
					this.currLandlord = this.firstStartPlayerId
				end
				this.grabLandlordOver(this.currLandlord)
				return
			end
		else
			if this.currGrabLevel > 0 and this.grabTimes >= maxGrabTimes then
				-- now landlord is known
				this.grabLandlordOver(this.currLandlord)
				return
			end			
		end

	-- 2. score grab mode
	elseif this.grabLandlordMode == 2 then
		-- the one who give level 3 first get landlord
		if this.currGrabLevel == 3 or 
			(this.currGrabLevel>0 and this.grabTimes>=maxGrabTimes) then
			-- now landlord is known
			this.grabLandlordOver(this.currLandlord)
			return
		end
	end

	local isFind = false
	local loopTimes = maxGrabTimes + 10
	while true do
		this.currWhoGrab = this.getNextPlayer(this.currWhoGrab)
		local userInfo = this.playerInfoList[this.currWhoGrab].userInfo
		if userInfo.grabRecord == -1 or userInfo.grabRecord > 1 then
			isFind = true
			break
		end
		loopTimes = loopTimes - 1
		if loopTimes <= 0 then
			break
		end
	end

	-- now nobody want to grab landlord
	if this.grabTimes > maxGrabTimes or isFind == false then
		if this.isScoreRace() then
			this.currGrabLevel = 1
			this.currLandlord = this.firstStartPlayerId
			this.grabLandlordOver(this.currLandlord)
		else
			this.currPlayTimes = this.currPlayTimes - 1
			this.restartGame()
		end
		return
	end

	skynet.timeout(10, this.grabLandlord)
end

function this.playPoker()
	local overTime = 0
	local lightPokerIdList = pokerUtil.getLightPokerIdList(this.allPlayerPokerSet[this.currWhoPlay], this.prevPokerList)
	if #lightPokerIdList <= 0 then
		overTime = 10
	end

	this.sendAllPlayer("whoPlay_ntf", {playerId = this.currWhoPlay, prevPlayerId = this.prevPlayerId})
	this.setTickTimer("p"..this.currWhoPlay, 15, function(timerVal)
		if timerVal == overTime then
			if this.isScoreRace() then
				this.playTimeout(this.currWhoPlay, 1)
			end
		else
			local playerInfo = this.playerInfoList[this.currWhoPlay]
			if playerInfo.sid then
				this.alarmTimerNtf("p", this.currWhoPlay, timerVal)
			else
				this.playTimeout(this.currWhoPlay, 3)
			end
		end
	end)
end
-- playAction: 1 - oneline timeout, 2 - normal, 3 - offline timeout
function this.playTimeout(playerId, playAction)
	local playPokerList = {}
	local playAction = playAction
	if #this.prevPokerList == 0 then
		playAction = 2
		table.insert(playPokerList, this.allPlayerPokerSet[playerId][1])
	end
	this.playPokerHandler(playerId, playAction, playPokerList)
end

function this.playPokerHandler(playerId, playAction, pokerList)
	if this.currWhoPlay ~= playerId then 
		skynet.error("ERR: it's not your turning")
		return 
	end
	local pokerType, level = pokerUtil.getPokerType(pokerList)
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
		local playerInfo = this.playerInfoList[playerId]
		if pokerType == 11 or pokerType == 12 then
			playerInfo.boomNum = playerInfo.boomNum + 1
			playerInfo.userInfo.boom = playerInfo.userInfo.boom + 1
			if this.currTotalBoom < this.maxBoom then
				this.currTotalBoom = this.currTotalBoom + 1
				if this.isScoreRace() then
					if this.currTotalBoom <= 2 then
						this.currLevel = this.currLevel * 2
					end
				else
					this.currLevel = this.currLevel * 2
				end
			end
		end
		playerInfo.userInfo.playTimes = playerInfo.userInfo.playTimes + 1
	end
	this.currWhoPlay = this.getNextPlayer(this.currWhoPlay)
	
	this.unsetTickTimerNtf("p", playerId)
	skynet.timeout(5, function()
		this.sendAllPlayer("playPoker_ntf", {playerId=playerId, playAction=playAction, pokerType=pokerType, pokerList=pokerList, grabLevel=this.currLevel})
	end)
	
	-- update this player's pokers and previous pokers
	--print(playerId..":"..cjson.encode(this.allPlayerPokerSet[playerId]))
	this.allPlayerPokerSet[playerId] = table_remove(this.allPlayerPokerSet[playerId], pokerList)
	--print(playerId..":"..cjson.encode(this.allPlayerPokerSet[playerId]))
	--print(playerId..":"..#this.allPlayerPokerSet[playerId])
	this.playerInfoList[playerId].userInfo.leftPoker = #this.allPlayerPokerSet[playerId]
	-- according to player's newest pokers, check if game is over
	if #this.allPlayerPokerSet[playerId] == 0 then
		local isLandlordWin = false
		if this.currLandlord == playerId then
			isLandlordWin = true
		end
		local totalBoom = 0
		local isSpring = 2
		for k, v in pairs(this.playerInfoList) do
			totalBoom = totalBoom + v.userInfo.boom
			if isLandlordWin then
				if v.userInfo.playerId ~= this.currLandlord and v.userInfo.playTimes > 0 then
					isSpring = 1
				end
			else
				if v.userInfo.playerId == this.currLandlord and v.userInfo.playTimes > 1 then
					isSpring = 1
				end
				if v.userInfo.playerId ~= playerId and 
						v.userInfo.playerId ~= this.currLandlord and
						v.userInfo.playTimes > 0 then
					isSpring = 1
				end
			end
		end
		totalBoom = math.min(totalBoom, this.maxBoom)
		local redpackPoolVal = skynet.call("redpackPool_s", "lua", "getRewardPoolVal")
		local resultList = {}
		for i = 1, this.maxPlayerNum do
			this.playerInfoList[i].userInfo.gameOverTimes = this.playerInfoList[i].userInfo.gameOverTimes + 1
			local item = {}
			item.playerId = i
			item.leftPokerNum = #this.allPlayerPokerSet[i]
			item.boomNum = this.playerInfoList[i].userInfo.boom
			if i == this.currLandlord then
				if isLandlordWin then
					item.result = 2
					item.score = (this.maxPlayerNum-1)*math_pow(2, totalBoom)
				else
					item.result = 1
					item.score = -(this.maxPlayerNum-1)*math_pow(2, totalBoom)
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
			if i == playerId and isSpring == 2 then
				if isLandlordWin then
					item.isSpring = 2
				else
					item.isSpring = 3
				end
			else
				item.isSpring = 1
			end
			item.score = this.currGrabLevel*isSpring *item.score
			if this.isScoreRace() then
				item.score = item.score * 1
			end
			if this.isScoreRace() then
				local costCoin = 0
				if item.result == 2 then
					if isLandlordWin then
						--costCoin = -4
						costCoin = -1*math.floor(math.abs(item.score)/3)
					else
						--costCoin = -2
						costCoin = -1*math.floor(math.abs(item.score)/3)
					end
				end
				--item.score = item.score + costCoin
				if this.coinType == 1 then
					this.playerInfoList[i].userInfo.score = item.score + this.playerInfoList[i].userInfo.score + costCoin
				else
					this.playerInfoList[i].userInfo.score2 = item.score + this.playerInfoList[i].userInfo.score2 + costCoin
				end
			else
				if this.coinType == 1 then
					this.playerInfoList[i].userInfo.score = item.score + this.playerInfoList[i].userInfo.score
				else
					this.playerInfoList[i].userInfo.score2 = item.score + this.playerInfoList[i].userInfo.score2
				end
			end
			if this.coinType == 1 then
				item.totalScore = this.playerInfoList[i].userInfo.score
			else
				item.totalScore = this.playerInfoList[i].userInfo.score2
			end
			table.insert(resultList, item)
		end
		local allPlayerLeftPokerSet = {}
		for k, v in pairs(this.allPlayerPokerSet) do
			if #v > 0 then
				table.insert(allPlayerLeftPokerSet, {playerId = k, pokerList = v})
			end
		end
		this.setTimer("gameResult", 10, function()
			this.sendAllPlayer("gameResult_ntf", {resultList = resultList, allPlayerPokerSet=allPlayerLeftPokerSet, redpackPoolVal=redpackPoolVal})
		end)
		this.playResultList[this.currPlayTimes] = resultList

		-- all games are over, dismiss room
		if this.currPlayTimes >= this.maxPlayTimes then
			this.roomOver()
			return
		else
			skynet.timeout(10, function()
				this.resetGame()
			end)
			if this.isScoreRace() then
				this.setGetAITimer()
				for i = 1, this.maxPlayerNum do
					local playerInfo = this.playerInfoList[i]
					if playerInfo.sid == nil then
						skynet.timeout(5*100, function() this.leaveRoom(i, 1) end)
					end
					skynet.timeout(7*100, function()
						if this.playerInfoList[i] and this.playerInfoList[i].userInfo.status < 2 then
							this.setTickTimer("r"..i, 15, function(timerVal)
								if this.playerInfoList[i] and this.playerInfoList[i].userInfo.status < 2 then
									if timerVal == 0 then
										if this.isScoreRace() then
											this.leaveRoom(i, 1)
										end
									else
										if this.playerInfoList[i] then
											this.alarmTimerNtf("r", i, timerVal)
										else
											this.unsetTickTimerNtf("r", i)
										end
									end
								end
							end)
						end
					end)
				end
			end

			--[[
			this.setTickTimer("s"..999, 15, function(timerVal)
				if timerVal == 0 then
					if this.isScoreRace() then
						--this.restartGame()
						this.dealUnreadyUser()
					end
					this.unsetTickTimer("s"..999)
				else
					this.alarmTimerNtf("s", 999, timerVal)
				end
			end)
			]]
			
			--[[
			for i = 1, this.maxPlayerNum do
				this.setTickTimer("r"..i, 15, function(timerVal)
				if timerVal == 0 then
						if this.isScoreRace() then
							this.leaveRoom(i)
						end
					else
						if this.playerInfoList[i] then
							this.alarmTimerNtf("r", i, timerVal)
						else
							this.unsetTickTimerNtf("r", i)
						end
					end
				end)
			end
			]]

			if this.isScoreRace() then
				-- check if some player have readPack
				local status, body = netutil.http_post("service_getActInfo.php", {tag="tag"})
				local actInfo = cjson.decode(body)
				this.actInfo = actInfo

				local roomResultList = this.calcRoomResult()
				this.playResultList = {}
				-- save user game data
				--this.sendAllAgent("saveGameResult", roomResultList)
				for k, v in pairs(this.playerInfoList) do
					this.saveGameResult(v.userInfo, v.playerId, this.roomNo, this.roomType, roomResultList)
				end
				
			end
		end
		return
	end

	
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
	--print(cjson.encode(this.playResultList))
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
			if vv then
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
		end
		if this.currPlayTimes == this.maxPlayTimes then
			item.loseTimes = this.currPlayTimes - item.winTimes
		else
			item.loseTimes = this.currPlayTimes - item.winTimes - 1
		end
		table.insert(roomResultList, item)
	end
	return roomResultList
end

function this.roomOver(t)
	if this.isRoomOver then return end
	this.isRoomOver = true
	local delay = 300
	if t then delay = t end
	local roomResultList = this.calcRoomResult()
	this.setTimer("roomResult", delay, function()
		this.sendAllPlayer("roomResult_ntf", {roomResultList = roomResultList})
		skynet.timeout(100, function()
			skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
			this.gameTimers = nil
		end)
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
	this.currLevel = 1
	this.currGrabLevel = 0
	this.prevPlayerId = 0
	this.prevPokerList = {}
	this.readyPlayerNum = 0
	this.isGrabOver = false
	this.currTotalBoom = 0
	-- all player's pokerList
	this.allPlayerPokerSet = {{},{},{}}
	if 1 == this.grabLandlordMode or 2 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, this.maxPlayerNum)
	end
	this.firstGrabPlayerId = 0
	this.firstStartPlayerId = this.currWhoGrab
	this.isFirstOneGrab = false
	for k, v in pairs(this.playerInfoList) do
		v.userInfo.status = 1
		v.userInfo.isLandlord = 1 -- 1 is not landlord, 2 is landlord
		v.userInfo.boom = 0
		v.userInfo.leftPoker = 0
		v.userInfo.spring = 1
		v.userInfo.playTimes = 0
		v.userInfo.grabRecord = -1
		if this.isScoreRace() then
			v.userInfo.hasPlay = 0
		end
	end
end

function this.restartGame()
	this.resetGame()
	this.sendAllPlayer("restartGame_ntf", {errno = 1000})
end

function this.dealUnreadyUser()
	for k, v in ipairs(this.playerInfoList) do
		if v then
			if v.userInfo.status == 1 then
				this.leaveRoom(v.userInfo.playerId, 1)
			end
		end
	end	
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
			userInfo.playerId = v.userInfo.playerId
			userInfo.win = v.userInfo.win
			userInfo.lose = v.userInfo.lose
			userInfo.score = v.userInfo.score
			userInfo.score2 = v.userInfo.score2
			userInfo.ip = v.userInfo.ip
			userInfo.status = v.userInfo.status
			userInfo.hasPlay = v.userInfo.hasPlay
			userInfo.isLandlord = v.userInfo.isLandlord
			userInfo.boom = v.userInfo.boom
			userInfo.leftPoker = v.userInfo.leftPoker
			userInfo.userno = v.userInfo.userno
			table.insert(userInfoList, userInfo)
		end
	end
	local redpackPoolVal = skynet.call("redpackPool_s", "lua", "getRewardPoolVal")
	this.sendAllPlayer("joinRoomOk_ntf", {userInfoList = userInfoList, redpackPoolVal=redpackPoolVal})

	-- If rejoin room, no need start ready timer
	--print(cjson.encode(this.playerInfoList))
	if this.playerInfoList[playerId] and this.playerInfoList[playerId].userInfo.status > 0 then
		local sid =this.playerInfoList[playerId].sid
		this.sendPlayer(sid, "reJoinRoomOk_ack", {
			userInfoList = userInfoList,
			pokerList = this.allPlayerPokerSet[playerId],
			bottomList = this.bottomPokerList,
			prevPlayerId = this.prevPlayerId,
			prevPlayPokerList = this.prevPokerList,
			currPlayTimes = this.playerInfoList[playerId].userInfo.gameOverTimes,
			grabLevel = this.currLevel,
			redpackPoolVal=redpackPoolVal
		})
	end

	if this.playerInfoList[playerId] and this.playerInfoList[playerId].userInfo.status < 2 then
		this.setTickTimer("r"..playerId, 15, function(timerVal)
			if timerVal == 0 then
				if this.isScoreRace() then
					this.leaveRoom(playerId, 1)
				end
			else
				if this.playerInfoList[playerId] then
					this.alarmTimerNtf("r", playerId, timerVal)
				else
					this.unsetTickTimerNtf("r", playerId)
				end
			end
		end)
	end
end

function this.alarmTimerNtf(timerType, playerId, timerVal)
	this.sendAllPlayer("alarmTimer_ntf", {playerId = playerId, timerVal = timerVal, timerType = timerType})
end

function this.leaveRoom(playerId, t)
	--[[
	this.sendAllPlayer("leaveRoom_ntf", {playerId = playerId})	
	for k, v in pairs(this.playerInfoList) do
		if v then
			skynet.timeout(100, function()
				skynet.kill(v.sid)
			end)
		end
	end
	skynet.timeout(150, function()
		skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
	end)
	]]
	this.unsetTickTimerNtf("r", playerId)
	local playerInfo = this.playerInfoList[playerId]
	if playerInfo == nil then return end
	if playerInfo.sid then
		--skynet.kill(playerInfo.sid)
	end
	if playerInfo.userInfo.hasPlay == 0 and t ~= 2 then
		t = 1
	end
	this.sendAllPlayer("leaveRoom_ntf", {playerId = playerId, t = t})
	if playerInfo.userInfo.hasPlay == 0 then
		playerInfo.userInfo.status = -1
		this.currPlayerNum = this.currPlayerNum - 1
		this.playerInfoList[playerId] = nil
	else
		playerInfo.sid = nil
	end
	
	local playerNum = 0
	for k, v in pairs(this.playerInfoList) do
		if v.sid then
			playerNum = playerNum + 1
		end
	end
	-- dismiss room
	if playerNum == 0 then
		skynet.timeout(0, function()
			this.gameTimers = nil
			skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
		end)
	end
end

function this.assignPlayerId()
	for i = 1, this.maxPlayerNum do
		if this.playerInfoList[i] == nil then
			return i
		end
	end
	return -1
end

function this.isScoreRace()
	return this.maxPlayTimes > 12 
end

-- Get AI player number
function this.setGetAITimer()
	local playerNum = 0
	for k, v in pairs(this.playerInfoList) do
		if v then
			local userInfo = v.userInfo
			local userFactor = this.calcUserFactor(userInfo)
			if userFactor > 4 then
				playerNum = playerNum + 1
			end
		end
	end
	if playerNum > 0 then
		return
	end

	--print("setGetAITimer..\n")
	this.unsetTimer("get_ai_timer")
	local randomVal = math.random(7, 10)
	this.setTimer("get_ai_timer", randomVal*100, function()
		this.aquireAIPlayer()
	end)
end

function this.unsetGetAITimer()
	--print("unsetGetAITimer..\n")
	this.unsetTimer("get_ai_timer")
end

function this.aquireAIPlayer()
	local num = this.maxPlayerNum - this.currPlayerNum
	local human = 0
	for k, v in pairs(this.playerInfoList) do
		if v and v.userInfo.userType == 1 then
			human = human + 1
		end
	end
	if num > 0 and num <= this.maxPlayerNum-1 and human > 0 then
		--print("aquireAIPlayer..\n")
		local ret = skynet.call("aiManager_s", "lua", "aquireAIPlayer", num, this.coinType)
		if ret.isFind == false then
			this.setGetAITimer()
		end
	end
end

function this.calcUserFactor(userInfo)
	local factor = 2
	if userInfo.rechargeVal and userInfo.rechargeVal > 0 and 
		userInfo.totalGetRedPackVal and userInfo.totalGetRedPackVal > 0 then
		factor = userInfo.totalGetRedPackVal/userInfo.rechargeVal
		if factor < 0.5 then
			factor = 0.5
		end
	end
	return factor
end

function this.checkRedPack()
	this.isStartCheckRedPack = true
	if this.isScoreRace() and this.actInfo and this.actInfo.activitySwitch == "on" then
		for k, v in pairs(this.playerInfoList) do
			if v and v.sid then
				local userInfo = v.userInfo
				local sid = v.sid
				if userInfo.gameOverTimes >= 3 then
					this.getRedPackPlayTiems = userInfo.gameOverTimes
					userInfo.gameOverTimes = 0
					local randomNum = math.random(1,100)
					local redPackVal = 0
					local coinVal = 0
					if this.coinType == 1 then
						userInfo.todayRedPackCount = userInfo.todayRedPackCount + 1
						local isTodayRecharge = false
						if userInfo.lastRechargeDate == userInfo.lastLoginTime and userInfo.todayRechargeVal >= 1200 then
							isTodayRecharge = true
						end

						local rewardPoolRedPackVal = skynet.call("redpackPool_s", "lua", "getRewardRedPack")
						if isTodayRecharge and rewardPoolRedPackVal > 0 then
							redPackVal = rewardPoolRedPackVal
						else
							if userInfo.loginDayCount == 1 and userInfo.todayRedPackCount == 1 then
								redPackVal = 120
							elseif userInfo.loginDayCount == 1 and userInfo.todayRedPackCount == 2 then
								redPackVal = 60
							elseif userInfo.loginDayCount == 1 and userInfo.todayRedPackCount == 3 then
								redPackVal = 60
							elseif userInfo.loginDayCount == 1 and userInfo.todayRedPackCount == 4 then
								redPackVal = 60
							elseif userInfo.loginDayCount == 2 and userInfo.todayRedPackCount == 1 then
								redPackVal = 60
							elseif userInfo.loginDayCount == 5 and userInfo.todayRedPackCount == 2 then
								redPackVal = 120
							elseif userInfo.loginDayCount == 10 and userInfo.todayRedPackCount == 2 then
								redPackVal = 120
							elseif userInfo.loginDayCount == 15 and userInfo.todayRedPackCount == 2 then
								redPackVal = 120
							else
								local function calc_sum(t, i)
									local sum = 0
									for k, v in pairs(t) do
										if k <= i then
											sum = sum + v 
										end
									end
									return sum
								end
								local function calc_redpack(configT, randomVal)
									local redpack, coin = 0, 0
									if randomVal <= calc_sum(configT, 1) then
										coin = 3
									elseif randomVal <= calc_sum(configT, 2) then
										coin = 6
									elseif randomVal <= calc_sum(configT, 3) then
										coin = 9
									elseif randomVal <= calc_sum(configT, 4) then
										redpack = 30
									elseif randomVal <= calc_sum(configT, 5) then
										redpack = 60
									elseif randomVal <= calc_sum(configT, 6) then
										redpack = 120
									end
									return redpack, coin
								end

								local factor = this.calcUserFactor(userInfo)
								if isTodayRecharge then
									if factor > 2 then
										redPackVal, coinVal = 30, 0
									else
										factor = 1
										local rate30 = math.floor(70*factor)
										local maxRange = math.floor(20 + 10 + rate30)
										local randomVal = math.random(1, maxRange)
										local configNotFree = {0,0,0,rate30,20,10}
										redPackVal, coinVal = calc_redpack(configNotFree, randomVal)
									end
								else
									local randomVal = math.random(1, 100)
									local configFree = {55,10,10,15,5,5}
									redPackVal, coinVal = calc_redpack(configFree, randomVal)
									if factor > 2 and redPackVal > 30 then
										redPackVal = 30
									end
								end
							end
						end
						--[[
						if randomNum <= this.actInfo.rate_40 then
							redPackVal = 40
						elseif randomNum <= this.actInfo.rate_80+this.actInfo.rate_40 then
							redPackVal = 80
						elseif randomNum <= this.actInfo.rate_120+this.actInfo.rate_80+this.actInfo.rate_40 then
							redPackVal = 120
						end
						]]
					else
						if randomNum <= this.actInfo.rate_4 then
							redPackVal = 1
						elseif randomNum <= this.actInfo.rate_8+this.actInfo.rate_4 then
							redPackVal = 5
						elseif randomNum <= this.actInfo.rate_12+this.actInfo.rate_8+this.actInfo.rate_4 then
							redPackVal = 50
						end
					end
					this.dispatchRedPackVal = this.dispatchRedPackVal + redPackVal
					userInfo.redPackVal = redPackVal
					userInfo.redPackCoinVal = coinVal
					this.sendPlayer(sid, "redPackStart_ack", {playerId = userInfo.playerId, redPackVal = redPackVal, coinVal = coinVal})
					--[[
					skynet.timeout(30*100, function() 
						if userInfo and userInfo.redPackVal and userInfo.playerId then
							userInfo.redPackVal = 0 
							local nowSid = this.playerInfoList[userInfo.playerId].sid
							this.sendPlayer(nowSid, "redPackOver_ack", {playerId = userInfo.playerId})
						end
					end)
					]]
				end
			end
		end
	end
	skynet.timeout(100*60*5, function()
		this.checkRedPack()
	end)
end

----------------------------- sevevice api -------------------------------
function SAPI.init(conf)
	this.roomTimerTicks = conf.roomTimerTicks or 10
	this.roomNo = conf.roomNo
	this.maxPlayerNum = conf.roomType
	this.maxPlayTimes = conf.playTimes
	this.grabLandlordMode = conf.grabMode
	this.maxBoom = conf.maxBoom
	this.coinType = conf.coinType
	if this.coinType == nil then 
		this.coinType = 1 
	end

	this.currPlayTimes = 0
	this.roomOwner = 1
	this.readyPlayerNum = 0
	this.playResultList = {}
	this.currTotalBoom = 0
	if 1 == this.grabLandlordMode or 2 == this.grabLandlordMode then
		this.currWhoGrab = math.random(1, this.maxPlayerNum)
	end
	this.firstGrabPlayerId = 0
	this.firstStartPlayerId = this.currWhoGrab
	this.isFirstOneGrab = false

	this.startGameTimer()

	this.setTimer("destroyRoom", 2*3600*100, function() 
		skynet.call("roomManager_s", "lua", "destroyRoom", this.roomNo)
	end)
	return 0
end

function SAPI.joinRoom(agent)
	-- AI
	if this.isScoreRace() then
		this.setGetAITimer()
	end
	local sid = agent.sid
	local userType = agent.userType
	local playerId = 0
	local boomNum = 0
	local spring = 1
	local userInfo = {}
	userInfo.userType = userType
	for k, v in pairs(agent.userInfo) do
		userInfo[k] = v
	end
	-- First check if this user join room before
	for k, v in pairs(this.playerInfoList) do
		if v and userInfo.userId == v.userInfo.userId then
			playerId = v.playerId
			v.sid = sid
			v.userInfo.redPackVal = 0
			v.userInfo.redPackCoinVal = 0
		end
	end
	-- If not join room before, create a new game player
	if playerId == 0 then
		if this.maxPlayerNum == this.currPlayerNum then
			return {errno = -1}
		end
		this.currPlayerNum = this.currPlayerNum + 1
		playerId = this.assignPlayerId()
		userInfo.status = -1
		userInfo.isLandlord = 1 -- 1 is not landlord, 2 is landlord
		userInfo.boom = 0
		userInfo.leftPoker = 0
		userInfo.playerId = playerId
		userInfo.hasPlay = 0
		userInfo.spring = 1
		userInfo.playTimes = 0
		userInfo.gameOverTimes = 0
		userInfo.grabRecord = -1
		userInfo.redPackVal = 0
		userInfo.redPackCoinVal = 0
		if this.isScoreRace() == false then
			userInfo.score = 0
		end

		this.playerInfoList[playerId] = {
			sid = sid,
			playerId = playerId,
			boomNum = 0,
			spring = 1, -- 1 no spring, 2 spring
			userInfo = userInfo
		}
	end

	-- notify all join user info
	--skynet.timeout(5, this.joinNtf)
	return {playerId=playerId, maxPlayTimes=this.maxPlayTimes, grabMode=this.grabLandlordMode, roomType=this.maxPlayerNum, maxBoom=this.maxBoom}
end

function SAPI.joinRoomOk(msg)
	local playerId = msg.playerId
	this.joinRoomOkNtf(playerId)
end

function SAPI.getReady(playerId)
	local playerInfo = this.playerInfoList[playerId]
	if playerInfo == nil then return end
	if this.isScoreRace() then
		if this.coinType == 1 and playerInfo.userInfo.score < 24 then return end
		if this.coinType == 2 and playerInfo.userInfo.score2 < 24 then return end
	end
	if playerInfo.userInfo.status >= 2 then return end
	this.unsetTickTimerNtf("r", playerId)
	playerInfo.userInfo.status = 2 -- now ready
	local readyList = {}
	for k, v in pairs(this.playerInfoList) do
		if v and v.userInfo.status == 2 then
			local readyPlayerId = v.playerId
			table.insert(readyList, readyPlayerId)
		end
	end

	-- check if all players get ready
	this.sendAllPlayer("getReady_ntf", {readyList = readyList})
	this.readyPlayerNum = #readyList
	if this.readyPlayerNum == this.maxPlayerNum then
		skynet.timeout(20, this.startGame)
	end
end

function SAPI.startGame(msg)
	if this.readyPlayerNum == this.maxPlayerNum then
		this.unsetGetAITimer()
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

function SAPI.leave(playerId, t)
	print ("player "..playerId.." leave room")
	this.leaveRoom(playerId, t)
	--[[
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
	]]
end

function SAPI.dismissRoom(msg)
	local playerId = msg.playerId
	local result = msg.result
	this.dismissInfo[playerId] = result
	local dismissNum = 0
	for k, v in pairs(this.dismissInfo) do
		if v then
			dismissNum = dismissNum + 1
		end
	end
	--print("---------"..dismissNum)
	--print("---------"..this.currPlayerNum)
	--print("---------"..this.maxPlayerNum)
	if this.currPlayerNum < this.maxPlayerNum then
		this.leaveRoom(playerId, 1)
		this.dismissInfo = {}
		return
	end
	--local dismissInfoList = {}
	--for k, v in pairs(this.dismissInfo) do
	--	if v then
	--		table.insert(dismissInfoList, {playerId=k, result=v})
	--	end
	--end
	--this.sendAllPlayer("dismissRoom_ntf", {dismissInfoList = dismissInfoList})
	if dismissNum == 1 then
		this.setSecondTimer("dis", 5*60, function(timerVal)
			if timerVal == 0 then
				this.sendAllPlayer("stopAlarmTimer_ntf", {playerId = playerId, timerType = timerType})
				this.roomOver(30)
				this.dismissInfo = {}
			else
				for k, v in pairs(this.playerInfoList) do
					if v and v.sid and v.userInfo then
						if this.dismissInfo[v.userInfo.playerId] == nil or true then
							this.sendPlayer(v.sid, "alarmTimer_ntf", {playerId = playerId, timerVal = timerVal, timerType = "dis"})
						end
					end
				end

				local dismissInfoList = {}
				for k, v in pairs(this.dismissInfo) do
					if v then
						table.insert(dismissInfoList, {playerId=k, result=v})
					end
				end
				this.sendAllPlayer("dismissRoom_ntf", {whoDismiss=playerId, dismissInfoList = dismissInfoList})				
			end
		end)
	end
	
	if dismissNum >= this.maxPlayerNum-1 then
		skynet.timeout(300, function()
			this.sendAllPlayer("stopAlarmTimer_ntf", {playerId = playerId, timerType = "dis"})
			this.unsetSecondTimer("dis")
			local isAllAgree = true
			for k, v in pairs(this.dismissInfo) do
				if v ~= 2 then
					isAllAgree = false
					break
				end
			end
			if isAllAgree then
				this.roomOver(30)
			end
			this.dismissInfo = {}
		end)
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
	print ("player "..playerId.." disconnect")
	if this.playerInfoList[playerId] then 
		this.playerInfoList[playerId].sid = nil
	end
end

function SAPI.getCurrPlayerNum(msg)
	local factor = msg.factor
	if factor <= 4 then
		return this.currPlayerNum
	else
		local playerNum = 0
		for k, v in pairs(this.playerInfoList) do
			if v then
				local userInfo = v.userInfo
				local userFactor = this.calcUserFactor(userInfo)
				if userFactor > 2.5 then
					playerNum = playerNum + 1
				end
			end
		end
		if playerNum == 0 then
			playerNum = 3
		end
		return playerNum
	end
end

function SAPI.getRedPack(msg)
	local playerId = msg.playerId
	if this.playerInfoList[playerId] then
		local result = 1
		local redPackVal = 0
		local coinVal = 0
		if this.playerInfoList[playerId].userInfo.redPackVal > 0 or 
			this.playerInfoList[playerId].userInfo.redPackCoinVal > 0 then
			result = 2
			redPackVal = this.playerInfoList[playerId].userInfo.redPackVal
			coinVal = this.playerInfoList[playerId].userInfo.redPackCoinVal
			this.playerInfoList[playerId].userInfo.redPackVal = 0
			this.playerInfoList[playerId].userInfo.redPackCoinVal = 0
			this.playerInfoList[playerId].userInfo.score = this.playerInfoList[playerId].userInfo.score + coinVal
		end
		skynet.call(this.playerInfoList[playerId].sid, "lua", "getRedPack_ack", {result = result, redPackVal = redPackVal, coinVal = coinVal, playTurn=this.getRedPackPlayTiems})
	end
end

function SAPI.findByUserId(userId)
	local ret = 0
	for k, v in pairs(this.playerInfoList) do
		if v and userId == v.userInfo.userId then
			ret = 1
			break
		end
	end
	return ret
end

function SAPI.ai_getAllPokerList(msg)
	local ret = {}
	for k, v in pairs(this.playerInfoList) do
		if v then
			ret[k] = {userType=v.userInfo.userType, pokerList=this.allPlayerPokerSet[k]}
		end
	end
	return ret
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
	print("now time: "..os.time())
	math.randomseed(os.time())
end)
