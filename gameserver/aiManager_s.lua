local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local this = {}
local SAPI = {}
local aiAgentList = {}
local aiUserList = {}

this.aiUseNum = 0

function this.aquireAiUserId()
	local tmpKey = nil
	local ret = nil
	for i = 1, #aiUserList do
		if aiUserList[i] then
			tmpKey = i
			break
		end
	end
	if tmpKey then
		ret = aiUserList[tmpKey]
		table.remove(aiUserList, tmpKey)
	end
	this.aiUseNum = this.aiUseNum + 1
	return ret
end

function SAPI.aquireAIPlayer(num)
	print("----------------aiUseNum:"..this.aiUseNum.."-------------------")
	local ret = {}
	ret.isFind = false
	-- create ai agent
	for i = 1, num do
		skynet.timeout((i-1)*300, function()
			local sid = skynet.newservice("aiAgent_s")
			local version = 1
			local userId =  this.aquireAiUserId()
			if userId then
				local authCode = "123456"
				skynet.call(sid, "lua", "start", {version = version, userId = userId, authCode = authCode})
				aiAgentList[userId] = sid
				ret.isFind = true
			end
		end)
	end
	return ret
end

function SAPI.releaseAIUser(userId)
	table.insert(aiUserList, userId)
	aiAgentList[userId] = nil
	this.aiUseNum = this.aiUseNum - 1
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
	skynet.register("aiManager_s")
	for i = 1, 103 do
		aiUserList[i] = "score_race_ai_"..i
	end
end)


