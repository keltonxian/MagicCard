
--==================================================
--	@Brief:    游戏计数器（用于3,2,1倒数等）
--	@Author:   Rios - CMY
--	@Date:     2015-07-16
--==================================================


local counterName = "Counter"
local parentOfCounter = Layer

local counterPrototype = {
	superClass = parentOfCounter,
	tickStep = 1,
	timeCount = 30,
	curTimeCount = 0,
	theCounterName = nil,

	tick = nil,
	setTimeCount = nil,
	setTickStep = nil,
	openCounter = nil,
	closeCounter = nil,
	
	tickBeforeCallback = nil,
	tickCallback = nil,
	tickOverCallback = nil,

	setTickBeforeCallback = nil,
	setTickCallback = nil,
	setTickOverCallback = nil,
}

local Counter = Counter or class(counterName, function()
	local obj = parentOfCounter.create()
	for k, v in pairs(counterPrototype) do
        obj[k] = v
    end
	return obj
end)


function Counter:ctor(args)
	self:setTimeCount(args.timeCount)
	self:setTickStep(args.tickStep)
end

function Counter.create(args)
    local obj = Counter.new(args)
    return obj
end

_G[counterName] = Counter

function Counter:tick()
	if self.curTimeCount < self.timeCount then
		if self.tickCallback then self:tickCallback() end
		self.curTimeCount = self.curTimeCount + 1
	else
		self:closeCounter()
	end
end

function Counter:openCounter()
	self.curTimeCount = 0
	if self.tickBeforeCallback then self:tickBeforeCallback() end
	if not self.theCounterName then
		self.theCounterName = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:tick() end, self.tickStep, false)
	end
end

function Counter:closeCounter()
	if self.theCounterName then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.theCounterName)
		self.theCounterName = nil
	end
	if self.tickOverCallback then
		self:tickOverCallback()
	end
end

----------------------------------------------------
-- Call back
----------------------------------------------------

function Counter:tickBeforeCallback()
	cclog("********************** call tickBeforeCallback")
end

function Counter:tickCallback()
	cclog("********************** call tickCallback, curTimeCount = %d", self.curTimeCount)
end

function Counter:tickOverCallback( ... )
	cclog("********************** call tickOverCallback")
end

----------------------------------------------------
-- getter and setter
----------------------------------------------------

function Counter:setTimeCount(timeCount)
	if timeCount and timeCount > 0 then self.timeCount = timeCount end
end

function Counter:setTickStep(tickStep)
	if tickStep and tickStep > 0 then self.tickStep = tickStep end
end

function Counter:setTickBeforeCallback(func)
 	self.tickBeforeCallback = func
end

function Counter:setTickCallback(func)
 	self.tickCallback = func
end

function Counter:setTickOverCallback(func)
 	self.tickOverCallback = func
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function Counter:test()
	local startCounter = Counter.create({timeCount = 4, tickStep = 1})
	startCounter.numbersImage = {"image/samples/counter/3.png", "image/samples/counter/2.png", "image/samples/counter/1.png", "image/samples/counter/go.png"}
	startCounter.numbersVidio = {"sfx/counter/3.mp3", "sfx/counter/2.mp3", "sfx/counter/1.mp3", "sfx/counter/go.mp3"}
	startCounter.numbersLayer = {}
	startCounter.runNumerAction = function(self, index)
		local l = startCounter.numbersLayer[index]
		local dt = 0.4
		local arr1 = CCArray:create()
		arr1:addObject(CCCallFunc:create(function()
			l:setVisible(true)
			AudioEngine.playEffect(startCounter.numbersVidio[index], false)
		end))
		arr1:addObject(CCScaleTo:create(dt,__G__iOSValue2(1.2, 1.5)))
		arr1:addObject(CCScaleTo:create(dt,__G__iOSValue2(2.0, 3.0)))
		arr1:addObject(CCCallFunc:create(function()
			l:setScale(1)
			l:setVisible(false)
		end))
		l:runAction(CCSequence:create(arr1))
	end
	startCounter:setTickCallback(function()
		local index = startCounter.curTimeCount + 1
		if not startCounter.numbersLayer[index] then
			startCounter.numbersLayer[index] = SpriteLayer.create(startCounter.numbersImage[index])
			startCounter.numbersLayer[index]:setPosition(__G__canvasCenter)
			startCounter:addChild(startCounter.numbersLayer[index], 100, index)
		end
		startCounter:runNumerAction(index)
	end)

	startCounter:openCounter()

	return startCounter
end

