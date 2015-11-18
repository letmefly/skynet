-- local default_config = require "luaconfig.userdata_default_config"

local userdata = {}

function userdata:newdata(email, password)
	local insert_data = {
		email = email,
		password = password,
		nickname = "",
		

	}
end

function userdata:load(userid)
	-- for k, v in pairs(data) do
	-- 	self[k] = v
	-- end
end

function userdata:save()
end

function userdata:set(key, value)
	self[key] = value
end

function userdata:get(key)
	return self[key]
end

return userdata

