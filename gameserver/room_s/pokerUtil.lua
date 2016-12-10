local this = {}

-- level 1: 1,2,3,4,		means that heart-3,diamod-3,club-3,spade-3
-- level 2: 5,6,7,8,		(4,4,4,4)
-- level 3: 9,10,11,12,		(5,5,5,5)
-- level 4: 13,14,15,16,	(6,6,6,6)
-- level 5: 17,18,19,20,	(7,7,7,7)
-- level 6: 21,22,23,24,	(8,8,8,8)
-- level 7: 25,26,27,28,		(9,9,9,9)
-- level 8: 29,30,31,32,	(10,10,10,10)
-- level 9: 33,34,35,36,	(11,11,11,11) J
-- level 10: 37,38,39,40,	(12,12,12,12) Q
-- level 11: 41,42,43,44,	(13,13,13,13) K
-- level 12: 45,46,47,48,	(14,14,14,14) A
-- level 13: 49,50,51,52,	(15,15,15,15) 2
-- level 14: 53,54			(16,16)		  Joker

this.TYPE_SINGLE = 1
this.TYPE_DOUBLE = 2 --对子 
this.TYPE_THREE = 3  --三不带
this.TYPE_THREE_SINGLE = 4 --3带1
this.TYPE_THREE_DOUBLE = 5 --3带2
this.TYPE_FOUR_TWO = 6  --4带2
this.TYPE_FOUR_FOUR = 7  --带2对
this.TYPE_SEQUENCE = 8     --顺子
this.TYPE_DOUBLE_BY_DOUBLE = 9 --连对
this.TYPE_THREE_BY_THREE = 10  --飞机
this.TYPE_BOOM = 11 --炸弹
this.TYPE_KING_BOOM = 12 --王炸


function this.isSingle(pokerList)
    if #pokerList == 1 then
        local seq = math.ceil(pokerList[1]/4)
        if pokerList[1] == 54 then
            seq = seq + 1
        end
        return this.TYPE_SINGLE,seq
    end
    return -1,-1
end

function this.isDouble(pokerList)
	if #pokerList == 2 then
		local seq1 = math.ceil(pokerList[1]/4)
		local seq2 = math.ceil(pokerList[2]/4)
		if seq1 == seq2 and seq2 < 14 then
			return this.TYPE_DOUBLE,seq1
		end
	end
	return -1,-1
end

function this.isThree(pokerList)
	if #pokerList == 3 then
		local seq1 = math.ceil(pokerList[1]/4)
		local seq2 = math.ceil(pokerList[2]/4)
		local seq3 = math.ceil(pokerList[3]/4)
		if seq1 == seq2 and seq1 == seq3 then
			return this.TYPE_THREE,seq1
		end
	end
	return -1,-1
end

function this.findEqualPoker(pokerList, maxEqual, excludeValList)
	local ret = {}
	local equalNum = 0
	local pokerIdx = 1
	for i = 1, #pokerList do
		if math.ceil(pokerList[i]/4) == math.ceil(pokerList[pokerIdx]/4) then
			local isExclude = false
			if excludeValList ~= nil then
				for j=1,#excludeValList do
					if excludeValList[j] == math.ceil(pokerList[i]/4) then
						isExclude = true
						break
					end
				end
			end
			if isExclude == false then
				equalNum = equalNum + 1
				table.insert(ret, i)
				if equalNum >= maxEqual then
					return ret
				end
			end
		else
			ret = {}
			table.insert(ret, i)
			equalNum = 1
			pokerIdx = i
		end
	end
	if #ret < maxEqual then
		ret = {}
	end
	return ret
end

function this.isOneByOne(pokerList)
	if #pokerList < 2 then
		return -1,-1
	end
	table.sort(pokerList)
	local prev = pokerList[1]
	for i = 2, #pokerList do
		if pokerList[i] - prev == 1 then
			prev = pokerList[i]
		else
			return -1,-1
		end
	end
	return this.TYPE_SEQUENCE, math.ceil(pokerList[1]/4)
end

function this.isThreeSingle(pokerList)
	if #pokerList ~= 4 then 
		return -1,-1 
	end
	table.sort(pokerList)
	local idxList = this.findEqualPoker(pokerList, 3)
	if #idxList ~= 0 then
		local level = math.ceil(pokerList[idxList[1]]/4)
		return this.TYPE_THREE_SINGLE,level
	end
	return -1,-1
end

function this.isThreeDouble(pokerList)
	if #pokerList ~= 5 then
		return -1,-1
	end
	table.sort(pokerList)
	-- find 3 equal poker
	local idxList1 = this.findEqualPoker(pokerList, 3)
	if #idxList1 == 0 then
		return -1,-1
	end
	local level = math.ceil(pokerList[idxList1[1]]/4)
	local idxList2 = this.findEqualPoker(pokerList, 2, {level})
	if #idxList2 == 0 then
		return -1,-1
	end
	return this.TYPE_THREE_DOUBLE,level
end

function this.isBoom(pokerList)
	if #pokerList ~= 4 then
		return -1,-1
	end
	table.sort(pokerList)
	local idxList = this.findEqualPoker(pokerList, 4)
	if #idxList == 0 then
		return -1,-1
	end
	local level = math.ceil(pokerList[idxList[1]]/4)
	return this.TYPE_BOOM,level
end

function this.isKingBoom(pokerList)
	if #pokerList ~= 2 then
		return -1,-1
	end
	table.sort(pokerList)
	if math.ceil(pokerList[1]/4) == 14 and math.ceil(pokerList[2]/4) == 14 then
		return this.TYPE_KING_BOOM, 14
	end
	return -1,-1
end

function this.isFourTwo(pokerList)
	if #pokerList ~= 6 then
		return -1,-1
	end
	table.sort(pokerList)
	-- find 4 equal poker
	local idxList = this.findEqualPoker(pokerList, 4)
	if #idxList == 0 then
		return -1,-1
	end
	local level = math.ceil(pokerList[idxList[1]]/4)
	return this.TYPE_FOUR_TWO,level
end

function this.isFourFour(pokerList)
	if #pokerList ~= 8 then
		return -1,-1
	end
	table.sort(pokerList)
	-- find 4 equal poker
	local idxList1 = this.findEqualPoker(pokerList, 4)
	if #idxList1 == 0 then
		return -1,-1
	end
	local level = math.ceil(pokerList[idxList1[1]]/4)
	-- find 2 equal poker
	local idxList2 = this.findEqualPoker(pokerList, 2, {math.ceil(pokerList[idxList1[1]]/4)})
	if #idxList2 == 0 then
		return -1,-1
	end
	-- find 2 equal poker
	local idxList3 = this.findEqualPoker(pokerList, 2, {math.ceil(pokerList[idxList1[1]]/4), 
		math.ceil(pokerList[idxList2[1]]/4)})
	if #idxList3 == 0 then
		return -1,-1
	end
	return this.TYPE_FOUR_FOUR,level
end

function this.isSequence(pokerList)
	if #pokerList < 5 then
		return -1,-1
	end
	table.sort(pokerList)
	local prev = pokerList[1]
	for i = 2, #pokerList do
		if math.ceil(pokerList[i]/4) - math.ceil(prev/4) == 1 then
			prev = pokerList[i]
		else
			return -1,-1
		end
	end
	return this.TYPE_SEQUENCE, math.ceil(pokerList[1]/4)
end

function this.isDoubleByDouble(pokerList)
	if #pokerList < 6 then
		return -1,-1
	end
	table.sort(pokerList)
	local prev = pokerList[1]
	for i = 2, #pokerList do
		if i % 2 == 1 then
			if math.ceil(pokerList[i]/4) - math.ceil(prev/4) == 1 then
				prev = pokerList[i]
			else
				return -1,-1
			end
		end
	end
	return this.TYPE_DOUBLE_BY_DOUBLE, math.ceil(pokerList[1]/4)
end

function this.isThreeByThree(pokerList)
	if #pokerList < 8 then
		return -1,-1
	end
	table.sort(pokerList)
	local sequence = {}
	local exclude = {}
	local idxList = {0}
	while #idxList ~= 0 do
		idxList = this.findEqualPoker(pokerList, 3, exclude)
		if #idxList ~= 0 then
			table.insert(sequence, math.ceil(pokerList[idxList[1]]/4))
			table.insert(exclude, math.ceil(pokerList[idxList[1]]/4))
		end
	end
	local isOneByOne, level = this.isOneByOne(sequence)
	if isOneByOne == -1 then
		return -1,-1
	end
	if #pokerList ~= #sequence * 4 then
		return -1,-1
	end
	return this.TYPE_THREE_BY_THREE, level
end

function this.getPokerType(pokerList)
	table.sort(pokerList)
	local pokerType, level = this.isSingle(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isDouble(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isThree(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isThree(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isBoom(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isKingBoom(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isThreeSingle(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isThreeDouble(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isFourTwo(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isFourFour(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isSequence(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isDoubleByDouble(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	pokerType, level = this.isThreeByThree(pokerList)
	if pokerType ~= -1 then
		return pokerType, level
	end
	return -1,-1
end

function this.getTipSingle(pokerList, level)
	local ret = {}
	for i = 1, #pokerList do
		if math.ceil(pokerList[i]/4) > level then
			table.insert(ret, i)
			return ret
		end
	end
	return ret
end

function this.getTipDouble(pokerList, level)
	local ret = {}
	local exclude = {}
	for i = 1, level do
		table.insert(exclude, i)
	end
	local idxList = this.findEqualPoker(pokerList, 2, exclude)
	if #idxList == 0 then
		return ret
	end
	return idxList
end

function this.getTipThree(pokerList, level)
	local ret = {}
	local exclude = {}
	for i = 1, level do
		table.insert(exclude, i)
	end
	local idxList = this.findEqualPoker(pokerList, 3, exclude)
		local cjson = require "cjson"
	print(cjson.encode(idxList))
	if #idxList == 0 then
		return ret
	end
	return idxList
end

function this.getTipThreeSingle(pokerList, level)
	local tipThree = this.getTipThree(pokerList, level)
	if tipThree == {} then
		return ret
	end
	local idxList = this.findEqualPoker(pokerList, 1, {math.ceil(pokerList[tipThree[1]]/4)})
	table.insert(tipThree, idxList[1])
	return tipThree
end

function this.getTipThreeDouble(pokerList, level)
	local tipThree = this.getTipThree(pokerList, level)
	if tipThree == {} then
		return {}
	end
	local idxList = this.findEqualPoker(pokerList, 2, {math.ceil(pokerList[tipThree[1]]/4)})
	if #idxList == 0 then
		return {}
	end
	table.insert(tipThree, idxList[1])
	table.insert(tipThree, idxList[2])
	return tipThree
end

function this.getTipBoom(pokerList, level)
	local ret = {}
	local exclude = {}
	for i = 1, level do
		table.insert(exclude, i)
	end
	local idxList = this.findEqualPoker(pokerList, 4, exclude)
	if #idxList ~= 0 then
		return idxList
	end
	-- get king boom
	exclude = {}
	for i = 0, 13 do
		table.insert(exclude, i)
	end
	idxList = this.findEqualPoker(pokerList, 4, exclude)
	if #idxList ~= 0 then
		return idxList
	end
	return ret
end

function this.getTipFourTwo(pokerList, level)
	local ret = {}
	local exclude = {}
	for i = 1, level do
		table.insert(exclude, i)
	end
	local idxList1 = this.findEqualPoker(pokerList, 4, exclude)
	if #idxList1 == 0 then
		return ret
	end

	local idxList2 = this.findEqualPoker(pokerList, 1, {math.ceil(pokerList[idxList1[1]]/4)})
	if #idxList2 == 0 then
		return ret
	end
	local idxList3 = this.findEqualPoker(pokerList, 1, {
		math.ceil(pokerList[idxList1[1]]/4), 
		math.ceil(pokerList[idxList2[1]]/4)
		})
	if #idxList3 == 0 then
		return ret
	end

	table.insert(ret, idxList2[1])
	table.insert(ret, idxList3[1])
	for i=1, #idxList1 do
		table.insert(ret, idxList1[i])
	end
	return ret
end

function this.getTipFourFour(pokerList, level)
	local ret = {}
	local exclude = {}
	for i = 1, level do
		table.insert(exclude, i)
	end
	local idxList1 = this.findEqualPoker(pokerList, 4, exclude)
	if #idxList1 == 0 then
		return ret
	end

	local idxList2 = this.findEqualPoker(pokerList, 2, {math.ceil(pokerList[idxList1[1]]/4)})
	if #idxList2 == 0 then
		return ret
	end
	local idxList3 = this.findEqualPoker(pokerList, 2, {
		math.ceil(pokerList[idxList1[1]]/4), 
		math.ceil(pokerList[idxList2[1]]/4)
		})
	if #idxList3 == 0 then
		return ret
	end

	table.insert(ret, idxList2[1])
	table.insert(ret, idxList2[2])
	table.insert(ret, idxList3[1])
	table.insert(ret, idxList3[2])
	for i=1, #idxList1 do
		table.insert(ret, idxList1[i])
	end
	return ret
end

function this.getTipSequence(pokerList, count, level)
	local ret = {}
	if count > #pokerList then
		return ret
	end
	local currLevel = level + 1
	local currCount = 0
	for i = 1, #pokerList do
		local tmpLevel = math.ceil(pokerList[i]/4)
		if tmpLevel == currLevel then
			table.insert(ret, i)
			currLevel = currLevel + 1
			currCount = currCount + 1
			if currCount == count then
				return ret
			end
		elseif tmpLevel > currLevel then
			ret = {}
			table.insert(ret, i)
			currLevel = tmpLevel + 1
			currCount = 1
		end
	end
	return {}
end

function this.getTipDoubleByDouble(pokerList, count, level)
	local ret = {}
	local currLevel = level
	while currLevel < 14 do
		local seq0l = this.getTipSequence(pokerList, count, currLevel)
		local leftPokerList = {}
		local j = 1
		for i = 1, #pokerList do
			if seq01[j] ~= i then
				table.insert(leftPokerList, i)
				j = j + 1
			end
		end
		local seq02 = this.getTipSequence(leftPokerList, count, currLevel)
		if seq0l ~= {} and seq0l[1] == seq02[1] then
			for i = 1, #seq0l do
				table.insert(ret, seq0l[i])
			end
			for i = 1, #seq02 do
				table.insert(ret, seq02[i])
			end
			return ret
		end
		currLevel = currLevel + 1
	end
	return {}
end

function this.getTipThreeByThree(pokerList, count, level)
	local ret = {}
	local currLevel = level
	while currLevel < 14 do
		local seq0l = this.getTipSequence(pokerList, count, currLevel)
		local leftPokerList = {}
		local j = 1
		for i = 1, #pokerList do
			if seq01[j] ~= i then
				table.insert(leftPokerList, i)
				j = j + 1
			end
		end
		local seq02 = this.getTipSequence(leftPokerList, count, currLevel)
		leftPokerList2 = {}
		j = 1
		for i = 1, #leftPokerList do
			if seq02[j] ~= i then
				table.insert(leftPokerList2, i)
				j = j + 1
			end
		end
		local seq03 = this.getTipSequence(leftPokerList2, count, currLevel)

		if seq0l ~= {} and seq0l[1] == seq02[1] and seq0l[1] == seq03[1] then
			for i = 1, #seq0l do
				table.insert(ret, seq0l[i])
			end
			for i = 1, #seq02 do
				table.insert(ret, seq02[i])
			end
			for i = 1, #seq03 do
				table.insert(ret, seq03[i])
			end
			return ret
		end
		currLevel = currLevel + 1
	end
	return {}
end

function this.getTipPoker(pokerList, currPlayPoker)
	table.sort(pokerList)
end

-- invalid comparation, means invalid picking poker
function this.pokerCmp(srcPokerList, destPokerList)
    local srcType, srcLevel = this.getPokerType(srcPokerList)
    if srcType == -1 then 
        return -1 
    end
    
    if #destPokerList == 0 then
        return 1
    end

    local destType, destLevel = this.getPokerType(destPokerList)
    if destType == this.TYPE_KING_BOOM then 
        return -1
    end
    if srcType == destType then
        if #srcPokerList ~= #destPokerList then
            return -1
        else
            if srcLevel > destLevel then
                return 1
            else
                return -1
            end
        end
    end
    
    if srcType == this.TYPE_BOOM or srcType == this.TYPE_KING_BOOM then
        return 1
    end
    return -1
end

function table_remove(srcTable, removeItems)
	local t = {}
	for k, v in pairs(removeItems) do
		t[k] = v
	end
	local function local_table_remove(srcTable, removeItems)
	    for i = 1, #srcTable do
	        for j = 1, #removeItems do
	            if srcTable[i] == removeItems[j] then
	                table.remove(srcTable, i)
	                table.remove(removeItems, j)
	                return local_table_remove(srcTable, removeItems)
	            end
	        end
	    end
	    return srcTable
	end	

	return local_table_remove(srcTable, t)
end



function table_insert(srcTable, insertItems)
    for i = 1, #insertItems do
        table.insert(srcTable, insertItems[i])
    end
    table.sort(srcTable)
    return srcTable
end

function math_pow(a, b)
	if b == 0 then
		return 1
	end
	return a * math_pow(a, b-1)
end

return this

