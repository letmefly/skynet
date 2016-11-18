local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"

local treasuredata = {data = {}}

function treasuredata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_treasures", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function treasuredata:save()
	local result = skynet.call("db_s", "lua", "update_treasures", self.data)
	return result
end

function treasuredata:get_slottreasures()
	local slottreasures = {}
	for k,v in pairs(self.data) do
		local slottreasure = {
			treasure_id = v.treasure_id,
			treasure_info_id = v.treasure_info_id,
			level = v.level,
			slot_number = v.slotnumber
		}
		table.insert(slottreasures, slottreasure)
	end
	return slottreasures
end

return treasuredata
