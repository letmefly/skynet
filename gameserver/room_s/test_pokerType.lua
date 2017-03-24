local pokerUtil = require "room_s.pokerUtil"
local cjson = require "cjson"
local M = {}

function M.id2poker(pokerList)
	local p = {}
	for i = 1, #pokerList do
		if pokerList[i] >= 1 and pokerList[i] <= 32 then
			p[i] = pokerUtil.getLevel(pokerList[i]) + 2
		end
		if pokerList[i] >= 33 and pokerList[i] <= 36 then
			p[i] = 'J'
		end
		if pokerList[i] >= 37 and pokerList[i] <= 40 then
			p[i] = 'Q'
		end		
		if pokerList[i] >= 41 and pokerList[i] <= 44 then
			p[i] = 'K'
		end	
		if pokerList[i] >= 45 and pokerList[i] <= 48 then
			p[i] = 'A'
		end	
		if pokerList[i] >= 49 and pokerList[i] <= 52 then
			p[i] = '2'
		end	
		if pokerList[i] >= 53 and pokerList[i] <= 53 then
			p[i] = 'g'
		end	
		if pokerList[i] >= 54 and pokerList[i] <= 54 then
			p[i] = 'G'
		end	
	end
	return p
end
function M.level2poker(levelList)
	local p = {}
	for i = 1, #levelList do
		if levelList[i] >= 1 and levelList[i] <= 8 then
			p[i] = i + 2
		end
		if levelList[i] >= 9 and levelList[i] <= 9 then
			p[i] = 'J'
		end
		if levelList[i] >= 10 and levelList[i] <= 10 then
			p[i] = 'Q'
		end		
		if levelList[i] >= 11 and levelList[i] <= 11 then
			p[i] = 'K'
		end	
		if levelList[i] >= 12 and levelList[i] <= 12 then
			p[i] = 'A'
		end	
		if levelList[i] >= 13 and levelList[i] <= 13 then
			p[i] = '2'
		end	
		if levelList[i] >= 14 and levelList[i] <= 14 then
			p[i] = 'G'
		end	
	end
	return p
end
-- test pokerUtil api
function M.test()
	local pokerList = {5}
	local t, l = pokerUtil.isSingle(pokerList)
	print("{5} "..t..","..l)
	
	pokerList = {5,6}
	t, l = pokerUtil.isDouble(pokerList)
	print("{5,6} "..t..","..l)

	pokerList = {5,6,7}
	t, l = pokerUtil.isThree(pokerList)
	print("{5,6,7} "..t..","..l)

	pokerList = {38,39,40,2}
	t, l = pokerUtil.isThreeSingle(pokerList)
	print("{38,39,40,2} "..t..","..l)

	pokerList = {5,6,7,32,31}
	t, l = pokerUtil.isThreeDouble(pokerList)
	print("{5,6,7,32,31} "..t..","..l)

	pokerList = {5,6,7,8}
	t, l = pokerUtil.isBoom(pokerList)
	print("{5,6,7,8} "..t..","..l)

	pokerList = {5,6,7,8,9,20}
	t, l = pokerUtil.getPokerType(pokerList)
	print("{5,6,7,8,9,20} "..t..","..l)

	pokerList = {5,6}
	t, l = pokerUtil.isKingBoom(pokerList)
	print("{5,6} "..t..","..l)
	pokerList = {53,54}
	t, l = pokerUtil.isKingBoom(pokerList)
	print("{53,54} "..t..","..l)

	pokerList = {8,6,7,5,13,11}
	t, l = pokerUtil.isFourTwo(pokerList)
	print("{8,6,7,5,13,11} "..t..","..l)

	pokerList = {8,6,7,5,21,22,29,30}
	t, l = pokerUtil.isFourFour(pokerList)
	print("{8,6,7,5,20,21} "..t..","..l)

	pokerList = {4,8,12,16,20,24}
	t, l = pokerUtil.isSequence(pokerList)
	print("{4,8,12,16,20,24} "..t..","..l)

	pokerList = {3,4,7,16,19,20,23,24,8,11,12,15}
	t, l = pokerUtil.isDoubleByDouble(pokerList)
	print("{3,4,7,16,19,20,23,24,8,11,12,15} "..t..","..l)

	pokerList = {2,3,4, 6,7,8, 10,11,12, 14,15,16, 18,19,20, 22,23,24, 41,47,33,31,35,27}
	t, l = pokerUtil.isThreeByThree(pokerList)
	print("{2,3,4, 6,7,8, 10,11,12, 14,15,16, 18,19,20, 22,23,24, 41,47,33,31,35,27} "..t..","..l)

	pokerList = {2,3,4, 6,7,8, 10,11,12, 14,15,16, 18,19,20, 22,23,24, 41,47,33,31,35,1}
	t, l = pokerUtil.getPokerType(pokerList)
	print("{2,3,4, 6,7,8, 10,11,12, 14,15,16, 18,19,20, 22,23,24, 41,47,33,31,35,1} "..t..","..l)

	pokerList = {1,2,3,4,9,10,11,12}
	local boomLevelList = pokerUtil.getAllBoomLevel(pokerList)
	print(cjson.encode(pokerList).."--boomLevelList-->"..cjson.encode(boomLevelList))

	local playPoker = {53,54}
	t,l = pokerUtil.getPokerType(playPoker)
	print("{53,54} "..t..","..l)

	local playPoker = {2,3,4,30}
	local tip = {}
	t,l = pokerUtil.getPokerType(playPoker)
	print("{2,3,4,30} "..t..","..l)
	pokerList = {6,7,8, 10,11,12, 14,15,16, 18,19,20, 22,23,24, 41,47,33,31,35,1}
	local tipIdx = pokerUtil.getTipThreeSingle(pokerList, l)
	for i = 1, #tipIdx do
		table.insert(tip, pokerList[tipIdx[i]])
	end
	print(cjson.encode(pokerList).."--"..cjson.encode(playPoker).."--"..cjson.encode(tip))

	local playPoker = {1,5,9,13,17}
	local tip = {}
	t,l = pokerUtil.getPokerType(playPoker)
	print("{1,5,9,13,17} "..t..","..l)
	pokerList = {6,7,10,14,18,22,26}
	local tipIdx = pokerUtil.getTipSequence(pokerList, #playPoker, l)
	for i = 1, #tipIdx do
		table.insert(tip, pokerList[tipIdx[i]])
	end
	print(cjson.encode(pokerList).."--"..cjson.encode(playPoker).."--tip sequecnt-->"..cjson.encode(tip))	

	pokerList = {6,7,10,14,18,22,26}
	playPoker = {1,5,9,13,17}
	tip = pokerUtil.getTipPoker(pokerList, playPoker)
	print(cjson.encode(pokerList).."--"..cjson.encode(playPoker).."--tip sequece-->"..cjson.encode(tip))

	print("{5,6,7,20} > {1,2,3,19} -- "..pokerUtil.pokerCmp({5,6,7,20}, {1,2,3,19}))
	print("{5} > {1} -- "..pokerUtil.pokerCmp({5}, {1}))
	print("{1} > {5} -- "..pokerUtil.pokerCmp({1}, {5}))
	print("{1,2,3,4} > {5,6,7,9} -- "..pokerUtil.pokerCmp({1,2,3,4}, {5,6,7,9}))

	print("{29,32,38,39,40} > {1,3,4,7,8} --"..pokerUtil.pokerCmp({29,32,38,39,40}, {1,3,4,7,8}))

	print("test table_remove")
	print("{6,15,19,20,25,33,35,36,38,41,42,44,45,47,48,49,52,51,53,21}")
	local t1 = {6,15,19,20,25,33,35,36,38,41,42,44,45,47,48,49,52,51,53,21}
	local t2 = {6}
	print(cjson.encode(table_remove(t1, t2)))
	t1 = {15,19,20,25,33,35,36,38,41,42,44,45,47,48,49,52,51,53,21}
	t2 = {36,35,33,19,20}
	print(cjson.encode(t1))
	print(cjson.encode(t2))
	print(cjson.encode(table_remove(t1, t2)))
	print(#table_remove(t1, t2))
	t1 = {15,25,38,41,42,44,45,47,48,49,52,51,53,21}
	t2 = {45,42,41,44,48,47,15,21}
	print(cjson.encode(t1))
	print(cjson.encode(t2))
	print(cjson.encode(table_remove(t1, t2)))
	print(#table_remove(t1, t2))
	t1 = {25,38,49,52,51,53}
	t2 = {49,52,51,25}
	print(cjson.encode(t1))
	print(cjson.encode(t2))	
	print(cjson.encode(table_remove(t1, t2)))	
	print(#table_remove(t1, t2))

	print("-------------splitPoker---------------")
	pokerList = {1,5,9,13,17,18,21,25,26}
	local ret = pokerUtil.ai_splitPoker(pokerList)
	print(cjson.encode(pokerList))
	print(cjson.encode(ret))

	print("-------------test ai first play poker---------------")
	pokerList = {1,5,9,13,17,20,21,23,24,31,35,36,44,46,49,50,52}
	local playPokerList = {}
	local isFriendPlay = false
	local ret = pokerUtil.ai_getPlayPoker(pokerList, playPokerList, isFriendPlay)
	print(cjson.encode(pokerList))
	print(cjson.encode(ret))

	print("-------------test ai not first play poker---------------")
	pokerList = {49,50}
	local playPokerList = {29,30}
	local isFriendPlay = false
	local ret = pokerUtil.ai_getPlayPoker(pokerList, playPokerList, isFriendPlay)
	print("my poker: "..cjson.encode(pokerList))
	print("other play: "..cjson.encode(playPokerList))
	print("my choose: "..cjson.encode(ret))

	pokerList = {2,3,4,10,18}
	local playPokerList = {}
	local isFriendPlay = false
	local ret = pokerUtil.ai_getPlayPoker(pokerList, playPokerList, isFriendPlay)
	print("my poker: "..cjson.encode(pokerList))
	print("other play: "..cjson.encode(playPokerList))
	print("my choose: "..cjson.encode(ret))

	print("-------------get play turn----------------")
	pokerList = {1,2,3,5,6,7,25,29,33,37,41}
	local playTurn = pokerUtil.ai_getPlayTurn(pokerList)
	print(cjson.encode(pokerList)..", play_turn=="..playTurn)
end

return M
