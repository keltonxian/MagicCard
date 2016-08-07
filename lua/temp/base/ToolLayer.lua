--[[---------------------------------------------------------
encapsulate basic functions for SALON game's spa / makup tools
-----------------------------------------------------------]]

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

TOOL_MAX_ZORDER = 100860

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "ToolLayer"
local ccParent = ButtonLayer  -- any Cocos2d-X class or its subclass (both native subclass and Lua subclass are ok)

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = ccParent,

    -- can be picked up or not
    canPickUp = true,
    -- scale and rotation when pick up
    scaleOnPickUp = 1.0,

    scaleOrigin = 1.0,

    rotateOnPickUp = 0.0,

    rotateOrigin = 0.0,

    spriteStateOnPickUp = nil,

    changeNormalSprite = false,

    -- the local coordinates of the tool point, default is the center of the sprite
    toolPointLocal = nil,

    -- the toolPoint is the calculated touch point based on the actual touch coordinates and the toolPointLocal
    -- should be used as the scratch point
    toolPoint = nil,

    -- misc settings
    pickUpAnimationDuraton = 0.2,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- allow multiple handlers for touch began, moved and ended events; like chain of action
    -- argument: touch event handler which is invoked with 3 arguments (sender, x, y)
    addTouchBeganAction = nil,
    addTouchMovedAction = nil,
    addTouchEndedAction = nil,

	noTouchDim = false,
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
        local obj = ccParent.create()

        -- MUST copy the prototype attributes to it
        for k, v in pairs(prototype) do
            obj[k] = v
        end

        -- disable button's default onTouchAnimation and autoState and dimOnPress
        obj.enableOnTouchAnimation = false
        obj.enableAutoState = false
        obj.dimOnPress = false

        -- action chain
        obj._touchBeganActions = {}
        obj._touchMovedActions = {}
        obj._touchEndedActions = {}

        return obj
    end
)

-- constructor definition
-- arguments: sprite (the CCSprite object / Layer object / Lua string), attrs (table, attributes)
-- return the object of class
function cls.create(sprite, attrs)
    local obj = cls.new()

    obj:setStateSprite(sprite, "normal")

    -- use the center point as the default toolPointLocal
    local s = obj:getContentSize()
    obj.toolPointLocal = { x = s.width / 2, y = s.height / 2 }

    if type(attrs) == "table" then
        for k, v in pairs(attrs) do
            obj[k] = v
        end
    end

    if obj.canPickUp then
        obj.moveOnTouch = true
        obj.restoreOnTouchEnded = true
    end

    obj:setScale(obj.scaleOrigin)
    obj:setRotation(obj.rotateOrigin)

    return obj
end

-- let the cls inherit all the attributes from prototype
setmetatable(cls, { __index = prototype })

-- export the cls to package
_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

function prototype:updateToolPoint(x, y)
    -- rotation counted: http://en.wikipedia.org/wiki/Rotation_(mathematics)
    local sin, cos = math.sin(math.rad(-(self.rotateOnPickUp+self.rotateOrigin))), math.cos(math.rad(-(self.rotateOnPickUp+self.rotateOrigin)))

    local p = self:convertToNodeSpace(ccp(x, y))
    local localPoint = ccp(0, 0)
    localPoint.x = p.x * cos - p.y * sin
    localPoint.y = p.x * sin + p.y * cos

    local tp = ccp(0, 0)
    tp.x = self.toolPointLocal.x * cos - self.toolPointLocal.y * sin
    tp.y = self.toolPointLocal.x * sin + self.toolPointLocal.y * cos

    local offsetX = (localPoint.x - tp.x) * self:getScaleX()
    local offsetY = (localPoint.y - tp.y) * self:getScaleY()
    self.toolPoint = ccp(x - offsetX, y - offsetY)
end

function prototype:addTouchBeganAction(action)
    table.insert(self._touchBeganActions, action)
end

function prototype:addTouchMovedAction(action)
    table.insert(self._touchMovedActions, action)
end

function prototype:addTouchEndedAction(action)
    table.insert(self._touchEndedActions, action)
end

function prototype:onTouchBegan(x, y)
    if self.benchParent then
        if self.canPickUp then
            self.benchParent:toggleToolShadow(self:getTag(), false)
        end
    end

    if self.spriteStateOnPickUp then
        self:setState(self.spriteStateOnPickUp)
    end

    if self.bounceTool and self.bounceTool.changeNormalSprite and self.bounceTool.spriteStateOnPickUp then
        self.bounceTool:setState(self.bounceTool.spriteStateOnPickUp)
    end

    if self.scaleOnPickUp ~= 1.0 then
        --[[  DO NOT scale with animation cause SpriteLayer.onTouchBegan will make use of the current scale value
        local action = CCSpawn:createWithTwoActions(
            CCScaleTo:create(self.pickUpAnimationDuraton, self.scaleOnPickUp),
            CCRotateTo:create(self.pickUpAnimationDuraton, self.rotateOnPickUp)
        )
        self:runAction(action)
        ]]
        local _scale = self.scaleOnPickUp*self.scaleOrigin
        self:setScale(_scale)
    end

    self._toolOrigZOrder = self:getZOrder()
    self:setZOrder(TOOL_MAX_ZORDER)

    -- move first then roate, especially when moveOnTouchAutoCenter is set
    local ret = prototype.superClass.onTouchBegan(self, x, y)

    self:updateToolPoint(x, y)

    for _, v in pairs(self._touchBeganActions) do
        v(self, x, y)
    end

    if not self.rotateOnPickUp ~= 0.0 then
        self:runAction(CCRotateTo:create(self.pickUpAnimationDuraton, (self.rotateOnPickUp+self.rotateOrigin)))
    end

    return ret
end

function prototype:onTouchMoved(x, y)
    self:updateToolPoint(x, y)

    for _, v in pairs(self._touchMovedActions) do
        v(self, x, y)
    end

    return prototype.superClass.onTouchMoved(self, x, y)
end

function prototype:onTouchEnded(x, y)
    if self.spriteStateOnPickUp then
        self:setState("normal")
    end

    if self.bounceTool and self.bounceTool.changeNormalSprite and self.bounceTool.spriteStateOnPickUp then
        self.bounceTool:setState("normal")
    end

    if self.scaleOnPickUp ~= 1.0 or self.rotateOnPickUp ~= 0.0 then
        local action = CCSpawn:createWithTwoActions(
            CCScaleTo:create(self.pickUpAnimationDuraton, self.scaleOrigin),
            CCRotateTo:create(self.pickUpAnimationDuraton, self.rotateOrigin)
        )
        self:runAction(action)
    end

    if self.benchParent then
        if self.canPickUp then
            local delay = 0.2
            performWithDelay( self.benchParent, function() self.benchParent:toggleToolShadow(self:getTag(), true) end, delay)       
        else
            self.benchParent:toggleToolShadow(self:getTag(), true)
        end
    end

    if self._toolOrigZOrder then
        self:setZOrder(self._toolOrigZOrder)
    end

    self:updateToolPoint(x, y)

    for _, v in pairs(self._touchEndedActions) do
        v(self, x, y)
    end

    if self.canPickUp then
        self.touchEndSound = self.touchEndSound or config_sound_effects.common_tool_end
    end

    return prototype.superClass.onTouchEnded(self, x, y)
end
