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

local function game:set_playcode(playcode)
	self.playcode = playcode
end
local function game:get_playcode()
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
	if friendinfo == nil then
		msg_ack["errno"] = 101
		return msg_ack
	end

	local instantitem_ok = true
	for k, v in pairs(msg["useItems"]) do
		local amount = itemdata:get_instantitem_amount(v)
		if amount <= 0 then
			instantitem_ok = false
			break
		end
	end
	if false == instantitem_ok then
		msg_ack["errno"] = 208
		return msg_ack
	end

	local slotcharacters = characterdata:get_slotcharacters(userdata:get("character_id"))
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
	msg_ack["playCode"] = 0
	msg_ack["slotCharacter"] = slotcharacters
	msg_ack["slotskills"] = slotskills
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

	local stage_id = tostring(playcode["stage_id"])
	local stageinfo = configdata:get("define_stage")[stage_id]
	
	-- update exp_point
	local reward_exp_point = stageinfo["rewardValue2"]
	userdata:plus_exp_point(reward_exp_point)

	-- update money
	local reward_money = stageinfo["rewardValue1"]
	shopdata:plus_money(reward_money)

	-- update stage accomplish state
	gamedata:update_stageinfo({
		stage_id = stage_id, 
		clear_type = msg["is_clear"], 
		score = msg["score"],
		clear_count = 1,
		create_date = os.time(),
		perfect = msg["isPerfect"]
	})

end

function function_name( ... )
	-- body
end

return game
