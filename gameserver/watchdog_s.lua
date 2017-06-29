local skynet = require "skynet"
local netpack = require "netpack"

local CMD = {}
local SOCKET = {}
local gate
local agent = {}

local online_user_num = 0

function SOCKET.open(fd, addr)
	online_user_num = online_user_num + 1
	skynet.error("New client from : " .. addr .. ", online user number "..online_user_num)
	agent[fd] = skynet.newservice("agent_s")
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self(), onlineUserNum = online_user_num })
end

local function close_agent(fd)
	online_user_num = online_user_num - 1
	skynet.error("online user number "..online_user_num)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
end

function CMD.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

local function testapi()
	-- test pbc api
	--local testapi = skynet.newservice("testapi")
	-- local ret = skynet.call(testapi, "lua", "testpbc", {a="hello", b=123})
	-- print(ret.result)
	local ret = skynet.call("redpackPool_s", "lua", "getRewardRedPack",{})
	print("shitttttttt:"..ret)
	
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")

	--just for test api
	 testapi()
end)
