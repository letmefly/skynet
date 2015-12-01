local userdata = require "agent_s.userdata"
local frienddata = require "agent_s.frienddata"
local itemdata = require "agent_s.itemdata"

local user = {}

function user:register(msg)
	local ret = userdata:newdata(msg.email, msg.password)
	local msg_ack = {
		errno = ret.errno 
	}
	return msg_ack
end

function user:login(msg)
	local msg_ack = {errno = 0}

	-- 1. load user data
	local ret = userdata:load(msg.email)
	if ret.errno ~= 0 then
		msg_ack["errno"] = ret.errno
		return msg_ack
	end
	if ret.errno == 0 and userdata:get("password") ~= msg.password then
		msg_ack["errno"] = 1002
		return msg_ack
	end

	-- 2. load friend data
	local ret = frienddata:load()
	if ret.errno ~= 0 then
		msg_ack["errno"] = ret.errno
		return msg_ack
	end

	-- 3. load item data
	local ret = itemdata:load()
	if ret.errno ~= 0 then
		msg_ack["errno"] = ret.errno
		return msg_ack
	end
	-- itemdata:plus_instantitem(99, 8888)
	-- itemdata:save()


	msg_ack["attendanceCount"] = userdata:get("attendance_count")
	msg_ack["heart"] = userdata:get("heart")
	msg_ack["heartTime"] = 0
	msg_ack["heartTimeSeconds"] = 0
	msg_ack["vipRemainSeconds"] = 1
	msg_ack["attendanceDays"] = 0
	msg_ack["attendanceReward"] = 0
	msg_ack["bannerID"] = "1"
	msg_ack["bannerImageURL"] = "2"
	msg_ack["userID"] = userdata:get("user_id")
	msg_ack["nickname"] = userdata:get("nickname")
	msg_ack["level"] = userdata:get("level")
	msg_ack["exp"] = userdata:get("exp_point")
	msg_ack["money"] = userdata:get("money")
	msg_ack["cash"] = userdata:get("cash")
	msg_ack["tutorial"] = userdata:get("tutorial")
	msg_ack["review"] = userdata:get("review")
	msg_ack["inviteCount"] = userdata:get("invite_count")
	msg_ack["lotteryPoint"] = userdata:get("lottery_point")
	msg_ack["lotteryHighCoupon"] = userdata:get("lottery_high_coupon")
	msg_ack["lotteryCoupon"] = userdata:get("lottery_coupon")
	msg_ack["skillSlot"] = userdata:get("skill_slot")
	msg_ack["treasureSlot"] = userdata:get("treasure_slot")
	msg_ack["treasureInventory"] = userdata:get("treasure_inventory")
	msg_ack["bestScore"] = userdata:get("best_score")
	msg_ack["agreeMessage"] = userdata:get("agree_message")
	msg_ack["daliyEventActive"] = 0
	msg_ack["videoRebornTimes"] = userdata:get("video_reborn_times")
	msg_ack["watchVideoTimes"] = userdata:get("watch_video_times")

	return msg_ack
end

function user:logout()
	userdata:save()
end

function user:change_nickname(msg)
end

return user

