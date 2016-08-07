--[[---------------------------------------------------------
as the replacement of CCSprite which has preset touch event handling, subclassed from Layer
-----------------------------------------------------------]]

require("base/Layer")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "SpriteLayer"

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = Layer,

	-- auto resize self's contentSize according to Sprite's contentSize
	autosize = true,

	-- move self on touch
	moveOnTouch = false,
	moveOnTouchAutoCenter = false,
	moveOnTouchCenterOffset = nil,
	moveOnTouchPointAdaptor = nil,
	moveBounds = nil,  -- rect instance, use CCRectMake

	-- go to original position when touch ended
	restoreOnTouchEnded = false,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- argument: a CCSprite object
	setSprite = nil,
	-- no argument, return the CCSprite object which is sent into before
	getSprite = nil,

	-- override parent's touch handling methods
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

		obj.moveOnTouchCenterOffset = ccp(0, 0)

		return obj
	end
)

--[[
	create()
	create(sprite)  -- CCSprite instance / Layer instance / string
	create(width, height)
]]
function cls.create(...)
	local obj = cls.new()
	local arg = {...}

	if #arg == 1 then
		obj:setSprite(arg[1])
	elseif #arg == 2 then
		obj:setContentSize(CCSizeMake(arg[1], arg[2]))
		-- doesn't work any longer since Layer is derived from CCLayer rather than CCLayerColor
		-- obj:setColor(tolua.cast(arg[3], "ccColor3B"))
		-- obj:setOpacity(arg[4])
	end

	return obj
end

setmetatable(cls, { __index = prototype })

_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

local kTagSprite = 10086

function prototype:setSprite(sprite)
	local oldPosition = nil
	local oldSprite = self:getSprite()
	if oldSprite then
		oldPosition = ccp(oldSprite:getPosition())
		self:removeChildByTag(kTagSprite, true)
	end

	if type(sprite) == "string" then
		sprite = CCSprite:create(sprite)
	end

	if oldPosition then
		sprite:setPosition(oldPosition)
	else
		if self.autosize then
			self:setContentSize(sprite:getContentSize())
		end

		local contentSize = self:getContentSize()
		sprite:setPosition(contentSize.width / 2, contentSize.height / 2)
	end
	
	self:addChild(sprite, 0, kTagSprite)
end

function prototype:getSprite()
	return tolua.cast(self:getChildByTag(kTagSprite), "CCSprite")
end

function prototype:onTouchBegan(x, y)
	if self.moveOnTouch then
		if self.restoreOnTouchEnded then
			self.originalPosition = ccp(self:getPosition())
		end

		local scaleX, scaleY = self:getScaleX(), self:getScaleY()
		local parentPoint = self:getParent():convertToNodeSpace(ccp(x, y))

		if self.moveOnTouchAutoCenter then
						
			if self.moveOnTouchPointAdaptor then
				local _offsetX, _offsetY = self.moveOnTouchPointAdaptor(self, x, y)
				self.moveOnTouchCenterOffset.x = _offsetX
				self.moveOnTouchCenterOffset.y = _offsetY
			end

			local newCenter = ccp(parentPoint.x - self.moveOnTouchCenterOffset.x * scaleX, parentPoint.y - self.moveOnTouchCenterOffset.y * scaleY)
			--[[ DO NOT use animation here caues it may lead to some consistency problem (refer to the code in ToolLayer.onTouchBegan)
			self:runActionSafe(CCMoveTo:create(0.1, newCenter))
			]]
			self:setPosition(newCenter.x, newCenter.y)
		else
			self.touchOffset = ccp(parentPoint.x - self:getPositionX(), parentPoint.y - self:getPositionY())
		end
	end

	-- NOTE: always use protopye.superClass
	-- DO NOT use self.superClass otherwise it would lead to infinite loop of "self.superClass" invocation
	return prototype.superClass.onTouchBegan(self, x, y)
end

function prototype:onTouchMoved(x, y)
	if self.moveOnTouch then
		local parentPoint = self:getParent():convertToNodeSpace(ccp(x, y))
		local scaleX, scaleY = self:getScaleX(), self:getScaleY()

		local newCenter = nil
		if self.moveOnTouchAutoCenter then
			newCenter = ccp(parentPoint.x - self.moveOnTouchCenterOffset.x * scaleX, parentPoint.y - self.moveOnTouchCenterOffset.y * scaleY)
		else
			newCenter = ccp(parentPoint.x - self.touchOffset.x, parentPoint.y - self.touchOffset.y)
		end

		-- should tune the following code according to scaleX and scaleY
		if self.moveBounds then
			local boundsMin = self:getParent():convertToNodeSpace(ccp(self.moveBounds:getMinX(), self.moveBounds:getMinY()))
			local boundsMax = self:getParent():convertToNodeSpace(ccp(self.moveBounds:getMaxX(), self.moveBounds:getMaxY()))

			local s = self:getContentSize()

			if newCenter.x - s.width / 2 < boundsMin.x then
				newCenter.x = boundsMin.x + s.width / 2
			elseif newCenter.x + s.width / 2 > boundsMax.x then
				newCenter.x = boundsMax.x - s.width / 2
			end

			if newCenter.y - s.height / 2 < boundsMin.y then
				newCenter.y = boundsMin.y + s.height / 2
			elseif newCenter.y + s.height / 2 > boundsMax.y then
				newCenter.y = boundsMax.y - s.height / 2
			end
		end

		-- which one is more smooth for the "drag movement" specially in low speed?

		-- OPTION 0: set position without any modification
		self:setPosition(newCenter.x, newCenter.y)

		-- OPTION 1: try to filter out the jitter while moving slowly
		-- if (not self.oldCenter) or
		-- 	(math.abs(self.oldCenter.x - newCenter.x) >= 1) or
		-- 	(math.abs(self.oldCenter.y - newCenter.y) >= 1) or
		-- 	((math.abs(self.oldCenter.x - newCenter.x) >= 0.5) and (math.abs(self.oldCenter.y - newCenter.y) >= 0.5)) then
		-- 		self:setPosition(newCenter.x, newCenter.y)
		-- 		self.oldCenter = newCenter
		-- end

		-- OPTION 2: use moveTo animation
		-- see: http://stackoverflow.com/questions/2020752/smoothly-drag-a-sprite-in-cocos2d-iphone
		-- if 0 == self:numberOfRunningActions() then
		-- 	self:runAction(CCEaseIn:create(CCMoveTo:create(0.018, newCenter), 2))
		-- end
	end

	return prototype.superClass.onTouchMoved(self, x, y)
end

function prototype:onTouchEnded(x, y)
	if self.moveOnTouch and self.restoreOnTouchEnded then
		self:runActionSafe(CCMoveTo:create(0.2, self.originalPosition))
	end

	return prototype.superClass.onTouchEnded(self, x, y)
end
