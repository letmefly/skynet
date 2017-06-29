local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local queue = require "skynet.queue"
local netutil = require "agent_s.netutil"
local cjson = require "cjson"

local cs = queue() 
local this = {}
local SERVICE_API = {}

local function calc_getRewardRedPack()
	local ret = 0
	local postData = {}
	local status, body = netutil.http_post("service_getRewardPool.php", postData)
	local poolInfo = cjson.decode(body)
	this.rewardPoolVal = poolInfo.rewardPoolVal
	local randomVal = math.random(1, 100)
	if this.rewardPoolVal > 600 and (randomVal >= 50 and randomVal < 55) then
		postData = {}
		postData.rewardPoolVal = 600
		local status, body = netutil.http_post("service_subRewardPool.php", postData)
		ret = 600
	end
	return ret
end

function SERVICE_API.getRewardRedPack()
	local ret = calc_getRewardRedPack()
	return ret
end

function SERVICE_API.getRewardPoolVal()
	local postData = {}
	local status, body = netutil.http_post("service_getRewardPool.php", postData)
	local poolInfo = cjson.decode(body)
	this.rewardPoolVal = poolInfo.rewardPoolVal
	this.rewardPoolVal = 2000
	return this.rewardPoolVal
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
	skynet.register("redpackPool_s")
end)
