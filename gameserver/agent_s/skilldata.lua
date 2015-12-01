local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"

local skilldata = {data = {}}

function skilldata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_skills", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function skilldata:save()
	local result = skynet.call("db_s", "lua", "update_skills", self.data)
	return result
end

function skilldata:get_slotskills()
	local slotskills = {}
	for k,v in pairs(self.data) do
		local slotskill = {
			skill_id = v.skill_id,
			skill_info_id = v.skill_info_id,
			level = v.level,
			slot_number = v.slot_number
		}
		table.insert(slotskills, slotskill)
	end
	return slotskills
end

return skilldata
