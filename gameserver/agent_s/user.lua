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
	local userid = msg.userid
	userdata:load(userid)
end

function user:logout()
	userdata:save()
end

function user:change_nickname(msg)
end

return user

