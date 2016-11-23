local this = {}

-- 1,2,3,4,		means that heart-3,diamod-3,club-3,spade-3
-- 5,6,7,8,		(4,4,4,4)
-- 9,10,11,12,	(5,5,5,5)
-- 13,14,15,16,	(6,6,6,6)
-- 17,18,19,20,	(7,7,7,7)
-- 21,22,23,24,	(8,8,8,8)
-- 25,26,27,28,	(9,9,9,9)
-- 29,30,31,32,	(10,10,10,10)
-- 33,34,35,36,	(11,11,11,11) J
-- 37,38,39,40,	(12,12,12,12) Q
-- 41,42,43,44,	(13,13,13,13) K
-- 45,46,47,48,	(14,14,14,14) A
-- 49,50,51,52,	(15,15,15,15) 2
-- 53,54		(16,16)		  Joker

this.TYPE_SINGLE = 1
this.TYPE_DOUBLE = 2 --对子 
this.TYPE_THREE = 3  --三不带
this.TYPE_THREE_SINGLE = 4 --3带1
this.TYPE_THREE_DOUBLE = 5 --3带2
this.TYPE_FOUR_TWO = 6  --4带2
this.TYPE_FOUR_FOUR = 7  --带2对
this.TYPE_STRAIGHT = 8     --顺子
this.TYPE_DOUBLE_BY_DOUBLE = 9 --连对
this.TYPE_THREE_BY_THREE = 10  --飞机
this.TYPE_BOOM = 11 --炸弹
this.TYPE_KING_BOOM = 12 --王炸

function this.getType(data)

end

function this.isSingle(pokerList)
	if #pokerList == 1 then
		local seq = pokerList[1]/4
		return this.TYPE_SINGLE,seq
	end
	return -1,-1
end

function this.isDouble(pokerList)
	if #pokerList == 2 then
		local seq1 = pokerList[1]/4
		local seq2 = pokerList[2]/4
		if seq1 == seq2 then
			return this.TYPE_DOUBLE,seq1
		end
	end
	return -1,-1
end

function this.isThree(pokerList)
	if #pokerList == 3 then
		local seq1 = pokerList[1]/4
		local seq2 = pokerList[2]/4
		local seq3 = pokerList[3]/4
		if seq1 == seq2 and seq1 == seq3 then
			return this.TYPE_THREE,seq1
		end
	end
	return -1,-1
end

function this.findEqualPoker(pokerList, maxEqual, excludeValList)
	local equalNum = 1
	local pokerIdx = 1
	for i = 1, #pokerList do
		if pokerList[i]/4 == pokerList[pokerIdx]/4 then
			local isExclude = false
			for j=1,#excludeValList do
				if excludeValList[j] == pokerList[i]/4 then
					isExclude = true
					break
				end
			end
			if isExclude == false then
				equalNum = equalNum + 1
				if equalNum >= maxEqual then
					return pokerIdx
				end
			end
		else
			equalNum = 1
			pokerIdx = i
		end
	end
	return -1
end

function this.isThreeSingle(pokerList)
	if #pokerList ~= 4 then 
		return -1,-1 
	end
	table.sort(pokerList)
	local idx = this.findEqualPoker(pokerList, 3)
	local level = pokerList[idx]/4
	if idx ~= -1 then
		return this.TYPE_THREE,level
	end
	return -1,-1
end

function this.isThreeDouble(pokerList)
	if #pokerList ~= 5 then
		return -1,-1
	end
	-- find 3 equal poker
	local idx1 = this.findEqualPoker(pokerList, 3)
	if idx1 == -1 then
		return -1,-1
	end
	local level = pokerList[idx1]/4

	local idx2 = this.findEqualPoker(pokerList, 2, {level})
	if idx2 == -1 then
		return -1,-1
	end
	return this.TYPE_THREE_DOUBLE,level
end

function this.isBoom(pokerList)
	if #pokerList ~= 4 then
		return -1,-1
	end
	local idx = this.findEqualPoker(leftPokerList, 4)
	if idx == -1 then
		return -1,-1
	end
	local level = pokerList[idx1]/4
	return this.TYPE_BOOM,level
end

function this.isKingBoom(pokerList)
	if #pokerList ~= 2 then
		return -1,-1
	end
	if pokerList[1]/4 == 16 and pokerList[2]/4 == 16 then
		return this.TYPE_KING_BOOM, 16
	end
	return -1,-1
end

function this.isFourTwo(pokerList)
	if #pokerList ~= 6 then
		return -1,-1
	end
	-- find 4 equal poker
	local idx1 = this.findEqualPoker(pokerList, 4)
	if idx1 == -1 then
		return -1,-1
	end
	local level = pokerList[idx1]/4
	return this.TYPE_THREE_DOUBLE,level
end

function this.isFourFour(pokerList)
	if #pokerList ~= 8 then
		return -1,-1
	end
	-- find 4 equal poker
	local idx1 = this.findEqualPoker(pokerList, 4)
	if idx1 == -1 then
		return -1,-1
	end
	local level = pokerList[idx1]/4

	-- find 2 equal poker
	local idx2 = this.findEqualPoker(pokerList, 2, {pokerList[idx1]/4})
	if idx2 == -1 then
		return -1,-1
	end
	-- find 2 equal poker
	local idx3 = this.findEqualPoker(pokerList, 2, {pokerList[idx1]/4, pokerList[idx2]/4})
	if idx3 == -1 then
		return -1,-1
	end

	return this.TYPE_THREE_DOUBLE,level
end

return this
