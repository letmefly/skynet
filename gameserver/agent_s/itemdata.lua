local cjson = require "cjson"
local skynet = require "skynet"
local userdata = require "agent_s.userdata"
local userdata = require "agent_s.userdata"

local itemdata = {}

function itemdata:plus_instantitem(itemid, amount)
	local is_exist = false
	for k,v in pairs(self.data) do
		if v.instant_item_id == itemid then
			is_exist = true
			v.amount = v.amount + amount
		end
	end
	-- if not exist, then insert
	if false == is_exist then
		local new_item = {
			user_id = userdata:get("user_id"),
			instant_item_id = itemid,
			amount = amount
		}
		table.insert(self.data, new_item)
	end
end

function itemdata:load()
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_instant_items", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function itemdata:save()
	local select_result = skynet.call("db_s", "lua", "update_instant_items", self.data)
	return select_result
end

function itemdata:get_instantitem_amount(itemid)
end

function itemdata:cost_instantitem(itemid, amount)

end

function itemdata:get_instantitems()
	-- body
end

return itemdata
