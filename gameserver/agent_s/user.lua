local userdata = require "agent_s.userdata"

local user = {}

function user:register(msg)
	print("email:" .. msg.email)
	print("password:" .. msg.password)
	return "user_register_ack", {err = 0}
end

function user:login(msg)
	local userid = msg.userid
	userdata:load(userid)
end

function user:logout()
	userdata:save()
end

function user:change_nickname(msg)
end

return user

