-- local skynet = require "skynet"
-- local nothing = require "skynet.manager"
-- local redis = require "redis"
-- local config = require "dbconf"

-- local conf = {
-- 	host = config["redis_host"],
-- 	port = config["redis_port"],
-- 	db = config["redis_db"]
-- }

-- local SERVICE_API = {}
-- local redis_client

-- function SERVICE_API.get_ranking(params)
-- end

-- skynet.start(function()
-- 	redis_client = redis.connect(conf)
-- 	if not redis_client then
-- 		print("[ram]failed to connect redis")
-- 	end

-- 	skynet.dispatch("lua", function(_,_, command, ...)
-- 		local f = SERVICE_API[command]
-- 		skynet.ret(skynet.pack(f(...)))
-- 	end)

-- 	skynet.register("ram_s")

-- 	print("[ram]start service ram...")
-- end)


local skynet = require "skynet"
local nothing = require "skynet.manager"
local ssdb = require "ssdb"
local cjson = require "cjson"
local config = require "dbconf"

-- local conf = {
-- 	host = config["redis_host"],
-- 	port = config["redis_port"],
-- 	db = config["redis_db"]
-- }

local SERVICE_API = {}
local db

function SERVICE_API.update_score(params)
	local userid = params.userid
	local score = params.score
	local rankname = "rank_"..os.date("%Y%m%d")
	local result = db:zadd(rankname, score, userid)
	return result
end

function SERVICE_API.get_rank(params)
	local userid = params.userid
	local rankname = "rank_"..os.date("%Y%m%d")
	local rank = db:zrank(rankname, userid)
	return rank
end

function SERVICE_API.get_score(params)
	local userid = params.userid
	local rankname = "rank_"..os.date("%Y%m%d")
	local score = db:zscore(rankname, userid)
	return score
end

function SERVICE_API.get_rank_count(params)
	local rankname = "rank_"..os.date("%Y%m%d")
	local count = db:zcount(rankname, 0, 2147483647)
	return count
end

skynet.start(function()
	db = ssdb.connect({host="127.0.0.1", port=8880})
	if not db then
		print("[ram]failed to connect redis")
	end

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register("ram_s")
	print("[ram]start service ram...")
end)

