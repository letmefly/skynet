local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"
local config = require "config"

local conf = {
	host = config["mysql_host"],
	port = config["mysql_port"],
	database = config["mysql_database"],
	user = config["mysql_user"],
	password = config["mysql_password"],
	max_packet_size = config["mysql_max_packet_size"]
}

local SERVICE_API = {}
local db

function SERVICE_API.insert_user(params)
end

function SERVICE_API.select_user(params)
end

function SERVICE_API.update_user(params)
end

skynet.start(function()
	db = mysql.connect({
		host = conf.host,
		port = conf.port,
		database = conf.database,
		user = conf.user,
		password = conf.password,
		max_packet_size = conf.max_packet_size,
		on_connect = function(param_db)
			print("[db]mysql connect success")
			param_db:query("set charset utf8")
		end
	})
	if not db then
		print("[db]failed to connect mysql")
	end

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register("db_s")
	print("[db]start service db..")
end)

