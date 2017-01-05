local pokerUtil = require "room_s.pokerUtil"
local cjson = require "cjson"
local M = {}

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
	pokerList = {1,2,3,5,5,9,11,13,17,18,21,22}
	local tipIdx = pokerUtil.getTipSequence(pokerList, #playPoker, l)
	for i = 1, #tipIdx do
		table.insert(tip, pokerList[tipIdx[i]])
	end
	print(cjson.encode(pokerList).."--"..cjson.encode(playPoker).."--tip-->"..cjson.encode(tip))	

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
end

return M
