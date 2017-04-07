local this = {}
-- level 1: 1,2,3,4,        means that heart-3,diamod-3,club-3,spade-3
-- level 2: 5,6,7,8,        (4,4,4,4)
-- level 3: 9,10,11,12,     (5,5,5,5)
-- level 4: 13,14,15,16,    (6,6,6,6)
-- level 5: 17,18,19,20,    (7,7,7,7)
-- level 6: 21,22,23,24,    (8,8,8,8)
-- level 7: 25,26,27,28,        (9,9,9,9)
-- level 8: 29,30,31,32,    (10,10,10,10)
-- level 9: 33,34,35,36,    (11,11,11,11) J
-- level 10: 37,38,39,40,   (12,12,12,12) Q
-- level 11: 41,42,43,44,   (13,13,13,13) K
-- level 12: 45,46,47,48,   (14,14,14,14) A
-- level 13: 49,50,51,52,   (15,15,15,15) 2
-- level 14: 53,54          (16,16)       Joker
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
this.TYPE_THREE_BY_THREE_DOUBLE = 13

local cjson = require "cjson"
function print_json(t)
    print(cjson.encode(t))
end

function this.getLevel(pokerId)
    local v = pokerId
    if v > 54 then
        v = v - 54
    end
    if v == 54 then
        return 15
    end
    return math.ceil(pokerId/4)
end
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

function this.findSinglePoker(pokerList)
    local ret = {}
    for i = 1, #pokerList do
        local isSame = false
        if i - 1 > 0 then
            if this.getLevel(pokerList[i-1]) == this.getLevel(pokerList[i]) then
                isSame = true
            end
        end
        if i + 1 <= #pokerList then
            if this.getLevel(pokerList[i]) == this.getLevel(pokerList[i+1]) then
                isSame = true
            end
        end
        if isSame == false then
            table.insert(ret, i)
        end
    end
    return ret
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
    if #pokerList < 4 then
        return -1,-1
    end
    table.sort(pokerList)
    local idxList = this.findEqualPoker(pokerList, 8)
    if #idxList == 8 and #idxList==#pokerList then
        local level = math.ceil(pokerList[idxList[1]]/4)
        return this.TYPE_BOOM,level+80
    end
    local idxList = this.findEqualPoker(pokerList, 7)
    if #idxList == 7 and #idxList==#pokerList then
        local level = math.ceil(pokerList[idxList[1]]/4)
        return this.TYPE_BOOM,level+70
    end
    local idxList = this.findEqualPoker(pokerList, 6)
    if #idxList == 6 and #idxList==#pokerList then
        local level = math.ceil(pokerList[idxList[1]]/4)
        return this.TYPE_BOOM,level+60    
    end    
    local idxList = this.findEqualPoker(pokerList, 5)
    if #idxList == 5 and #idxList==#pokerList then
        local level = math.ceil(pokerList[idxList[1]]/4)
        return this.TYPE_BOOM,level+50          
    end    
    local idxList = this.findEqualPoker(pokerList, 4)
    if #idxList == 4 and #idxList==#pokerList then
        local level = math.ceil(pokerList[idxList[1]]/4)
        return this.TYPE_BOOM,level          
    end
    return -1,-1
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
function this.isThreeByThreeDouble(pokerList)
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
    for i = 1, #sequence do
        local level = sequence[i]
        table.insert(exclude, level)
        idxList = this.findEqualPoker(pokerList, 2, exclude)
        if #idxList == 0 then
            return -1,-1
        end
        table.insert(exclude, this.getLevel(pokerList[idxList[1]]))
    end
    return this.TYPE_THREE_BY_THREE_DOUBLE, level
end
function this.getPokerType(pokers)
    local pokerList = {}
    for k, v in pairs(pokers) do
        if v > 54 then
            v = v - 54
        end
        pokerList[k] = v
    end
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
    pokerType, level = this.isThreeByThreeDouble(pokerList)
    if pokerType ~= -1 then
        return pokerType, level
    end
    pokerType, level = this.isThreeByThree(pokerList)
    if pokerType ~= -1 then
        return pokerType, level
    end

    return -1,-1
end
function this.getTipSingle(pokerList, playPokerList)
    local ret = {}
    for i = 1, #pokerList do
        if math.ceil(pokerList[i]/4) > math.ceil(playPokerList[1]/4) then
            table.insert(ret, i)
            return ret
        end
        if playPokerList[1] == 53 and pokerList[i] == 54 then
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
    --local cjson = require "cjson"
    --print(cjson.encode(idxList))
    if #idxList == 0 then
        return ret
    end
    return idxList
end
function this.getTipThreeSingle(pokerList, level)
    local tipThree = this.getTipThree(pokerList, level)
    if #tipThree == 0 then
        return {}
    end
    local idxList = this.findEqualPoker(pokerList, 1, {math.ceil(pokerList[tipThree[1]]/4)})
    local singleList = this.findSinglePoker(pokerList)
    if #singleList == 0 then
        table.insert(tipThree, idxList[1])
    else
        table.insert(tipThree, singleList[1])
    end
    return tipThree
end
function this.getTipThreeDouble(pokerList, level)
    local tipThree = this.getTipThree(pokerList, level)
    if #tipThree == 0 then
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
    idxList = this.findEqualPoker(pokerList, 2, exclude)
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
        if tmpLevel >= 13 then return {} end
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
    while currLevel < 13 do
        local seq01 = this.getTipSequence(pokerList, count/2, currLevel)
        local leftPokerList = {}
        local j = 1
        for i = 1, #pokerList do
            if this.isContains(seq01, i) == false then
                table.insert(leftPokerList, pokerList[i])
            end
        end
        --printJson(leftPokerList)
        local seq02 = this.getTipSequence(leftPokerList, count/2, currLevel)
        --[[
        print("seq01:")
        for kkk, vvv in pairs(seq01) do
        print(pokerList[vvv]..",")
        end
        print("seq02:")
        for kkk, vvv in pairs(seq02) do
        print(leftPokerList[vvv]..",")
        end
        ]]
        if pokerList[seq01[1]] and leftPokerList[seq02[1]] and this.getLevel(pokerList[seq01[1]]) == this.getLevel(leftPokerList[seq02[1]]) then
            for i = 1, #seq01 do
                table.insert(ret, pokerList[seq01[i]])
            end
            for i = 1, #seq02 do
                table.insert(ret, leftPokerList[seq02[i]])
            end
            table.sort(ret)
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
        local seq0l = {}
        seq0l = this.getTipSequence(pokerList, count, currLevel)
        local leftPokerList = {}
        local j = 1
        for i = 1, #pokerList do
            if seq0l[j] ~= i then
                table.insert(leftPokerList, i)
                j = j + 1
            end
        end
        local seq02 = this.getTipSequence(leftPokerList, count, currLevel)
        local leftPokerList2 = {}
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

function this.getTipPoker2(pokers, playPokers, isFriend)
    local ret = this.ai_getPlayPoker(pokers, playPokers, isFriend)
    if #ret == 0 then
        ret = this.getTipPoker(pokers, playPokers)
    end
    return ret
end

function this.getTipPoker(pokers, playPokers)
    local pokerList = {}
    local currPlayPoker = {}
    for k, v in pairs(pokers) do
        if v > 54 then
            v = v - 54
        end
        pokerList[k] = v
    end
    for k, v in pairs(playPokers) do
        if v > 54 then
            v = v - 54
        end
        currPlayPoker[k] = v
    end
    local tipPokers = {}
    local tipPokerIdxs = {}
    table.sort(pokerList)
    table.sort(currPlayPoker)    
    if #currPlayPoker == 0 then
        table.insert(tipPokers, pokerList[1])
        return tipPokers
    end
    local pokerType, level = this.getPokerType(currPlayPoker)
    if pokerType ==  this.TYPE_SINGLE then
        --tipPokerIdxs = this.getTipSingle(pokerList, currPlayPoker)
        tipPokerIdxs = this.getBestTipSingle(pokerList, currPlayPoker)
    elseif pokerType ==  this.TYPE_DOUBLE then
        tipPokerIdxs = this.getTipDouble(pokerList, level)
    elseif pokerType == this.TYPE_THREE then
        tipPokerIdxs = this.getTipThree(pokerList, level)
    elseif pokerType == this.TYPE_THREE_SINGLE then
        tipPokerIdxs = this.getTipThreeSingle(pokerList, level)
    elseif pokerType == this.TYPE_THREE_DOUBLE then
        tipPokerIdxs = this.getTipThreeDouble(pokerList, level) 
    elseif pokerType == this.TYPE_BOOM then
        tipPokerIdxs = this.getTipBoom(pokerList, level)
    elseif pokerType == this.TYPE_FOUR_TWO then
        tipPokerIdxs = this.getTipFourTwo(pokerList, level)
    elseif pokerType == this.TYPE_FOUR_FOUR then
        tipPokerIdxs = this.getTipFourFour(pokerList, level)    
    elseif pokerType == this.TYPE_SEQUENCE then
        --tipPokerIdxs = this.getTipSequence(pokerList, #currPlayPoker, level) 
        tipPokerIdxs = this.getBestTipSequence(pokerList, #currPlayPoker, level)
    elseif pokerType == this.TYPE_DOUBLE_BY_DOUBLE then
        tipPokers = this.getTipDoubleByDouble(pokerList, #currPlayPoker, level) 
    elseif pokerType == this.TYPE_THREE_BY_THREE then
        tipPokerIdxs = this.getTipThreeByThree(pokerList, #currPlayPoker/4, level) 
    end
    if #tipPokers == 0 and #tipPokerIdxs==0 and pokerType ~= this.TYPE_BOOM then
        tipPokerIdxs = this.getTipBoom(pokerList, 0)
    end
    for i = 1, #tipPokerIdxs do
        local idx = tipPokerIdxs[i]
        table.insert(tipPokers, pokers[idx])
    end
    return tipPokers
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
        if srcType == this.TYPE_BOOM then
            if #srcPokerList > #destPokerList then
                return 1
            end
        end
        if #srcPokerList ~= #destPokerList then
            return -1
        else
            if srcLevel > destLevel then
                return 1
            else
                return -1
            end
        end
    else
        if srcType == this.TYPE_BOOM or srcType == this.TYPE_KING_BOOM then
            return 1
        end
    end
    return -1
end
function this.sortPoker(pokers)
    table.sort(pokers, function(a, b)
        if a > 54 then
            a = a - 54
        end
        if b > 54 then
            b = b - 54
        end
        return a < b
    end)
end
function this.getAllSameLevelList(pokerList, sameNum)
    local retList = {}
    local tmpPokerList = {}
    for k, v in pairs(pokerList) do
        tmpPokerList[k] = v
    end
    for i = 1, #tmpPokerList do
        local idxList = this.findEqualPoker(tmpPokerList, sameNum, retList)
        if #idxList == sameNum then
            table.insert(retList, this.getLevel(pokerList[idxList[1]]))
        end
    end
    return retList
end
function this.getAllBoomLevel(pokerList)
    local boomLevelList = this.getAllSameLevelList(pokerList, 4)
    -- get king boom
    local exclude = {}
    for i = 1, 13 do
        table.insert(exclude, i)
    end
    if this.isContains(pokerList, 53) and this.isContains(pokerList, 54) then
        table.insert(boomLevelList, this.getLevel(53))
        table.insert(boomLevelList, this.getLevel(54))
    end
    return boomLevelList
end
function this.getAllDoubleLevel(pokerList)
    local retList = this.getAllSameLevelList(pokerList, 2)
    return retList
end
function this.getAllThreeLevel(pokerList)
    local retList = this.getAllSameLevelList(pokerList, 3)
    return retList
end
function this.getAllSequence(pokerList, count, level)
    local ret = {}
    if count > #pokerList then
        return ret
    end
    for i = level, 8 do
        local tmpLevel = i
        local tipPokers = this.getTipSequence(pokerList, count, tmpLevel)
        for k, v in pairs(tipPokers) do
            if this.isContains(ret, v) == false then
                table.insert(ret, v)
            end
        end
    end
    return ret
end
function this.getAllDoubleSequenceList(pokerList, count, level)
    local ret = {}
    if count > #pokerList then
        return ret
    end
    for i = level, 10 do
        local tmpLevel = i
        local tipPokers = this.getTipDoubleByDouble(pokerList, count, tmpLevel)
        for k, v in pairs(tipPokers) do
            if this.isContains(ret, v) == false then
                table.insert(ret, v)
            end
        end
    end
    return ret
end
function this.isContains(t, var)
    for k, v in pairs(t) do
        if v == var then
            return true
        end
    end
    return false
end
function this.getLightPokerIdList(pokerList, playPokerList)
    local retLightPokerIdList = {}
    if #playPokerList == 0 then
        for k, v in pairs(pokerList) do
            retLightPokerIdList[k] = v
        end
        return retLightPokerIdList
    end
    local tmpPokerList = {}
    for k, v in pairs(pokerList) do
        if v > 54 then
            v = v - 54
        end
        tmpPokerList[k] = v
    end
    local tmpPlayPokerList = {}
    for k, v in pairs(playPokerList) do
        if v > 54 then
            v = v - 54
        end
        tmpPlayPokerList[k] = v
    end
    table.sort(tmpPlayPokerList)
    local t, l = this.getPokerType(tmpPlayPokerList)
    if t == this.TYPE_SINGLE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if level > l or this.isContains(allBoomLevelList, level) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t ==  this.TYPE_DOUBLE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allDoubleLevel = this.getAllDoubleLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if ((this.isContains(allDoubleLevel, level) == true and level > l)) or 
                this.isContains(allBoomLevelList, level) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_THREE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allThreeLevel = this.getAllThreeLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if (this.isContains(allThreeLevel, level) == true and level > l) or 
                this.isContains(allBoomLevelList, level) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_THREE_SINGLE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allThreeLevel = this.getAllThreeLevel(tmpPokerList)
        local hasBiggerThree = false
        table.sort(allThreeLevel)
        if allThreeLevel[1] and allThreeLevel[#allThreeLevel] > l then
            hasBiggerThree = true
        end
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if hasBiggerThree or (this.isContains(allThreeLevel, level) == true and level > l) or 
                this.isContains(allBoomLevelList, level) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_THREE_DOUBLE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allThreeLevel = this.getAllThreeLevel(tmpPokerList)
        local allDoubleLevel = this.getAllDoubleLevel(tmpPokerList)
        local hasBiggerThree = false
        table.sort(allThreeLevel)
        if allThreeLevel[1] and allThreeLevel[#allThreeLevel] > l then
            hasBiggerThree = true
        end
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if (this.isContains(allThreeLevel, level) == true and level > l) or
                (this.isContains(allDoubleLevel, level) == true and hasBiggerThree) or
                this.isContains(allBoomLevelList, level) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_BOOM then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if (this.isContains(allBoomLevelList, level) == true and level > l) then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_FOUR_TWO then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local hasBiggerFour = false
        table.sort(allBoomLevelList)
        if allBoomLevelList[1] and allBoomLevelList[#allBoomLevelList] > l then
            hasBiggerFour = true
        end
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if (this.isContains(allBoomLevelList, level) == true) or hasBiggerFour then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_FOUR_FOUR then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if (this.isContains(allBoomLevelList, level) == true and level > l) then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_SEQUENCE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allSequenceList = this.getAllSequence(tmpPokerList, #tmpPlayPokerList, this.getLevel(tmpPlayPokerList[1]))
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if this.isContains(allBoomLevelList, level) == true or this.isContains(allSequenceList, i) == true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_DOUBLE_BY_DOUBLE then
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        local allDoubleSequenceList = this.getAllDoubleSequenceList(tmpPokerList, #tmpPlayPokerList, this.getLevel(tmpPlayPokerList[1]))
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if this.isContains(allBoomLevelList, level) == true or this.isContains(allDoubleSequenceList, tmpPokerList[i])==true then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_THREE_BY_THREE then
        local count = #playPokerList/4
        local splitList = this.ai_splitPoker(tmpPokerList)
        local retAir = this.ai_findAirPlane(splitList.threeList, count, l)
        local hasBig = false
        if #retAir == count then
            hasBig = true
        end
        
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if this.isContains(allBoomLevelList, level) == true or hasBig then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end
    elseif t == this.TYPE_THREE_BY_THREE_DOUBLE then
        local count = #playPokerList/5
        local splitList = this.ai_splitPoker(tmpPokerList)
        local retAir = this.ai_findAirPlane(splitList.threeList, count, l)
        local hasBig = false
        if #retAir == count then
            hasBig = true
        end
        local allBoomLevelList = this.getAllBoomLevel(tmpPokerList)
        for i = 1, #tmpPokerList do
            local level = this.getLevel(tmpPokerList[i])
            if this.isContains(allBoomLevelList, level) == true or hasBig then
                table.insert(retLightPokerIdList, tmpPokerList[i])
            end
        end        
    end
    return retLightPokerIdList
end
function this.getBestTipSingle(pokerList, playPokerList)
    local ret = {}
    local playLevel = this.getLevel(playPokerList[1])
    --[[
    for i = 1, #pokerList do
    if math.ceil(pokerList[i]/4) > math.ceil(playPokerList[1]/4) then
    table.insert(ret, i)
    return ret
    end
    if playPokerList[1] == 53 and pokerList[i] == 54 then
    table.insert(ret, i)
    return ret
    end        
    end
    ]]
    local levelList = {}
    for i = 1, 15 do
        levelList[i] = 0
    end
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        levelList[level] = levelList[level] + 1
    end 
    -- 1. find in single list   
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        if level > playLevel and levelList[level] == 1 then
            table.insert(ret, i)
            return ret
        end
        if playPokerList[1] == 53 and pokerList[i] == 54 then
            table.insert(ret, i)
            return ret
        end 
    end
    -- 2. find in double list   
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        if level > playLevel and levelList[level] >= 2 and level >= 12 then
            table.insert(ret, i)
            return ret
        end
    end
    return ret
end
function this.getBestTipSequence(pokerList, count, level)
    local ret = {}
    if count > #pokerList then
        return ret
    end
    local tipList = {}
    local tipIdxList = {}
    for i = level, 8 do
        local tmpLevel = i
        local tipPokerIdx = this.getTipSequence(pokerList, count, tmpLevel)
        if #tipPokerIdx > 0 then
            local tipPokers = {}
            for k = 1, #tipPokerIdx do
                table.insert(tipPokers, pokerList[tipPokerIdx[k]])
            end
            table.insert(tipList, tipPokers)
            table.insert(tipIdxList, tipPokerIdx)
        end
    end
    -- find the best tip sequence
    local bestIdx = 0
    local pokerScore = this.calcPokerScore(pokerList)
    for i = 1, #tipList do
        local tip = tipList[i]
        local score = this.calcPokerScore(table_remove(pokerList, tip)) + #tip*1.5
        if score > pokerScore then
            bestIdx = i
            pokerScore = score
        end
    end
    if bestIdx ~= 0 then
        ret = tipIdxList[bestIdx]
    end
    return ret
end
function this.calcPokerScore(pokerList)
    local levelList = {}
    for i = 1, 15 do
        levelList[i] = 0
    end
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        levelList[level] = levelList[level] + 1
    end
    local score = 0
    for i = 1, #levelList do
        if levelList[i] == 4 then
            score = score + 6
        elseif levelList[i] == 3 then
            score = score + 4
        elseif levelList[i] == 2 then
            score = score + 3
        elseif levelList[i] == 1 then
            score = score + 1
        end
    end
    return score
end
function table_clone(t)
    local ret = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            ret[k] = table_clone(v)
        else
            ret[k] = v
        end
    end
    return ret
end
--[[
function table_remove(srcTable, removeItems)
if #srcTable > 0 then
table.sort(srcTable)
end
if #removeItems > 0 then
table.sort(removeItems)
end
local newTable = {}
for i = 1, #srcTable do
if this.isContains(removeItems, srcTable[i])==false then
table.insert(newTable, srcTable[i])
end
end
return newTable
end
]]
function table_remove_item(srcTable, item)
    for i = 1, #srcTable do
        if srcTable[i] == item then
            table.remove(srcTable, i)
            return srcTable
        end
    end
    return srcTable
end
function table_remove(srcTable, removeItems)
    local newTable = table_clone(srcTable)
    for i = 1, #removeItems do
        local item = removeItems[i]
        newTable = table_remove_item(newTable, item)
    end
    return newTable
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

----------------------------- AI FUNCTIONS ---------------------------
function this.ai_getLevelList(pokerList)
    local levelList = {}
    for i = 1, 15 do
        levelList[i] = 0
    end
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        levelList[level] = levelList[level] + 1
    end 
    return levelList
end
function this.ai_getIdx(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return i
        end
    end
    return -1
end
function this.ai_getMiss(seq, one, two, three)
    local oneIdx = this.ai_getIdx(seq, one)
    local twoIdx = this.ai_getIdx(seq, two)
    local threeIdx = this.ai_getIdx(seq, three)
    if oneIdx ~= -1 and twoIdx ~= -1 and threeIdx ~= -1 then
        return table_remove(seq, {one, two, three})
    end
    return {}
end
function this.ai_calcMissSeqPoker(one, two, three)
    local ret = {}
    if three - one > 4 then
        return {}
    end
    for i = 1, 8 do
        local currSeq = {i, i+1, i+2, i+3, i+4}
        local miss = this.ai_getMiss(currSeq, one, two, three)
        if #miss > 0 then
            table.insert(ret, miss)
        end
    end
    return ret
end
function this.ai_find(tab, search)
    local ret = {}
    for i = 1, #search do
        local idx = this.ai_getIdx(tab, search[i])
        if idx ~= -1 then
            table.insert(ret, search[i])
        end
    end
    return ret
end
function this.ai_level_remove(tableHigh, tableLow, items)
    local high = table_remove(tableHigh, items)
    local low = table_insert(tableLow, items)
    return high, low
end
function this.ai_equal(tab1, tab2)
    if #tab1 ~= #tab2 then return false end
    table.sort(tab1)
    table.sort(tab2)
    for i = 1, #tab1 do
        if tab1[i] ~= tab2[i] then
            return false
        end
    end
    return true
end
function this.ai_splitPoker(pokerList)
    local ret = {}
    ret.oneList = {}
    ret.twoList = {}
    ret.threeList = {}
    ret.fourList = {}
    ret.oneSeqList = {}
    ret.twoSeqList = {}
    ret.kingBoomList = {}
    local pokerLevelList = this.ai_getLevelList(pokerList)
    for level = 1, #pokerLevelList do
        if pokerLevelList[level] == 1 then
            table.insert(ret.oneList, level)
        elseif pokerLevelList[level] == 2 then
            table.insert(ret.twoList, level)
        elseif pokerLevelList[level] == 3 then
            table.insert(ret.threeList, level)
        elseif pokerLevelList[level] == 4 then
            table.insert(ret.fourList, level)
        end
    end
    local tempSingleList = {}
    table.sort(ret.oneList)
    -- link all sinlge poker to seqence
    while #ret.oneList >= 3 do
        local currSeq = {}
        local one = ret.oneList[1]
        local two = ret.oneList[2]
        local three = ret.oneList[3]
        --table_insert(currSeq, {one, two, three})
        if one and two and three then
            local missList = this.ai_calcMissSeqPoker(one, two, three)
            local isFind = false
            if #missList > 0 then
                -- now split poker from two, three, four list
                for j = 1, #missList do
                    local miss = missList[j]
                    local ret1 = this.ai_find(ret.oneList, miss)
                    local ret2 = this.ai_find(ret.twoList, miss)
                    local ret3 = this.ai_find(ret.threeList, miss)
                    local ret4 = this.ai_find(ret.fourList, miss)
                    local retMerge = {}

                    retMerge = table_insert(retMerge, ret1)
                    retMerge = table_insert(retMerge, ret2)
                    retMerge = table_insert(retMerge, ret3)
                    retMerge = table_insert(retMerge, ret4)

                    if this.ai_equal(retMerge, miss) then
                        local zeroList = {}
                        ret.oneList, zeroList = this.ai_level_remove(ret.oneList, zeroList, ret1)
                        ret.twoList, ret.oneList = this.ai_level_remove(ret.twoList, ret.oneList, ret2)
                        ret.threeList, ret.twoList = this.ai_level_remove(ret.threeList, ret.twoList, ret3)
                        ret.fourList, ret.threeList = this.ai_level_remove(ret.fourList, ret.threeList, ret4)

                        ret.oneList = table_remove(ret.oneList, {one, two, three})
                        table.insert(ret.oneSeqList, table_insert({one, two, three}, miss))
                        isFind = true
                        break
                    end
                end
            end
            ret.oneList = table_remove(ret.oneList, {one})

            if isFind == false then
                table.insert(tempSingleList, one)
            end
            table.sort(ret.oneList)
        end
    end
    ret.oneList = table_insert(ret.oneList, tempSingleList)
    -- now check if has single poker to longer sequence
    table.sort(ret.oneList)
    local tmpRemoveList = {}
    for i = 1, #ret.oneList do
        local one = ret.oneList[i]
        if one < 13 then
            for j = 1, #ret.oneSeqList do
                local seq = ret.oneSeqList[j]
                if seq[1] == one + 1 or seq[#seq] == one - 1 then
                    table.insert(seq, one)
                    table.insert(tmpRemoveList, one)
                    break
                end
            end
        end
    end
    ret.oneList = table_remove(ret.oneList, tmpRemoveList)
    -- now check if has double sequence
    table.sort(ret.twoList)
    tmpRemoveList = {}
    while #ret.twoList >= 3 do
        local isFind = false
        if ret.twoList[3] <= 12 and ret.twoList[1] + 1 == ret.twoList[2] and 
            ret.twoList[2] + 1 == ret.twoList[3] then
            table.insert(ret.twoSeqList, {ret.twoList[1], ret.twoList[2], ret.twoList[3]})
            ret.twoList = table_remove(ret.twoList, {ret.twoList[1], ret.twoList[2], ret.twoList[3]})
            isFind = true
        end
        if isFind == false then
            table.insert(tmpRemoveList, ret.twoList[1])
        end
        ret.twoList = table_remove(ret.twoList, {ret.twoList[1]})
        table.sort(ret.twoList)
    end
    -- restore
    ret.twoList = table_insert(ret.twoList, tmpRemoveList)
    -- check if has king boom
    for i = 1, #ret.oneList do
        if ret.oneList[i] == 14 or ret.oneList[i] == 15 then
            table.insert(ret.kingBoomList, ret.oneList[i])
        end
    end
    if #ret.kingBoomList == 2 then
        ret.oneList = table_remove(ret.oneList, ret.kingBoomList)
    else
        ret.kingBoomList = {}
    end

    table.sort(ret.oneList)
    table.sort(ret.twoList)
    table.sort(ret.threeList)
    table.sort(ret.fourList)
    return ret
end
function this.ai_level2Poker(pokerList, levelList)
    local cloneLevelList = table_clone(levelList)
    local ret = {}
    for i = 1, #pokerList do
        local level = this.getLevel(pokerList[i])
        if this.ai_getIdx(cloneLevelList, level) ~= -1 then
            table.insert(ret, pokerList[i])
            cloneLevelList = table_remove(cloneLevelList, {level})
        end
    end
    return ret
end
function this.ai_calcPlayTurn(splitList)
    local turn = 0
    local oneTwoTurn = #splitList.oneList + #splitList.twoList - #splitList.threeList
    if oneTwoTurn < 0 then oneTwoTurn = 0 end
    turn = turn + oneTwoTurn
    turn = turn + #splitList.threeList
    turn = turn + #splitList.oneSeqList
    turn = turn + #splitList.twoSeqList
    return turn
end
function this.ai_getPlayTurn(pokerList)
    local splitList = this.ai_splitPoker(pokerList)
    return this.ai_calcPlayTurn(splitList)
end
function this.ai_getAirplane(levelList)
    local ret = {}
    table.insert(ret, levelList[1])
    for i = 2, #levelList do
        if levelList[i] == ret[#ret] + 1 then
            table.insert(ret, levelList[i])
            if #ret == 3 then
                return ret
            end
        else
            if #ret < 2 then
                ret = {}
                table.insert(ret, levelList[i])
            else
                return ret
            end
        end
    end
    return ret
end
function this.ai_findAirPlane(levelList, count, level)
    local ret = {}
    table.insert(ret, levelList[1])
    for i = 2, #levelList do
        if levelList[i] == ret[#ret] + 1 and levelList[i-1] > level then
            table.insert(ret, levelList[i])
            if #ret == count then
                return ret
            end
        else
            if #ret < 2 then
                ret = {}
                table.insert(ret, levelList[i])
            end
        end
    end
    return ret
end
function this.ai_getFirstPlayPoker(pokerList, next1Info, next2Info)
    local myT, myL = this.getPokerType(pokerList)
    if myT ~= -1 then return pokerList end
    local splitList = this.ai_splitPoker(pokerList)
    local playTurn = this.ai_calcPlayTurn(splitList)
    local minLevel = 6
    local isOneFirst = true

    -- help your friend win
    local friendLastType, friendLastLevel = -1, -1
    if next1Info and next1Info.isFriend then
        friendLastType, friendLastLevel = this.getPokerType(next1Info.pokerList)
        if friendLastType == this.TYPE_SINGLE then
            if this.getLevel(pokerList[1]) < friendLastLevel then
                if #splitList.kingBoomList == 2 then
                    local ret1 = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1], splitList.kingBoomList[2]})
                    return ret1
                end
                return {pokerList[1]}
            end
        elseif friendLastType == this.TYPE_DOUBLE then
            local idxList = this.findEqualPoker(pokerList, 2, {})
            if #idxList > 0 and this.getLevel(pokerList[idxList[1]] < friendLastLevel) then
                if #splitList.kingBoomList == 2 then
                    local ret1 = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1], splitList.kingBoomList[2]})
                    return ret1
                end
                return {pokerList[idxList[1]], pokerList[idxList[2]]}
            end
        end
    end
    -- block your adversary win
    local adversaryLastType, adversaryLastLevel = -1, -1
    if next1Info and next1Info.isFriend == false then
        adversaryLastType, adversaryLastLevel = this.getPokerType(next1Info.pokerList)
    elseif next2Info and next2Info.isFriend == false then
        adversaryLastType, adversaryLastLevel = this.getPokerType(next2Info.pokerList)
    end

    if #splitList.oneList > 0 and #splitList.twoList > 0 then
        if splitList.twoList[1] < splitList.oneList[1] then
            isOneFirst = false
        end
    end

    if adversaryLastType == this.TYPE_SINGLE then
        isOneFirst = false
    elseif adversaryLastType == this.TYPE_DOUBLE then
        isOneFirst = true
    end

    while minLevel <= 16 do
        -- first choose level < 6
        if #splitList.oneSeqList > 0 then
            local seq = splitList.oneSeqList[1]
            if seq[1] <= minLevel then
                local ret = this.ai_level2Poker(pokerList, seq)
                return ret
            end
        end
        if #splitList.twoSeqList > 0 then
            local twoSeq = splitList.twoSeqList[1]
            if twoSeq[1] <= minLevel then
                local ret1 = this.ai_level2Poker(pokerList, twoSeq)
                pokerList = table_remove(pokerList, ret1)
                local ret2 = this.ai_level2Poker(pokerList, twoSeq)
                local ret = table_insert(ret1, ret2)
                return ret
            end
        end
        -- air plane
        if #splitList.threeList >= 2 then
            local retAir = this.ai_getAirplane(splitList.threeList)
            if #retAir >= 2 and #splitList.oneList >= #retAir and retAir[1] <= 10 and splitList.oneList[#retAir] <= 13 then
                local airLevelList = {}
                if #retAir == 2 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],splitList.oneList[1], splitList.oneList[2]})
                elseif #retAir == 3 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],retAir[3],retAir[3],retAir[3],splitList.oneList[1], splitList.oneList[2],splitList.oneList[3]})
                end
                local ret1 = this.ai_level2Poker(pokerList, airLevelList)
                return ret1
            end
            if #retAir >= 2 and #splitList.twoList >= #retAir and retAir[1] <= 10 and splitList.twoList[#retAir] <= 12 then
                local airLevelList = {}
                if #retAir == 2 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],splitList.twoList[1], splitList.twoList[2],splitList.twoList[1], splitList.twoList[2]})
                elseif #retAir == 3 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],retAir[3],retAir[3],retAir[3],
                        splitList.twoList[1], splitList.twoList[2],splitList.twoList[3],splitList.twoList[1], splitList.twoList[2],splitList.twoList[3]})
                end
                local ret1 = this.ai_level2Poker(pokerList, airLevelList)
                return ret1
            end
        end
        if #splitList.threeList > 0 then
            local threeLevel = splitList.threeList[1]
            if threeLevel <= minLevel or #splitList.oneList + #splitList.twoList <= #splitList.threeList then
                if isOneFirst then
                    -- 3w1
                    if #splitList.oneList > 0 then
                        local single = splitList.oneList[1]
                        if single < 13 or playTurn <= 4 then
                            local ret1 = this.ai_level2Poker(pokerList, {threeLevel, threeLevel, threeLevel, single})
                            return ret1
                        end
                    end
                    -- 3w2
                    if #splitList.twoList > 0 then
                        local two = splitList.twoList[1]
                        if two < 9 or playTurn <= 4 then
                            local ret1 = this.ai_level2Poker(pokerList, {threeLevel, threeLevel, threeLevel, two, two})
                            return ret1
                        end
                    end
                else
                    -- 3w2
                    if #splitList.twoList > 0 then
                        local two = splitList.twoList[1]
                        if two < 9 or playTurn <= 4 then
                            local ret1 = this.ai_level2Poker(pokerList, {threeLevel, threeLevel, threeLevel, two, two})
                            return ret1
                        end
                    end
                    -- 3w1
                    if #splitList.oneList > 0 then
                        local single = splitList.oneList[1]
                        if single < 13 or playTurn <= 4 then
                            local ret1 = this.ai_level2Poker(pokerList, {threeLevel, threeLevel, threeLevel, single})
                            return ret1
                        end
                    end
                end

                -- 3w0
                local ret1 = this.ai_level2Poker(pokerList, {threeLevel, threeLevel, threeLevel})
                return ret1
            end
        end
        -- 4w2
        if #splitList.fourList > 0 then
            local singleNum = #splitList.oneList - #splitList.threeList
            if singleNum >= 4 and splitList.fourList[1] < 11 then
                if splitList.oneList[1] < 10 and splitList.oneList[2] < 10 then
                    local ret1 = this.ai_level2Poker(pokerList, {splitList.fourList[1], splitList.fourList[1], splitList.fourList[1], splitList.fourList[1], splitList.oneList[1], splitList.oneList[2]})
                    return ret1
                end
            end
        end
        if isOneFirst then
            if #splitList.oneList > 0 then
                for idx = 1, #splitList.oneList do
                    local one = splitList.oneList[idx]
                    if one <= minLevel and one > adversaryLastLevel then
                        local ret1 = this.ai_level2Poker(pokerList, {one})
                        return ret1
                    end
                    if adversaryLastLevel == -1 then
                        break
                    end
                end
                if adversaryLastType == this.TYPE_DOUBLE then
                    --print("---------------adversaryLastType:type-double----------------")
                    if #splitList.twoList > 0 then
                        local one = splitList.twoList[1]
                        local ret1 = this.ai_level2Poker(pokerList, {one})
                        return ret1
                    end
                end
            end
            if #splitList.twoList > 0 then
                for idx = 1, #splitList.twoList do
                    local two = splitList.twoList[idx]
                    if two <= minLevel and two > adversaryLastLevel then
                        local ret1 = this.ai_level2Poker(pokerList, {two,two})
                        return ret1
                    end
                    if adversaryLastLevel == -1 then
                        break
                    end
                end
            end
        else
            if #splitList.twoList > 0 then
                for idx = 1, #splitList.twoList do
                    local two = splitList.twoList[idx]
                    if two <= minLevel and two > adversaryLastLevel then
                        local ret1 = this.ai_level2Poker(pokerList, {two,two})
                        return ret1
                    end
                    if adversaryLastLevel == -1 then
                        break
                    end
                end
            end
            if #splitList.oneList > 0 then
                for idx = 1, #splitList.oneList do
                    local one = splitList.oneList[idx]
                    if one <= minLevel and one > adversaryLastLevel then
                        local ret1 = this.ai_level2Poker(pokerList, {one})
                        return ret1
                    end
                    if adversaryLastLevel == -1 then
                        break
                    end
                end
            end
        end
        minLevel = minLevel + 6
    end
    -- choose boom
    if #splitList.fourList > 0 then
        local four = splitList.fourList[1]
        local ret1 = this.ai_level2Poker(pokerList, {four, four, four, four})
        return ret1
    end
    if #splitList.kingBoomList == 2 then
        local ret1 = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1], splitList.kingBoomList[2]})
        return ret1
    end
    return {pokerList[#pokerList]}
end
function this.ai_findFirstBigger(levelList, level)
    for i = 1, #levelList do
        if levelList[i] > level then
            return levelList[i]
        end
    end
    return -1
end
function this.ai_findBiggest(levelList, minLevel, maxLevel, level)
    local ret = -1
    for i = 1, #levelList do
        if levelList[i] >= minLevel and levelList[i] <= maxLevel and levelList[i] > level then
            if levelList[i] > ret then
                ret = levelList[i]
            end
        end
    end
    return ret
end
function this.ai_getBoomWin(pokerList, playPokerList)
    local pokerType, level = this.getPokerType(pokerList)
    if pokerType == this.TYPE_BOOM or pokerType == this.TYPE_KING_BOOM then
        local ret = this.pokerCmp(pokerList, playPokerList)
        if ret > 0 then
            return pokerList
        end
    end
    return {}
end
function this.ai_getSeq(oneSeqList, level, len)
    local findSeq = {}
    local currLevel = 15
    for i = 1, #oneSeqList do
        local seq = oneSeqList[i]
        table.sort(seq)
        if seq[1] > level and #seq == len then
            if seq[1] < currLevel then
                findSeq = seq
                currLevel = seq[1]
            end
        end
    end
    return table_clone(findSeq)
end
function this.ai_isPlayBoom(splitList)
    local turn = 0
    local oneTurn = #splitList.oneList - #splitList.threeList
    if oneTurn < 0 then oneTurn = 0 end
    turn = turn + oneTurn
    turn = turn + #splitList.twoList
    turn = turn + #splitList.threeList
    turn = turn + #splitList.oneSeqList
    turn = turn + #splitList.twoSeqList
    turn = turn + #splitList.kingBoomList
    if turn <= 3 then
        return true
    end
    return false
end
function this.ai_getNotFirstPlayPoker(pokerList, playPokerList, isFriendPlay, next1Info, next2Info)
    local ret = this.ai_getBoomWin(pokerList, playPokerList)
    if #ret > 0 then return ret end
    local splitList = this.ai_splitPoker(pokerList)
    local playTurn = this.ai_calcPlayTurn(splitList)
    local pokerType, level = this.getPokerType(playPokerList)

    local friendLastType, friendLastLevel = -1, -1
    if next1Info and next1Info.isFriend then
        friendLastType, friendLastLevel = this.getPokerType(next1Info.pokerList)
    elseif next2Info and next2Info.isFriend then
        friendLastType, friendLastLevel = this.getPokerType(next2Info.pokerList)
    end
    -- block your adversary win
    local adversaryLastType, adversaryLastLevel = -1, -1
    if next1Info and next1Info.isFriend == false then
        adversaryLastType, adversaryLastLevel = this.getPokerType(next1Info.pokerList)
    elseif next2Info and next2Info.isFriend == false then
        adversaryLastType, adversaryLastLevel = this.getPokerType(next2Info.pokerList)
    end

    if friendLastType ~= -1 then
        if next1Info then
            if next1Info.isFriend == true then
                return {}
            else
                if adversaryLastType < level then
                    return {}
                end
            end
        end
    end

    if pokerType == this.TYPE_SINGLE then
        local biggerLevel = this.ai_findFirstBigger(splitList.oneList, level)
        -- you can play out all your pokers this time, you win
        if #pokerList == 1 and biggerLevel ~= -1 then
            return pokerList
        end
        if friendLastType == this.TYPE_SINGLE and friendLastLevel > level and next1Info.isFriend then
            return {}
        end
        if adversaryLastType == this.TYPE_SINGLE and adversaryLastLevel > level then
            biggerLevel = this.ai_findFirstBigger(splitList.oneList, adversaryLastLevel)
        end
        -- if friend play bigger than J, then you skip
        if isFriendPlay and level >= 12 and playTurn >= 3 and adversaryLastType == -1 then
            return {}
        end
        -- you can play if there is bigger single poker no matter who
        if biggerLevel ~= -1 then
            if adversaryLastType == -1 and biggerLevel >= 14 and biggerLevel - level >= 5 then
                return {}
            else
                local ret = this.ai_level2Poker(pokerList, {biggerLevel})
                return ret
            end
        end
        -- if it is not your firend and has no single poker, now split higher double poker
        if isFriendPlay == false then
            if #splitList.kingBoomList == 2 and (#splitList.oneList >= 3 or adversaryLastType ~= -1) then
                local ret = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1]})
                return ret
            end
            local biggest = this.ai_findBiggest(splitList.twoList, 6, 13, level)
            if biggest ~= -1 then
                local ret = this.ai_level2Poker(pokerList, {biggest})
                return ret
            end
            biggest = this.ai_findBiggest(splitList.threeList, 6, 13, level)
            if biggest ~= -1 then
                local ret = this.ai_level2Poker(pokerList, {biggest})
                return ret
            end
        end
    elseif pokerType ==  this.TYPE_DOUBLE then
        local biggerLevel = this.ai_findFirstBigger(splitList.twoList, level)
        -- you can play out all your pokers this time, you win
        if biggerLevel ~= -1 and this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        if friendLastType == this.TYPE_DOUBLE and friendLastLevel > level and next1Info and next1Info.isFriend then
            return {}
        end
        -- if friend play bigger than J, then you skip
        if isFriendPlay and level >= 9 and playTurn >= 3 and adversaryLastType == -1 then
            return {}
        end
        -- you can play if there is bigger single poker no matter who
        if biggerLevel ~= -1 then
            local ret = this.ai_level2Poker(pokerList, {biggerLevel,biggerLevel})
            return ret
        end
        if isFriendPlay == false then
            local biggest = this.ai_findBiggest(splitList.threeList, 6, 13, level)
            if biggest ~= -1 then
                local ret = this.ai_level2Poker(pokerList, {biggest, biggest})
                return ret
            end
        end
    elseif pokerType == this.TYPE_THREE then
        local biggerLevel = this.ai_findFirstBigger(splitList.threeList, level)
        -- you can play out all your pokers this time, you win
        if biggerLevel ~= -1 and this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        -- if friend play bigger than J, then you skip
        if isFriendPlay and level >= 6 and playTurn >= 3 then
            return {}
        end
        if biggerLevel ~= -1 then
            local ret = this.ai_level2Poker(pokerList, {biggerLevel,biggerLevel,biggerLevel})
            return ret
        end
    elseif pokerType == this.TYPE_THREE_SINGLE then
        local biggerLevel = this.ai_findFirstBigger(splitList.threeList, level)
        -- you can play out all your pokers this time, you win
        if biggerLevel ~= -1 and this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        -- if friend play bigger than J, then you skip
        if isFriendPlay and level >= 6 and playTurn >= 3 then
            return {}
        end
        if biggerLevel ~= -1 then
            if #splitList.oneList > 0 then
                local single = splitList.oneList[1]
                if single < 13 or playTurn <= 2 then
                    local ret1 = this.ai_level2Poker(pokerList, {biggerLevel, biggerLevel, biggerLevel, single})
                    return ret1
                end
            end
            if isFriendPlay == false then
                local biggest = this.ai_findBiggest(splitList.twoList, 1, 12, level)
                if biggest ~= -1 then
                    local ret = this.ai_level2Poker(pokerList, {biggerLevel, biggerLevel, biggerLevel, biggest})
                    return ret
                end
            end
        end
    elseif pokerType == this.TYPE_THREE_DOUBLE then
        local biggerLevel = this.ai_findFirstBigger(splitList.threeList, level)
        -- you can play out all your pokers this time, you win
        if biggerLevel ~= -1 and this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        -- if friend play bigger than J, then you skip
        if isFriendPlay and level >= 6 and playTurn >= 3 then
            return {}
        end
        if biggerLevel ~= -1 then
            if #splitList.twoList > 0 then
                local two = splitList.twoList[1]
                if two < 12 or playTurn <= 2 then
                    local ret1 = this.ai_level2Poker(pokerList, {biggerLevel, biggerLevel, biggerLevel, two, two})
                    return ret1
                end
            end
        end
    elseif pokerType == this.TYPE_BOOM then
        local biggerLevel = this.ai_findFirstBigger(splitList.fourList, level)
        if biggerLevel == -1 then
            if #splitList.kingBoomList == 2 and this.ai_isPlayBoom(splitList) then
                local ret1 = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1], splitList.kingBoomList[2]})
                return ret1
            end
            return {}
        else
            if this.ai_isPlayBoom(splitList) then
                local ret1 = this.ai_level2Poker(pokerList, {biggerLevel, biggerLevel, biggerLevel, biggerLevel})
                return ret1
            end
        end
    elseif pokerType == this.TYPE_FOUR_TWO then
        local biggerLevel = this.ai_findFirstBigger(splitList.fourList, level)
        -- you can play out all your pokers this time, you win
        if biggerLevel ~= -1 and this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        local singleNum = #splitList.oneList - #splitList.threeList
        if biggerLevel ~= -1 and isFriendPlay == false and splitList.fourList[1] <= 13 and singleNum >= 3 then
            if splitList.oneList[1] < 10 and splitList.oneList[2] < 10 then
                local ret1 = this.ai_level2Poker(pokerList, {biggerLevel, biggerLevel, biggerLevel, biggerLevel, splitList.oneList[1], splitList.oneList[2]})
                return ret1
            end
        end
    elseif pokerType == this.TYPE_FOUR_FOUR then
    elseif pokerType == this.TYPE_SEQUENCE then
        if this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        if isFriendPlay and level >= 5 and playTurn >= 3 then
            return {}
        end
        local seq = this.ai_getSeq(splitList.oneSeqList, level, #playPokerList)
        if #seq > 0 then
            local ret1 = this.ai_level2Poker(pokerList, seq)
            return ret1
        end
        if isFriendPlay == false then
            local seq = this.ai_getSeq(splitList.oneSeqList, level-1, #playPokerList + 1)
            if #seq > 0 then
                table.sort(seq)
                seq = table_remove(seq, {seq[1]})
                local ret1 = this.ai_level2Poker(pokerList, seq)
                return ret1
            end
            seq = this.ai_getSeq(splitList.oneSeqList, level, #playPokerList + 1)
            if #seq > 0 then
                table.sort(seq)
                seq = table_remove(seq, {seq[#seq]})
                local ret1 = this.ai_level2Poker(pokerList, seq)
                return ret1
            end
        end
    elseif pokerType == this.TYPE_DOUBLE_BY_DOUBLE then
        if this.pokerCmp(pokerList, playPokerList) == 1 then
            return pokerList
        end
        if isFriendPlay and level >= 5 and playTurn >= 3 then
            return {}
        end
        local seq = this.ai_getSeq(splitList.twoSeqList, level, #playPokerList/2)
        if #seq > 0 then
            local ret1 = this.ai_level2Poker(pokerList, table_insert(seq, seq))
            return ret1
        end
        if isFriendPlay == false then
            local seq = this.ai_getSeq(splitList.twoSeqList, level, 1 + #playPokerList/2)
            if #seq > 0 then
                table.sort(seq)
                seq = table_remove(seq, {seq[#seq]})
                local ret1 = this.ai_level2Poker(pokerList, table_insert(seq, seq))
                return ret1
            end
            seq = this.ai_getSeq(splitList.twoSeqList, level-1, 1 + #playPokerList/2)
            if #seq > 0 then
                table.sort(seq)
                seq = table_remove(seq, {seq[1]})
                local ret1 = this.ai_level2Poker(pokerList, table_insert(seq, seq))
                return ret1
            end
        end
    elseif pokerType == this.TYPE_THREE_BY_THREE then
        if isFriendPlay then return {} end
        local count = #playPokerList/4
        local retAir = this.ai_findAirPlane(splitList.threeList, count, level)
        if #retAir == count and count <= 3 then
            if #retAir >= 2 and #splitList.oneList >= #retAir and retAir[1] <= 10 and splitList.oneList[#retAir] <= 13 then
                local airLevelList = {}
                if #retAir == 2 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],splitList.oneList[1], splitList.oneList[2]})
                elseif #retAir == 3 then
                    table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],retAir[3],retAir[3],retAir[3],splitList.oneList[1], splitList.oneList[2],splitList.oneList[3]})
                end
                local ret1 = this.ai_level2Poker(pokerList, airLevelList)
                return ret1
            end
        end
    elseif pokerType == this.TYPE_THREE_BY_THREE_DOUBLE then
        if isFriendPlay then return {} end
        local count = #playPokerList/5
        local retAir = this.ai_findAirPlane(splitList.threeList, count, level)
        if #retAir >= 2 and #splitList.twoList >= #retAir and retAir[1] <= 10 and splitList.twoList[#retAir] <= 12 then
            local airLevelList = {}
            if #retAir == 2 then
                table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],splitList.twoList[1], splitList.twoList[2],splitList.twoList[1], splitList.twoList[2]})
            elseif #retAir == 3 then
                table_insert(airLevelList, {retAir[1], retAir[1], retAir[1], retAir[2],retAir[2],retAir[2],retAir[3],retAir[3],retAir[3],
                    splitList.twoList[1], splitList.twoList[2],splitList.twoList[3],splitList.twoList[1], splitList.twoList[2],splitList.twoList[3]})
            end
            local ret1 = this.ai_level2Poker(pokerList, airLevelList)
            return ret1
        end
    end

    -- check it is worth play boom
    if this.ai_isPlayBoom(splitList) or adversaryLastType ~= -1 or (next1Info and next1Info.isFriend and friendLastType ~= -1) then
        if #splitList.fourList > 0 then
            local four = splitList.fourList[1]
            local ret1 = this.ai_level2Poker(pokerList, {four, four, four, four})
            return ret1
        end
        if #splitList.kingBoomList == 2 then
            local ret1 = this.ai_level2Poker(pokerList, {splitList.kingBoomList[1], splitList.kingBoomList[2]})
            return ret1
        end
    end
    return {}
end
function this.ai_getPlayPoker(pokerList, playPokerList, isFriendPlay, next1Info, next2Info)
    local isFirstPlay = false
    if #playPokerList == 0 or playPokerList == nil then
        isFirstPlay = true
    end
    if isFirstPlay then
        return this.ai_getFirstPlayPoker(pokerList, next1Info, next2Info)
    else
        return this.ai_getNotFirstPlayPoker(pokerList, playPokerList, isFriendPlay, next1Info, next2Info)
    end
    return {}
end
function this.ai_isGrabLandlord(pokerList, bottomList)
    local clonePokerList = table_clone(pokerList)
    local pokers = table_insert(clonePokerList, bottomList)
    local splitList = this.ai_splitPoker(pokers)
    local hasKing = false
    if this.isContains(pokers, 53) == true or this.isContains(pokers, 54) == true then
        hasKing = true
    end
    local singleNum = #splitList.oneList - #splitList.threeList
    if singleNum <= 4 and hasKing == true then
        return true
    end
    return false
end

return this
