local skynet = require "skynet"
local nothing = require "skynet.manager"
local mysql = require "mysql"
local cjson = require "cjson"
local config = require "dbconf"

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

local function get_insert_sql(tablename, insertdata)
	local keys, values = "", ""
	for k, v in pairs(insertdata) do
		keys = keys .. k .. ","
		if type(v) == "string" then
			values = values.."'"..v.."'"..","
		else
			values = values .. v .. ","
		end
	end
	keys = string.sub(keys, 1, -2)
	values = string.sub(values, 1, -2)
	local sql = "INSERT INTO " .. tablename .. " (" .. keys .. ")" .. " VALUES " .. "(" .. values .. ")"
	return sql
end

local function get_insert_update_sql(tablename, insertdata)
	local keys, values = "", ""
	local updatestr = ""
	for k, v in pairs(insertdata) do
		keys = keys .. k .. ","
		if type(v) == "string" then
			values = values.."'"..v.."'"..","
			updatestr = updatestr..k.."=".."'"..v.."'"..","
		else
			values = values .. v .. ","
			updatestr = updatestr..k.."=".."'"..v.."'"..","
		end
	end
	keys = string.sub(keys, 1, -2)
	values = string.sub(values, 1, -2)
	updatestr = string.sub(updatestr, 1, -2)
	local sql = "INSERT INTO " .. tablename .. " (" .. keys .. ")" .. " VALUES " .. "(" .. values .. ")".." ON DUPLICATE KEY UPDATE "..updatestr
	return sql
end

local function get_update_sql(tablename, searchkey, updatedata)
	local str = ""
	for k, v in pairs(updatedata) do
		if k ~= searchkey then
			if type(v) == "string" then
				str = str..k.."=".."'"..v.."'"..","
			else
				str = str..k.."="..v..","
			end
		end
	end
	str = string.sub(str, 1, -2)
	local searchvalue = updatedata[searchkey]
	if type(searchvalue) == "string" then
		searchvalue = "'"..searchvalue.."'"
	end
	local sql = "UPDATE "..tablename.." SET "..str.." WHERE "..searchkey.."="..searchvalue
	return sql
end

local function get_select_sql(tablename, conditions)
	local str = ""
	for k, v in pairs(conditions) do
		if type(v) == "string" then
			str = str..k.."=".."'"..v.."'"..","
		else
			str = str..k.."="..v..","
		end
	end
	str = string.sub(str, 1, -2)
	local sql = "SELECT * FROM "..tablename.." WHERE "..str
	return sql
end

local function do_select(tablename, conditions)
	local sql = get_select_sql(tablename, conditions)
	local result = db:query(sql)
	if result.badresult then
		print("[db_s]err: db query fail..")
		print(cjson.encode(result))
		return {errno = result.errno, data = {}}
	end
	return {errno = 0, data = result}
end

local function do_insert_update(tablename, data)
	for k,v in pairs(data) do
		local sql = get_insert_update_sql(tablename, v)
		local result = db:query(sql)
		if result.badresult then
			print("[db_s]err: db query fail..")
			print(cjson.encode(result))
			return {errno = result.errno, data = {}}
		end
	end
	return {errno = 0, data = {}}
end


function SERVICE_API.insert_user(data)
	local sql = get_insert_sql("op_users", data)
	local result = db:query(sql)
	if result.badresult then
		print("[db_s]err: db query fail..")
		print(cjson.encode(result))
		return {errno = result.errno, data = {}}
	end
	return {errno = 0, data = result}
end

function SERVICE_API.select_user(conditions)
	return do_select("op_users", conditions)
end

function SERVICE_API.update_user(data)
	return do_insert_update("op_users", data)
end


function SERVICE_API.select_friends(conditions)
	return do_select("op_users_friends", conditions)
end

function SERVICE_API.update_friends(data)
	return do_insert_update("op_users_friends", data)
end


function SERVICE_API.select_characters(conditions)
	return do_select("op_users_characters", conditions)
end

function SERVICE_API.update_characters(data)
	return do_insert_update("op_users_characters", data)
end

function SERVICE_API.select_skills(conditions)
	return do_select("op_users_skills", conditions)
end

function SERVICE_API.update_skills(data)
	return do_insert_update("op_users_skills", data)
end

function SERVICE_API.select_treasures(conditions)
	return do_select("op_users_treasures", conditions)
end

function SERVICE_API.update_treasures(data)
	return do_insert_update("op_users_treasures", data)
end

function SERVICE_API.select_instant_items(conditions)
	return do_select("op_users_instant_items", conditions)
end

function SERVICE_API.update_instant_items(data)
	return do_insert_update("op_users_instant_items", data)
end

function SERVICE_API.select_stages(conditions)
	return do_select("op_users_stages", conditions)
end

function SERVICE_API.update_stages(data)
	return do_insert_update("op_users_stages", data)
end

function SERVICE_API.insert_message(data)
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

