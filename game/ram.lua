local skynet = require "skynet"
local redis = require "redis"

local conf = {
	host = "127.0.0.1",
	port = 6379,
	db = 0
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

	skynet.register("ram")
end)

