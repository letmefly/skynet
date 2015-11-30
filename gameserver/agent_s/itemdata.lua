local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"

local itemdata = {}

function itemdata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_instant_items", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function itemdata:get_instantitem_amount(itemid)
end

function itemdata:cost_instantitem(itemid, num)

end

function itemdata:get_instantitems()
	-- body
end

return itemdata
