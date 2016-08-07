--[[---------------------------------------------------------
implementing scratch-out and scratch-in features
-----------------------------------------------------------]]

require("base/Layer")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

-- do scratch in tick or in touch move event handler?
local DO_SCRATCH_IN_TICK = false

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "ScratchLayer"

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
	superClass = Layer,
	-- true for scratch-out, false for scratch-in
	scratchOut = true,
	-- NOTICE: the below scratchSprite and brushSprite MUST be retained properly before passing in
	-- the sprite used to scratch out or in
	scratchSprite = nil,
	-- the sprite used as the mask of scratching brush
	brushSprite = nil,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

	-- should be called whenever we change the self.scratchOut
	-- 1 OPTIONAL argument: doSetBrushSprite, do brush sprite setup if specified
	setupScratch = nil,

    -- reset the brush and relevant stuff
    -- argument: brush sprite (Layer instance)
    resetBrush = nil,

	-- get percentage (0.0 to 1.0) of transparent pixels
	-- argument (OPTIONAL): transparentAlpha (0.0 to <1.0), default is 0.1
	getPercentageTransparent = nil,

	-- override parent's onEnter & onExit
	-- install the tick callback on CCNode's onEnter event
	onEnter = nil,
	-- cleanup on CCNode's onExit event
	onExit = nil,

	-- reset the layer, no arguments
	reset = nil,

	-- the drawing method called every frame, no arguments
	tick = nil,

	-- override parent's methods
	onTouchBegan = nil,
	onTouchMoved = nil,
	onTouchEnded = nil,
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
		local obj = Layer.create()
		obj:ignoreAnchorPointForPosition(false)

        for k, v in pairs(prototype) do
            obj[k] = v
        end

        return obj
    end
)

function cls.create()
	return cls.new()
end

setmetatable(cls, { __index = prototype })

_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

function prototype:setupScratch(doSetBrushSprite)
	local contentSize = self.scratchSprite:getContentSize()

	self:setContentSize(contentSize)

	if not self.renderTexture then
		self.renderTexture = CCEnhancedRenderTexture:create(contentSize.width, contentSize.height)
		self.renderTexture:setPosition(contentSize.width / 2, contentSize.height / 2)
		self:addChild(self.renderTexture)

	    -- local blendFunc = ccBlendFunc()
	    -- blendFunc.src = GL_ONE
	    -- blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA
	    -- self.renderTexture:getSprite():setBlendFunc(blendFunc)
	end

	if doSetBrushSprite then
	    self:resetBrush(self.brushSprite)
	end
end

function prototype:resetBrush(brush)
    self.brushSprite = brush

    local bs = self.brushSprite:getContentSize()
    local bScale = self.brushSprite:getScale()

    self.brushSize = CCSizeMake(bs.width * bScale, bs.height * bScale)

    local blendFuncBrush = ccBlendFunc()
    if self.scratchOut then
        blendFuncBrush.src = GL_ZERO
        blendFuncBrush.dst = GL_ONE_MINUS_SRC_ALPHA
    else
        blendFuncBrush.src = GL_SRC_ALPHA
        blendFuncBrush.dst = GL_ONE_MINUS_SRC_ALPHA

        if self.brushTexture then
            self.brushTexture:release()
            self.brushTexture = nil
        end

        self.brushTexture = CCRenderTexture:create(self.brushSize.width, self.brushSize.height)
        self.brushTexture:retain()

        local bf = ccBlendFunc()
        bf.src = GL_SRC_ALPHA
        bf.dst = GL_ONE_MINUS_SRC_ALPHA
        self.brushTexture:getSprite():setBlendFunc(bf)
    end

    self.brushSprite:setBlendFunc(blendFuncBrush)
end

function prototype:getPercentageTransparent(transparentAlpha)
	return self.renderTexture:getPercentageTransparent(transparentAlpha and transparentAlpha or 0.1)
end

function prototype:onEnter()
	cclog("register scratch tick callback for layer tag %d", self:getTag())
	if DO_SCRATCH_IN_TICK and not self.scheduleTickHandle then
		self.scheduleTickHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:tick() end, 0, false)
	end

	prototype.superClass.onEnter(self)
end

function prototype:onExit()
	cclog("unregister scratch tick callback for layer tag %d", self:getTag())
	if self.scheduleTickHandle and DO_SCRATCH_IN_TICK then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleTickHandle)
		self.scheduleTickHandle = nil
	end

	if self.brushTexture then
		self.brushTexture:release()
        self.brushTexture = nil
	end

	prototype.superClass.onExit(self)
end

function prototype:reset()
	if self.scratchOut then
		local contentSize = self:getContentSize()
		self.scratchSprite:setPosition(contentSize.width / 2, contentSize.height / 2)
		self.renderTexture:beginWithClear(0, 0, 0, 0)
		self.scratchSprite:visit()
		self.renderTexture:endToLua()
	else
		self.renderTexture:clear(0, 0, 0, 0)
	end
end

function prototype:doScratch()
	if self.scratchOut then
		self.brushSprite:setPosition(self.scratchPoint.x, self.scratchPoint.y)
		self.renderTexture:begin()
		self.brushSprite:visit()
		self.renderTexture:endToLua()
	else
		local texture = self.scratchSprite:getTexture()
		local textureSize = texture:getContentSizeInPixels()

		local textureX = self.scratchPoint.x
		local textureY = textureSize.height - self.scratchPoint.y

        local textureSprite = CCSprite:createWithTexture(texture, CCRectMake(textureX - self.brushSize.width / 2, textureY - self.brushSize.height / 2, self.brushSize.width, self.brushSize.height))

        local bf = ccBlendFunc()
        bf.src = GL_DST_ALPHA
        bf.dst = GL_ZERO
        textureSprite:setBlendFunc(bf)

        self.brushSprite:setPosition(self.brushSize.width / 2, self.brushSize.height / 2)
        textureSprite:setPosition(self.brushSize.width / 2, self.brushSize.height / 2)

        self.brushTexture:beginWithClear(0, 0, 0, 0)
        self.brushSprite:visit()
        textureSprite:visit()
        self.brushTexture:endToLua()

        self.brushTexture:setPosition(self.scratchPoint.x, self.scratchPoint.y)
		self.renderTexture:begin()
		self.brushTexture:visit()
		self.renderTexture:endToLua()
	end
end

function prototype:tick()
	if (not DO_SCRATCH_IN_TICK) or (not self.scratchBegan) then
		return
	end

	self:doScratch()
end

function prototype:onTouchBegan(x, y)
	self.scratchBegan = true
	self.scratchPoint = self:convertToNodeSpace(ccp(x, y))

	if not DO_SCRATCH_IN_TICK then
		self:doScratch()
	end

	return prototype.superClass.onTouchBegan(self, x, y)
end

function prototype:onTouchMoved(x, y)
	self.scratchPoint = self:convertToNodeSpace(ccp(x, y))

	if not DO_SCRATCH_IN_TICK then
		self:doScratch()
	end
	
	return prototype.superClass.onTouchMoved(self, x, y)
end

function prototype:onTouchEnded(x, y)
	self.scratchBegan = false
	return prototype.superClass.onTouchEnded(self, x, y)
end
