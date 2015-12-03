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
local ssdb_client

function SERVICE_API.update_score(params)
	local userid = params.userid
	local score = params.score
	local rankname = "rank_"..os.date("%Y%m%d")
	ssdb_client:zadd(rankname, score, userid)
end

function SERVICE_API.get_rank(params)
	local userid = params.userid
	local rankname = "rank_"..os.date("%Y%m%d")
	local rank = ssdb_client:zrank(rankname, userid)
	return rank
end

function SERVICE_API.get_score(params)
	local userid = params.userid
	local rankname = "rank_"..os.date("%Y%m%d")
	local score = ssdb_client:zscore(rankname, userid)
	return score
end

function SERVICE_API.get_rank_count(params)
	local rankname = "rank_"..os.date("%Y%m%d")
	local count = ssdb_client:zcount(rankname, 0, 2147483647)
	return count
end

skynet.start(function()
	ssdb_client = ssdb.connect({host="127.0.0.1", port=8880})
	if not ssdb_client then
		print("[ram]failed to connect redis")
	end

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register("ram_s")

	-- local rankname = "rank_"..os.date("%Y%m%d")
	-- ssdb_client:zadd(rankname, 12300, "chris1")
	-- ssdb_client:zadd(rankname, 12400, "chris2")
	-- ssdb_client:zadd(rankname, 12500, "chris3")
	-- ssdb_client:zadd(rankname, 12600, "chris4")
	-- ssdb_client:zadd(rankname, 12700, "chris5")
	-- ssdb_client:zadd(rankname, 12800, "chris6")
	-- ssdb_client:zadd(rankname, 12900, "chris7")
	-- print(cjson.encode(ssdb_client:zrange(rankname, 0, -1, "WITHSCORES")))
	-- print(rankname)

	print("[ram]start service ram...")
end)