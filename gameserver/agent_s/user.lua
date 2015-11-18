local userdata = require "agent_s.userdata"

local user = {}

function user:register(msg)
	local ret = userdata:newdata(msg.email, msg.password)
	local msg_ack = {
		err = ret.errno 
	}
	return msg_ack
end

function user:login(msg)
	local ret = userdata:load(msg.email)
	local errno = ret.errno
	if ret.errno == 0 and userdata:get("password") ~= msg.password then
		errno = 1002
	end
	local msg_ack = {
		err = errno
	}
	return msg_ack
end

function user:logout()
	userdata:save()
end

function user:change_nickname(msg)
end

return user

