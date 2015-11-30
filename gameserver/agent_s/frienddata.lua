local frienddata = {data = {}}

function frienddata:load(userid)
	local result = skynet.call("db_s", "lua", "select_friends", {user_id = userid})
	if result.errno == 0 and next(result.data) ~= nil then
		self.data = result.data
	end
	-- print(cjson.encode(self.data))
	return result
end

function frienddata:get_friendinfo(friend_userid)
	return
end

return frienddata
