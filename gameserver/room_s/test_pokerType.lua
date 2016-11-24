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

	pokerList = {5,6,7,32}
	t, l = pokerUtil.isThreeSingle(pokerList)
	print("{5,6,7,32} "..t..","..l)

	pokerList = {5,6,7,32,31}
	t, l = pokerUtil.isThreeDouble(pokerList)
	print("{5,6,7,32,31} "..t..","..l)

	pokerList = {5,6,7,8}
	t, l = pokerUtil.isBoom(pokerList)
	print("{5,6,7,8} "..t..","..l)

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

end

return M
