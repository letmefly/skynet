local cjson = require "cjson"
local userdata = require "agent_s.userdata"
local gamedata = require "agent_s.gamedata"
local frienddata = require "agent_s.frienddata"
local shopdata = require "agent_s.shopdata"
local characterdata = require "agent_s.characterdata"
local skilldata = require "agent_s.skilldata"
local treasuredata = require "agent_s.treasuredata"
local itemdata = require "agent_s.itemdata"
local configdata = require "agent_s.configdata"

local game = {}

function game:set_playcode(playcode)
	self.playcode = playcode
end
function game:get_playcode()
	return self.playcode
end

function game:lobby(msg)
end

function game:start(msg)
	local msg_ack = {errno = 0}
	local cost_heart_num = 1
	if userdata:get("heart") < cost_heart_num then
		msg_ack["errno"] = 202
		return msg_ack
	end

	local friendinfo = frienddata:get_friendinfo(msg["friendUserID"])
	if msg["friendUserID"] > 0 and friendinfo == nil then
		msg_ack["errno"] = 101
		return msg_ack
	end

	local instantitem_ok = true
	for k, v in pairs(msg["useItems"]) do
		local amount = itemdata:get_instantitem_amount(v)
		if amount and amount <= 0 then
			instantitem_ok = false
			break
		end
	end
	if false == instantitem_ok then
		msg_ack["errno"] = 208
		return msg_ack
	end

	local slotcharacter = characterdata:get_slotcharacter(userdata:get("character_id"))
	local slotskills = skilldata:get_slotskills()
	local slottreasures = treasuredata:get_slottreasures()

	-- cost, update data
	userdata:cost_heart(cost_heart_num)
	for k, v in pairs(msg["useItems"]) do
		itemdata:cost_instantitem(v, 1)
	end

	-- store game start state data
	self:set_playcode({
		stage_id = msg["stageID"],
		friend_user_id = msg["friendUserID"],
		is_finish = 0,
		create_date = os.time()
	})
	
	-- msg_ack
	msg_ack["playCode"] = 10
	msg_ack["slotCharacter"] = slotcharacter
	msg_ack["slotSkills"] = slotskills
	msg_ack["slotTreasures"] = slotTreasures

	return msg_ack
end

function game:result(msg)
	local msg_ack = {errno = 0}
	local playcode = self:get_playcode()
	if nil == playcode then
		msg_ack["errno"] = 201
		return msg_ack
	end

	local grade_reward = {}
	local stage_id = tostring(playcode.stage_id)

	if msg["is_clear"] > 0 and stage_id then
		local stage_config = configdata:get("define_stage")[stage_id]
		local user_stageinfo = gamedata:get_user_stageinfo(playcode["stage_id"])
		
		-- update exp_point
		local reward_exp_point = stage_config["rewardValue2"]
		userdata:plus_exp_point(reward_exp_point)

		-- update money
		local reward_money = stage_config["rewardValue1"]
		userdata:plus_money(reward_money)

		-- update stage accomplish state
		local reward = {}
		if user_stageinfo then
			if msg["is_clear"] == 3 and user_stageinfo.clear_type < 3 then
				table.insert(reward, 3)
			end
			if msg["is_clear"] >= 2 and user_stageinfo.clear_type < 2 then
				table.insert(reward, 2)
			end
			if msg["is_clear"] >= 1 and user_stageinfo.clear_type < 1 then
				table.insert(reward, 1)
			end
			gamedata:update_user_stageinfo({
				stage_id = stage_id,
				clear_type = msg["is_clear"],
				score = msg["score"],
				clear_count = 1,
				create_date = os.time(),
				perfect = msg["isPerfect"]
			})
		else
			if msg["is_clear"] == 3 then
				table.insert(reward, 3)
			end
			if msg["is_clear"] >= 2 then
				table.insert(reward, 2)
			end
			if msg["is_clear"] >= 1 then
				table.insert(reward, 1)
			end
			gamedata:insert_user_stageinfo({
				stage_id = stage_id,
				clear_type = msg["is_clear"],
				score = msg["score"],
				clear_count = 1,
				create_date = os.time(),
				perfect = msg["isPerfect"]
			})
		end

		for k, v in pairs(reward) do
			local rewardtype = stage_config["gradeRewardType"..v]
			local rewardcount = stage_config["gradeRewardValue"..v]
			if "Gold" == rewardtype then
				userdata:plus_money(rewardcount)
				table.insert(grade_reward, {type=0, amount=rewardcount, itemID=nil})
			end
		end

	elseif 1 == msg["is_clear"] and 0 == stage_id then
		leaguedate:update_user_leagueranking(msg["score"])
	else
	end

	-- update exp and money
	userdata:plus_exp_point(msg["gainExp"] * 1)
	userdata:plus_money(msg["gainMoney"] * 1)

	-- send reward message to friend, using message service
	if playcode.friend_user_id then
		skynet.send("mail_s", "lua", "send_mail", {
			send_user_id = msg["userID"],
			receive_user_id = playcode.friend_user_id,
			gift_type = 6,
			amount = 10,
			text_id = 4
		})
	end

	-- clear this time game play state
	self:set_playcode(nil)

	msg_ack["money"] = userdata:get("money")
	msg_ack["cash"] = userdata:get("cash")
	msg_ack["lotteryPoint"] = userdata:get("lottery_point")
	msg_ack["lotteryHighCoupon"] = userdata:get("lottery_high_coupon")
	msg_ack["lotteryCoupon"] = userdata:get("lottery_coupon")
	msg_ack["heart"] = userdata:get("heart")
	msg_ack["heartTime"] = userdata:get("heart_time")
	msg_ack["heartTimeSeconds"] = userdata:get("heart_time_seconds")
	msg_ack["gradeReward"] = grade_reward
	msg_ack["items"] = itemdata:get_instantitems()
	return msg_ack
end

function function_name( ... )
	-- body
end

return game
