--[[---------------------------------------------------------
providing basic button functions
-----------------------------------------------------------]]

require("base/SpriteLayer")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "ButtonLayer"
local ccParent = SpriteLayer  -- any Cocos2d-X class or its subclass (both native subclass and Lua subclass are ok)

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = ccParent,

    -- sound on touch, if nil, use defaultTouchSound; no sound if both are nil
    touchSound = nil,

    --sound on touch end (usually use for ToolLayer)
    touchEndSound = nil,

    -- need animation on touch or not
    enableOnTouchAnimation = true,
    -- auto change button state on touch began (changed to "selected") and touch ended (restored to "normal")
    enableAutoState = false,

    -- 3 sprites for 3 different button states
    -- for custom states, can access their sprites by "xxxxSprite", say, you have a custom state by setStateSprite(..., "pickup"), then you can access the sprite through obj.pickupSprite
    normalSprite = nil,
    selectedSprite = nil,
    disabledSprite = nil,

    -- misc settings
    defaultTouchSound = nil,

    -- the minimum interval between 2 clicks, the button will be disabled between 2 clicks if minClickInterval is greater than 0
    minClickInterval = 0,

    -- dim the button on press
    dimOnPress = true,

    -- button click callback, guarantee it's called after the default click animation completed
    -- NOTE: if you override the onTouchAnimation, the clickHandler won't be called so you must do this in your own onTouchAnimation
    -- argument: sender (the button instance itself)
    clickHandler = nil,
    -- true if wanna trigger the above clickHandler on touch ended
    doClickHandlerOnTouchEnded = false,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- override it if new animation is needed; default animation is a simple scale up and down
    onTouchAnimation = nil,

    -- argument: state string (3 preset states: "normal", "selected", "disabled"; can be other custom states)
    setState = nil,

    -- argument: sprite (sprite object or string), state string ("normal", "selected", "disabled" or any other custom states)
    setStateSprite = nil,
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

        obj._states = {}

        return obj
    end
)

-- constructor definition
-- arguments: normal, selected, disabled; all are optional, can be CCSprite or Layer or even Lua string
-- return the object of class
function cls.create(normal, selected, disabled)
    local obj = cls.new()

    if normal then
        obj:setStateSprite(normal, "normal")
    end

    if selected then
        obj:setStateSprite(selected, "selected")
    end

    if disabled then
        obj:setStateSprite(disabled, "disabled")
    end

    obj:setState("normal")

    return obj
end

-- let the cls inherit all the attributes from prototype
setmetatable(cls, { __index = prototype })

-- export the cls to package
_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

function prototype:onTouchAnimation()
    if self._touchAnimating then
        if self.clickHandler and not self.doClickHandlerOnTouchEnded then self:clickHandler() end
    else
        self._touchAnimating = true
        local origScale = self:getScale()
        local actionArray = CCArray:create()
        actionArray:addObject(CCScaleTo:create(0.1, origScale * 1.2))
        actionArray:addObject(CCScaleTo:create(0.1, origScale))
        if self.clickHandler and not self.doClickHandlerOnTouchEnded then
            actionArray:addObject(CCCallFunc:create(function() self:clickHandler() end))
        end
        actionArray:addObject(CCCallFunc:create(function() self._touchAnimating = false end))
        self:runAction(CCSequence:create(actionArray))
    end
end

function prototype:setState(state)
    local target = self[state .. "Sprite"]

    if target then
        for _, s in pairs(self._states) do
            local sprite = self[s .. "Sprite"]
            if sprite then
                sprite:setVisible(s == state)
            end
        end

        -- this affects touchHit as well so contentSize must be updated
        local size = target:getContentSize()
        self:setContentSize(size)
        target:setPosition(size.width / 2, size.height / 2)
    else
        -- if no target state sprite, then keep the state unchanged
    end

    --[[ NOT change this attribute implicitly
    self.isTouchEnabled = not (state == "disabled")
    ]]
end

function prototype:setStateSprite(sprite, state)
    if type(sprite) == "string" then
        sprite = CCSprite:create(sprite)
    end

    local spriteAttr = state .. "Sprite"
    local x, y, z, visible

    if self._states["normal"] then
        x, y = self.normalSprite:getPosition()  -- use the same position as "normal" state sprite
    else
        local s = sprite:getContentSize()
        x, y = s.width / 2, s.height / 2
    end

    if self._states[state] then
        z = self[spriteAttr]:getZOrder()  -- use the old Z order
        visible = self[spriteAttr]:isVisible()
    else
        z = #self._states
        visible = (state == "normal")
    end

    sprite:setPosition(x, y)
    sprite:setVisible(visible)

    if state == "normal" then
        self:setSprite(sprite)
        sprite:setZOrder(z)
    else
        if self[spriteAttr] then
            self:removeChild(self[spriteAttr], true)
        end
        self:addChild(sprite, z)
    end

    self[spriteAttr] = sprite
    if not self._states[state] then
        -- let _states["normal"] == "normal"
        self._states[state] = state
    end
end

function prototype:onTouchBegan(x, y)
    local sound = self.touchSound or self.defaultTouchSound
    if sound then
        AudioEngine.playEffect(sound, false)
    end

    if self.enableAutoState then
        self:setState("selected")
    end

    if self.enableOnTouchAnimation then
        self:onTouchAnimation()  -- clickHandler is called inside
    else
        if self.clickHandler and not self.doClickHandlerOnTouchEnded then
            self:clickHandler()
        end
    end

    if self.dimOnPress then
        Utils:sharedUtils():setColorDim(self, true)
    end

    return prototype.superClass.onTouchBegan(self, x, y)
end

function prototype:onTouchMoved(x, y)
    return prototype.superClass.onTouchMoved(self, x, y)
end

function prototype:onTouchEnded(x, y)
    local sound = self.touchEndSound
    if sound then
        AudioEngine.playEffect(sound, false)
    end

    if self.enableAutoState then
        self:setState("normal")
    end

    -- must call after setState because setState may change the isTouchEnabled
    if self.minClickInterval > 0 then
        self.isTouchEnabled = false
        performWithDelay(self, function() self.isTouchEnabled = true end, self.minClickInterval)
    end

    if self.dimOnPress then
        Utils:sharedUtils():setColorDim(self, false)
    end

    if self.doClickHandlerOnTouchEnded and self.clickHandler then
        self:clickHandler()
    end

    return prototype.superClass.onTouchEnded(self, x, y)
end
