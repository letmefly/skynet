local skynet = require "skynet"
local nothing = require "skynet.manager"
local redis = require "redis"
local config = require "dbconf"

local conf = {
	host = config["redis_host"],
	port = config["redis_port"],
	db = config["redis_db"]
}

local SERVICE_API = {}
local redis_client

function SERVICE_API.get_ranking(params)
end

skynet.start(function()
	redis_client = redis.connect(conf)
	if not redis_client then
		print("[ram]failed to connect redis")
	end

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register("ram_s")

	print("[ram]start service ram...")
end)

