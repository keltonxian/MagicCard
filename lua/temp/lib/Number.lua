
--==================================================
--    @Brief:   数字类
--    @Author:  Rios
--    @Date:    2015-07-17
--==================================================

Number = Number or class("Number")


function Number:ctor()
end

----------------------------------------------------
-- 从min - max 中随机 N个数
----------------------------------------------------
function Number:getNRandomFromZone(N,min,max)
	if N>max-min then return nil end
    local rets = {}
    local nums = {}
    for i=min,max do
        table.insert(nums,i)
    end

    local function getOneNumber()
        local aRandomIndex = math.random(#nums)
        table.insert(rets,nums[aRandomIndex])
        table.remove(nums,aRandomIndex)
    end

    for i=1,N do
        getOneNumber()
    end

    return rets
end

----------------------------------------------------
-- 生成一个Tags的表，根据 Zorder的表中的key
----------------------------------------------------
function Number:generateTagsFromZOrders(aBaseTag,aZOrderTable)
    local aTagTable = {}
    for k,v in pairs(aZOrderTable) do
        aTagTable[k]=0
    end

    local function generateTag(aTagTable,aBaseTag)
	    local count=aBaseTag
	    for k,v in pairs(aTagTable) do
	        aTagTable[k]=count
	        count=count+1
	    end
	end

    generateTag(aTagTable,aBaseTag)
    return aTagTable
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function Number:test()

	-- getNRandomFromZone
	print("####  getNRandomFromZone  ####")
	local aRandoms = Number:getNRandomFromZone(4, 100, 200)
	for i,v in ipairs(aRandoms) do
		print(i, v)
	end

	-- generate order for tags
	print("####  generate  ####")
	local aZOrders = {
		hair = 10,
		face = 8,
		mouth = 9,	
	}
	local aTags = Number:generateTagsFromZOrders(100, aZOrders)
	print("hair.tag = ",aTags.hair)
	print("face.tag = ",aTags.face)
	print("mouth.tag = ",aTags.mouth)
end

