local skynet = require "skynet"
local cjson = require "cjson"
local userdata = require "agent_s.userdata"

local frienddata = {data = {}}

function frienddata:load(userid)
	local userid = userdata:get("user_id")
	local result = skynet.call("db_s", "lua", "select_friends", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function frienddata:get_friendinfo(friend_userid)
	for k,v in pairs(self.data) do
		if v.user_id == friend_userid then
			return v
		end
	end
	return nil
end

return frienddata
