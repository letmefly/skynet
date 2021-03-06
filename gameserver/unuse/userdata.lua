local cjson = require "cjson"
local skynet = require "skynet"
local constants = require "config.define_constants"

local userdata = {data = {}}

function userdata:newdata(email, password)
	local data = {
		email = email,
		password = password,
		nickname = constants["user_default_nickname"],
		level = constants["user_default_level"],
		exp_point = constants["user_default_exp"],
		money = constants["user_default_money"],
		cash = constants["user_default_cash"],
		heart = constants["user_default_heart"],
		lottery_point = constants["user_default_lottery"],
		lottery_high_coupon = constants["user_lottery_high_coupon"],
		lottery_coupon = constants["user_lottery_coupon"],
		character_id = constants["user_default_character_id"],
		treasure_inventory = constants["user_default_treasure"],
		best_score = 0,
		os_type = 1,
		os_version = "",
		market_type = 1,
		attendance_count = 0,
		attendance_date = "",
		push_id = "",
		create_date = os.time(),
		update_date = "",
		delete_date = "",
		login_date = "",
		create_ip = "",
		update_ip = "",
		delete_ip = "",
		login_ip = "",
		version = 1,
		status = 1
	}

	local select_result = skynet.call("db_s", "lua", "select_user", {email = email})
	-- user exist already
	if select_result.errno == 0 and next(select_result.data) ~= nil then
		return {errno = 10000, data = {}}
	end
	local insert_result = skynet.call("db_s", "lua", "insert_user", data)
	if insert_result.errno ~= 0 then
		return {errno = 10001, data = {}}
	end
	return {errno = 0, data = {}}
end

function userdata:load(email)
	local result = skynet.call("db_s", "lua", "select_user", {email = email})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
		-- for k, v in pairs(result.data[1]) do
		-- 	self.data[k] = v
		-- end
	end
	-- print(cjson.encode(self.data))
	return result
end

function userdata:clear()
	self.data = nil
end

function userdata:save()
	local select_result = skynet.call("db_s", "lua", "update_user", self.data)
	return select_result
end

function userdata:set(key, value)
	self.data[1][key] = value
end

function userdata:get(key)
	return self.data[1][key]
end

function userdata:cost_heart(heart_num)
	self.data[1]["heart"] = self.data[1]["heart"] - heart_num
end

-- must check level up
function userdata:plus_exp_point(point_num)
	self.data[1]["exp_point"] = self.data[1]["exp_point"] + point_num
end

function userdata:plus_money(money_num)
	self.data[1]["money"] = self.data[1]["money"] + money_num
end

return userdata

