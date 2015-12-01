local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"
local constants = require "config.define_constants"

local gamedata = {data = {}}

function gamedata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_stages", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data["stages"] = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function gamedata:save()
	local result = skynet.call("db_s", "lua", "update_stages", self.data["stages"])
	return result
end

function gamedata:get_user_stageinfo(stageid)
	for k,v in pairs(self.data["stages"]) do
		if v.stage_id == stageid then
			return v
		end
	end
	return nil
end

function gamedata:update_user_stageinfo(stageinfo)
	local is_exist = false
	for k,v in pairs(self.data["stages"]) do
		if v.stage_id == stageinfo.stage_id then
			is_exist = true
			v.clear_type = stageinfo.clear_type
			v.score = stageinfo.score
			v.clear_count = stageinfo.clear_count
			v.create_date = stageinfo.create_date
			v.perfect = stageinfo.perfect
		end
	end
	return is_exist
end

function gamedata:insert_user_stageinfo(stageinfo)
	local is_exist = false
	for k,v in pairs(self.data["stages"]) do
		if v.stage_id == stageinfo.stage_id then
			is_exist = true
		end
	end
	if false == is_exist then
		table.insert({
			user_id = userdata:get("user_id")
			stage_id = stageinfo.stage_id,
			clear_type = stageinfo.clear_type,
			score = stageinfo.score,
			clear_count = stageinfo.clear_count,
			create_date = stageinfo.create_date,
			perfect = stageinfo.perfect,
			best_score = 0
		})
	end
	return ~is_exist
end

return gamedata
