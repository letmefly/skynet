local userdata = require "agent_s.userdata"
local gamedata = require "agent_s.gamedata"
local frienddata = require "agent_s.frienddata"
local shopdata = require "agent_s.shopdata"
local characterdata = require "agent_s.characterdata"
local skilldata = require "agent_s.skilldata"
local treasuredata = require "agent_s.treasuredata"
local itemdata = require "agent_s.itemdata"


local game = {}

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
	
	-- msg_ack
	msg_ack["playCode"] = 0
	msg_ack["slotCharacter"] = slotcharacter
	msg_ack["slotskills"] = slotskills
	msg_ack["slotTreasures"] = slotTreasures

	return msg_ack
end

function game:result(msg)
	-- body
end

function function_name( ... )
	-- body
end

return game
