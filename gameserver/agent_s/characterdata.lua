local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"

local characterdata = {data = {}}

function characterdata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_characters", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function characterdata:save()
	local result = skynet.call("db_s", "lua", "update_characters", self.data)
	return result
end

function characterdata:get_slotcharacter(character_id)
	for k,v in pairs(self.data) do
		if v.character_id == character_id then
			return v
		end
	end
	return nil
end

return characterdata
