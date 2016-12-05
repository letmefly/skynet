local skynet = require "skynet"
local nothing = require "skynet.manager"

function SERVICE_API.send_mail(params)
	local receive_user_id = params.receive_user_id
	local agentservice = "agent_"..tostring(receive_user_id)
	if skynet.queryservice(true, agentservice) then
		skynet.send(agentservice, "lua", "has_new_mail", params)
	end
	skynet.send("db_s", "lua", "insert_message", params)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = SERVICE_API[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.register("mail_s")

	print("[ram]start service mail_s...")
end)

