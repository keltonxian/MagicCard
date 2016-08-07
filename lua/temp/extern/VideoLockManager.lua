
--==================================================
--	@Brief:    视频锁保存状态逻辑
--	@Author:   Rios - CMY
--	@Date:     2015-07-17
--==================================================

function string.split(str, delimiter)
	if str == nil or str=='' or delimiter == nil then
		return nil
	end
	
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function pairsByKeys(t)      
    local a = {}      
    for n in pairs(t) do          
        a[#a+1] = n      
    end      
    table.sort(a)      
    local i = 0      
    return function()          
    i = i + 1          
    return a[i], t[a[i]]      
    end  
end

function getSystemTime()
	local year = tostring(os.date("%Y") % 100)
	local day = os.date("%j")
	day = tonumber(day)
	if day < 10 then
		day = "00" .. day
	elseif day < 100 then
		day = "0" .. day
	else
		day = tostring(day)
	end
	-- print(year, day, year .. day)
	-- print(type(year), type(day), type(year .. day))
	return year, day
end

__G__CurrentYear, __G__CurrentDay = getSystemTime()

VideoLockManager = class("VideoLockManager")

function VideoLockManager:ctor(args)
	self.baseIndex = args.baseIndex
	if not self.baseIndex then self.baseIndex = 10 end
	self.curIndex = self.baseIndex
	self.key = args.key -- scene name
	self.stringValue = "" -- scene name * values sum
	self.lockValues = {} -- all values
	self.lockStatus = "" -- all status
	self.unlockTimeValues = {} -- all unlock time values
	self.unlockTimeStatus = "" -- a string
	self.isRestored = false -- false, should addItem, true, not need addItem
end

function VideoLockManager.create(args)
	local obj = VideoLockManager.new(args)
	return obj
end

----------------------------------------------------
-- private function
----------------------------------------------------

----------------------------------------------------
-- get all values and all unlock time values
----------------------------------------------------
function VideoLockManager:decomposite(sum)
	if not sum then return end
	local k = 1
	local cunIndex = self.baseIndex
	while(sum > 0) do
		self.lockValues[cunIndex] = string.sub(self.lockStatus, k, k)
		self.unlockTimeValues[cunIndex] = string.sub(self.unlockTimeStatus, (k - 1) * 5 + 1, k * 5)
		sum = sum - cunIndex
		cunIndex = cunIndex + 1
		k = k + 1
	end
end

function VideoLockManager:calculateValues()
	local ret = string.split(self.stringValue, "*")
	self:decomposite(tonumber(ret[2]))
end

function VideoLockManager:composite()
	local sum = 0
	self.lockStatus = ""
	self.unlockTimeStatus = ""
	for k, v in pairsByKeys(self.lockValues) do
		sum = sum + k
		self.lockStatus = self.lockStatus .. v
		self.unlockTimeStatus = self.unlockTimeStatus .. self.unlockTimeValues[k]
	end
	self.stringValue = self.key .. "*" .. tostring(sum)
end

function VideoLockManager:updateValuesByTime(year, day)
	for k, v in pairsByKeys(self.unlockTimeValues) do
		local oldYear = string.sub(v, 1, 2)
		local oldDay = string.sub(v, 3, 5)
		local curItemLockStatus = self.lockValues[k]
		if curItemLockStatus == "1" and (oldDay ~= day or oldYear ~= year) then
			self.unlockTimeValues[k] = "00000"
			self.lockValues[k] = "0"
		end
	end
end

----------------------------------------------------
-- public function
----------------------------------------------------

----------------------------------------------------
-- 添加锁的信息
----------------------------------------------------
function VideoLockManager:addItem()
	if self.isRestored then
		self.curIndex = self.curIndex + 1
		return
	end
	self.lockValues[self.curIndex] = "0"
	self.unlockTimeValues[self.curIndex] = "00000"
	self.curIndex = self.curIndex + 1
end

-- 解锁，改变对应index的相关值
function VideoLockManager:recordUnlockItem(index)
	self.lockValues[index] = "1"
	self.unlockTimeValues[index] = __G__CurrentYear .. __G__CurrentDay
	-- self:writeFile()
end

----------------------------------------------------
-- 每一次进入游戏（开始进入，或者从后台返回）都会调用到此函数
----------------------------------------------------
function VideoLockManager:readFile()
	self.stringValue = CCUserDefault:sharedUserDefault():getStringForKey(self.key)
	self.curIndex = self.baseIndex
	if self.stringValue == "" then
		self.isRestored = false
		return
	end
	self.isRestored = true
	self.lockStatus = CCUserDefault:sharedUserDefault():getStringForKey(self.stringValue)
	self.unlockTimeStatus = CCUserDefault:sharedUserDefault():getStringForKey(self.stringValue .. "unlock")
	self:calculateValues()
	__G__CurrentYear, __G__CurrentDay = getSystemTime()
	self:updateValuesByTime(__G__CurrentYear, __G__CurrentDay)
end

function VideoLockManager:writeFile()
	if table.maxn(self.lockValues) >= self.baseIndex then
		self:composite()
		CCUserDefault:sharedUserDefault():setStringForKey(self.key, self.stringValue)
		CCUserDefault:sharedUserDefault():setStringForKey(self.stringValue, self.lockStatus)
		CCUserDefault:sharedUserDefault():setStringForKey(self.stringValue .. "unlock", self.unlockTimeStatus)
	end
end

function VideoLockManager:getLockStateByIndex(Index)
	if self.lockValues[Index] == "1" then return false end
	return true
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function VideoLockManager:test()

		local aTestLayer = Layer.create()

		local sl = VideoLockManager.create({
			baseIndex = 10,
			key = "testScene",
		})

		local buttonTexts = {"click me unlock","reload lock state","nextDayTest","back"}
		local OFFSET_Y = 80
		local ITEM_H = 80
	    local yyyy = 200
		for i=#buttonTexts, 1, -1 do
			local aButton = SpriteLayer.create(50, ITEM_H)
			local aButtonSize = aButton:getContentSize()
			local aText = CCLabelTTF:create(buttonTexts[i], "", 30)
			aButton:addChild(aText, 1)
			if i == 1 then 
				-- ################## lock item ################## do this
				sl:addItem()

				aTestLayer.lockStateLabel = aText
				aTestLayer.lockButton = aButton 
			end
			aText:setPosition(aButtonSize.width/2, aButtonSize.height/2)
			aText:setColor(ccc3(255, 255, 255))
			aButton:setPosition(300 + 100, OFFSET_Y + yyyy)
			aButton.tapHandler = function(s)

				if i == #buttonTexts then
					local aParentLayer = aTestLayer:getParent()
					performWithDelay(aParentLayer,function() 
						aParentLayer:removeFromTouchResponders(aTestLayer) 
						aParentLayer:removeChild(aTestLayer, true)
					 end, 0.5)
					return
				end

				if i == 1 then
					getSystemTime = function()
						local year = tostring(os.date("%Y") % 100)
						local day = os.date("%j")
						day = tonumber(day)
						if day < 10 then
							day = "00" .. day
						elseif day < 100 then
							day = "0" .. day
						else
							day = tostring(day)
						end
						return year, day
					end

					__G__CurrentYear, __G__CurrentDay = getSystemTime()

					-- ################## unlock item ################## do this
					sl:recordUnlockItem(1)

					-- ################## save data when exit scene ################## do this
					sl:writeFile()

					return
				end

				if i == 2 then
					-- ################## save data when enter scene ################## do this
					sl:readFile()

					if sl:getLockStateByIndex(1) then
						aTestLayer.lockStateLabel:setString("locking")
					else
						aTestLayer.lockStateLabel:setString("unlock")
					end
					return
				end

				if i == 3 then
					getSystemTime = function()
						local year = tostring(os.date("%Y") % 100)
						local day = os.date("%j")
						day = tonumber(day) + 1

						if day < 10 then
							day = "00" .. day
						elseif day < 100 then
							day = "0" .. day
						else
							day = tostring(day)
						end
						return year, day
					end

					__G__CurrentYear, __G__CurrentDay = getSystemTime()

					return
				end
			end
			aTestLayer:addChild(aButton, 1, 100+i)
			aTestLayer:addToTouchResponders(aButton)
			yyyy = yyyy + OFFSET_Y
		end

		return aTestLayer
end

