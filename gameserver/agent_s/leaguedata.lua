local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"

local leaguedata = {}

function leaguedata:load()
end

function leaguedata:save()
end

function leaguedata:update_user_leagueranking(score)
	local userid = userdata:get("user_id")
	local result = skynet.call("ram_s", "lua", "update_score", {userid=userid, score=score})
end

return leaguedata

