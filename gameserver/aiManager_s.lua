local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register

local this = {}
local SAPI = {}
local aiAgentList = {}
local aiUserList = {}
aiUserList[1] = "13343421653"
aiUserList[2] = "13343425808"

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
	return ret
end

function SAPI.aquireAIPlayer(num)
	local ret = {}
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
			end
		end)
	end
	return ret
end

function SAPI.releaseAIUser(userId)
	table.insert(aiUserList, userId)
	aiAgentList[userId] = nil
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
end)


