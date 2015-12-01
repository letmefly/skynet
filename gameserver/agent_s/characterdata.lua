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
end

function characterdata:get_slotcharacters(userid, character_id)
	return
end

return characterdata
