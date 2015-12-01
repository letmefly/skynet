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


function frienddata:save()
	local result = skynet.call("db_s", "lua", "update_friends", self.data)
	return result
end


function frienddata:add_friend(friend_userid)
	local is_exist = false
	for k,v in pairs(self.data) do
		if v.user_id == friend_userid then
			is_exist = true
			return 2000
		end
	end
	if false == is_exist then
		local newfriend = {
			user_id = userdata:get("user_id"),
			friend_user_id = friend_userid,
			create_date = os.time(),
			delete_date = "",
			play_date = "",
			status = 3
		}
		table.insert(self.data, newfriend)
	end
	return 0
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
