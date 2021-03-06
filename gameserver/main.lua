local skynet = require "skynet"

local max_client = 64

skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)

	require("room_s.test_pokerType").test()

	--skynet.newservice("ram_s")
	--skynet.newservice("db_s")
	skynet.newservice("roomManager_s")
	skynet.newservice("aiManager_s")
	skynet.newservice("redpackPool_s")
	local watchdog_s = skynet.newservice("watchdog_s")
	
	skynet.call(watchdog_s, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	
	print("Watchdog listen on ", 8888)

	skynet.exit()
end)
