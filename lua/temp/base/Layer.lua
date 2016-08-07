--[[---------------------------------------------------------
Layer: the very basic class of other graphical elements, providing basic touch event handling and dispatching and other handy functions
-----------------------------------------------------------]]

require("lib/extern")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

-- this variable is supposed to be set outside through Layer.setGlobalTouchIntercepted
-- it ought to be set true when a poped up interstitial ads or news blast window done
local GLOBAL_TOUCH_INTERCEPTED = false

-- maximum touchPriority, it's supposed to be set when the Layer object is hit and receives all the following touch events
MAX_TOUCH_PRIORITY = 99999999

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "Layer"
-- local ccParent = CCLayerColor
-- for the sake performance, user CCLayer instead
local ccParent = CCLayer

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = ccParent,

    -- it is altered in addToTouchResponders / removeFromTouchResponders automatically
    -- also it can be set manually, when set, the touchHit always returns false
    -- should be set to false when running action on the Layer object
    isTouchEnabled = false,

    -- handy touch events handler, will be called with arguments: sender, x, y
    touchBeganHandler = nil,
    touchMovedHandler = nil,
    touchEndedHandler = nil,

    -- handy tap (aka. touch ended) event handler, will be called with argument: sender (self)
    tapHandler = nil,

    -- the Layer instance which dispatches touch event
    touchDispatcher = nil,

    -- priority to respond to touch events, the bigger value the higher priority
    -- should always use setTouchPriority to set it
    touchPriority = 0,

    -- scale factors of the touch hitbox (enlarge / shrink the touch hitbox based on the actual content size of the layer)
    touchHitScaleX = 1.0,
    touchHitScaleY = 1.0,

    -- not allow to pass the touch event along the responder link if true; default: true
    -- WARNING: change this may cause very weird behavior
    swallowTouch = true,

    -- if true, ignore touch handling when touches fall on transparent area (that means touch hits no sublayers)
    -- should use it carefully; default: false
    touchThroughTransparent = false,
    -- do similar thing as touchThroughTransparent, but it will check if the touch hits transparent pixels
    -- use it with greater carefulness cause transparent pixel hit test is a bit expensive
    touchThroughTransparentStrict = false,

    touchContainsExtendChildren = false,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- detect if the given touch point is inside the responsive area of the layer
    -- arguments: x, y
    -- return true or false
    touchHit = nil,

    -- default touch event handling, subclass should override them to change the default behavior
    -- arguments: x, y
    -- onTouchBegan must returns true if it allows consequent events being sent
    onTouchBegan = nil,
    onTouchMoved = nil,
    onTouchEnded = nil,

    -- the touch event dispatching method, subclass should override it carefully to change the touch dispatching logic
    -- arguments: eventType ("began", "moved", "ended", "cancelled"), x, y
    onTouch = nil,

    -- install / uninstall the touch event dispatching facility
    -- argument: enabled (Boolean)
    enableTouchDispatching = nil,

    -- install / uninstall the keypad event dispatching facility
    -- argument: enabled (Boolean)
    enableKeypadHandling = nil,

    -- set touch priority, and adjust the order of touch responders link accordingly
    -- argument: priority
    setTouchPriority = nil,

    -- return the touchPriority
    getTouchPriority = nil,

    -- add to / remove from the touch responders link to receive / decline the dispatched touch events
    -- argument: Layer object
    addToTouchResponders = nil,
    removeFromTouchResponders = nil,
    -- no argument
    removeAllTouchResponders = nil,

    -- should be called every time when children's touchPriority changes
    -- no arguments
    reorderTouchResponders = nil,

    --[[
    layout self (add Layer instances as children) via configuration data (the only argument).
    the argument data format is as below:
        {
            -- child #1
            {
                x =,                        -- (x, y), the bottom left coordinates
                y =,
                z =,                        -- the z order in the CCNode tree
                tag =,                      -- IMPORTANT: children are retrieved by tag usually
                touch =,                    -- touch priority, any values < 0 will be treated as "NOT RESPONDING TOUCH EVENTS"
                class =,                    -- MUST be Layer or Layer's subclass
                width =,                    -- (OPTIONAL)
                height =,                   -- (OPTIONAL)
                color =,                    -- (OPTIONAL) a object created with ccc3
                opacity =,                  -- (OPTIONAL) 0~255
                scale =,                    -- (OPTIONAL) scale factor for both x & y
                image =,                    -- (OPTIONAL) image name to setup the SpriteLayer instance
                spriteFrameName =,          -- (OPTIONAL) sprite frame name
                visible=,                   -- (OPTIONAL) visible or not
                attributes =,               -- (OPTIONAL) extra attributes, in a table form ({ attr1 = value1, ... })
                layout =,                   -- (OPTIONAL) nested layout method: call child's layout method
            },
            ...
        }
    ]]
    layout = nil,

    -- handlers which are invoked when CCNode's onEnter, onExit or any other relevant events are triggered
    -- subclass should override them to do necessary work (initialize, cleanup, etc) there
    -- no arguments
    onEnter = nil,
    onExit = nil,
    onEnterTransitionFinish = nil,
    onExitTransitionStart = nil,
    onCleanup = nil,

    -- argument: true of false
    setGlobalTouchIntercepted = nil,

    -- disabled the touch handling when running action so I call it "run action safe"
    -- argument: action
    runActionSafe = nil,

    -- 触摸点偏移
    moveTouchOffset = {x = 0, y = 0},
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
        -- create a transparent CCLayerColor object
        -- local obj = ccParent:create(ccc4(0x00, 0x00, 0x00, 0x00))
        local obj = ccParent:create()

        -- touch responder link, using Lua weak table
        -- MUST put member variables of type "table" inside here
        -- otherwise, they will become "class member variable" rather than "instance member variable"
        obj.touchResponders = {}
        setmetatable(obj.touchResponders, { __mode = "v" })

        for k, v in pairs(prototype) do
            obj[k] = v
        end

        return obj
    end
)

-- the one and only object constructor method, should always use it to spawn the Layer object
-- no arguments
function cls.create()
    local obj = cls.new()

    -- handle CCNode's onEnter and onExit event
    local function ccnodeEventHandler(eventType)
        if eventType == "enter" then
            obj:onEnter()
        elseif eventType == "exit" then
            obj:onExit()
        elseif eventType == "enterTransitionFinish" then
            obj:onEnterTransitionFinish()
        elseif eventType == "exitTransitionStart" then
            obj:onExitTransitionStart()
        elseif eventType == "cleanup" then
            obj:onCleanup()
        end
    end
    obj:registerScriptHandler(ccnodeEventHandler)

    return obj
end

setmetatable(cls, { __index = prototype })

cls.prototype = prototype

_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

function prototype:touchHit(x, y)
    if not self.isTouchEnabled or not self:isVisible() then
        return false
    end

    local size = self:getContentSize()
    local ox = (size.width * self.touchHitScaleX - size.width) / 2
    local oy = (size.height * self.touchHitScaleY - size.height) / 2
    local rect = CCRectMake(-ox+self.moveTouchOffset.x, -oy+self.moveTouchOffset.y, size.width * self.touchHitScaleX, size.height * self.touchHitScaleY)
    -- local ret = rect:containsPoint(self:convertToNodeSpace(ccp(x, y)))
    local localPoint = self:convertToNodeSpace(ccp(x,y))
    local ret = rect:containsPoint(localPoint)

    if ret then
        if self.touchThroughTransparentStrict then
            -- do strict pixel transparency detection
            cclog("+++++ touchThroughTransparentStrict +++++")
            -- ret = not Utils:transparentHitTest(self, ccp(x, y))
            ret = not Utils:transparentHitTest(self, localPoint)
        elseif self.touchThroughTransparent then
            ret = false  -- assume touch falls on transparent area

            -- check every sublayers see if touch really hit the transparent area
            for _, b in pairs(self.touchResponders) do
                if b:touchHit(x, y) then
                    ret = true
                    break
                end
            end
        end
    elseif self.touchContainsExtendChildren then
        local _touchResponders = self.touchResponders
        if self.superClass == ScrollLayer then
            if self.container and type(self.container.touchResponders) == "table" then
                _touchResponders = self.container.touchResponders
            end
        end
        for _, b in pairs(_touchResponders) do
            if b:touchHit(x, y) then
                ret = true
                break
            end
        end
    end

    return ret
end

function prototype:onTouchBegan(x, y)
    local ret = nil

    if self.touchBeganHandler then
        ret = self.touchBeganHandler(self, x, y)
    end

    if ret == nil then
        ret = true
    end

    return ret  -- returning false indicates touchMoved and touchEnded would not be triggered
end

function prototype:onTouchMoved(x, y)
    if self.touchMovedHandler then
        self.touchMovedHandler(self, x, y)
    end
end

function prototype:onTouchEnded(x, y)
    if self.touchEndedHandler then
        self.touchEndedHandler(self, x, y)
    end

    if self.tapHandler then
        self.tapHandler(self)
    end
end

function prototype:onTouch(eventType, x, y)
    --[[
    NOTE: the following code is for Android; Android will put the app into background when the interstitial ads shown (completely different from iOS);
    however, the app (the GL view actually) is still receiving touch events till you release your finger;
    it's principle in Android development that updateing UI from non-UI thread may likely cause app crash, so the above situation will easily crash the app;
    so I do the following trick to discard all the "in background touch events" to resolve this problem.
    ]]
    if __G__isBackground and __G__isAndroid then
        cclog("++++++ discard touch events when application is in background ++++++")
        return false
    end

    -- no multiple touch events at the same time
    if eventType == "began" then
        if self.touchHasBegan then
            if GLOBAL_TOUCH_INTERCEPTED then
                -- emmit a "touch ended" event then continue the "touch began" process
                -- this is a special patch to resolve the "interstitial ads interrupts touche event handling" problem
                self:onTouch("ended", x, y)
            end

            -- not allow mutliple touches
            return false
        end
        self.touchHasBegan = true
    elseif eventType == "ended" or eventType == "cancelled" then
        if not self.touchHasBegan then
            return true
        end

        self.touchHasBegan = false
    end

    GLOBAL_TOUCH_INTERCEPTED = false

    for _, v in ipairs(self.touchResponders) do

        local flag = v.touchPriority == MAX_TOUCH_PRIORITY
        if not flag then
            if eventType == "began" then
                flag = v:touchHit(x, y)
            end
        end

        if flag then
            if eventType == "began" then
                v.oldTouchPriority = v.touchPriority
                v:setTouchPriority(MAX_TOUCH_PRIORITY)
            elseif eventType == "moved" then
                --
            elseif eventType == "ended" then
                --
            elseif eventType == "cancelled" then
                -- ignore it for the time being
            end

            -- only invoke the touch handler when touch has began
            if v.touchPriority == MAX_TOUCH_PRIORITY then
                local ret = v:onTouch(eventType, x, y)

                if eventType == "ended" or eventType == "cancelled" then
                    v:setTouchPriority(v.oldTouchPriority)
                end

                if v.swallowTouch then
                    return ret
                end
            end
        end
    end

    if eventType == "began" then
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        return self:onTouchMoved(x, y)
    elseif eventType == "ended" then
        return self:onTouchEnded(x, y)
    elseif eventType == "cancelled" then
        return self:onTouchEnded(x, y)
    end
end


function prototype:enableTouchDispatching(enabled)
    self:setTouchEnabled(enabled)

    if enabled then
        self:registerScriptTouchHandler(function(eventType, x, y) return self:onTouch(eventType, x, y)  end)
    else
        self:unregisterScriptTouchHandler()
    end
end

function prototype:setTouchPriority(priority)
    if priority ~= self.touchPriority then
        self.touchPriority = priority
        if self.touchDispatcher then
            self.touchDispatcher:reorderTouchResponders()
        end
    end
end

function prototype:getTouchPriority()
    return self.touchPriority
end

function prototype:addToTouchResponders(child)
    child.isTouchEnabled = true
    child.touchDispatcher = self

    local inserted = false
    for i, r in ipairs(self.touchResponders) do
        if r.touchPriority <= child.touchPriority then
            table.insert(self.touchResponders, i, child)
            inserted = true
            break
        end
    end

    if not inserted then
        table.insert(self.touchResponders, child)
    end
end

function prototype:removeFromTouchResponders(child)
    child.isTouchEnabled = false
    child.touchDispatcher = nil

    for i, r in ipairs(self.touchResponders) do
        if r == child then
            table.remove(self.touchResponders, i)
            break
        end
    end
end

function prototype:removeAllTouchResponders()
    -- see: http://stackoverflow.com/questions/4880368/how-to-delete-all-elements-in-a-lua-table
    for k in pairs(self.touchResponders) do
        self.touchResponders[k] = nil
    end
end

function prototype:reorderTouchResponders()
    table.sort(self.touchResponders, 
        function(a, b) 
            if a.touchPriority == b.touchPriority then
                return a:getZOrder() > b:getZOrder()
            else
                return a.touchPriority > b.touchPriority 
            end
        end)
end

function prototype:layout(data)
    for _, d in ipairs(data) do
        local child = d.class.create()

        local sprite = nil
        if d.image then
            sprite = CCSprite:create(d.image)
            if nil == sprite then print("error layout image not found", d.image) end
        elseif d.spriteFrameName then
            sprite = CCSprite:createWithSpriteFrameName(d.spriteFrameName)
            if nil == sprite then 
				print("error layout sprite frame not found", d.spriteFrameName) 
			end
        end

        if sprite then
            if d.class == SpriteLayer then
                child:setSprite(sprite)
            elseif d.class == ButtonLayer then
                child:setStateSprite(sprite, "normal")
                child:setState("normal")
            end
        end

        if d.width and d.height then
            child:setContentSize(CCSizeMake(d.width, d.height))
        end

        if d.scale then
            child:setScale(d.scale)
        end

        local contentSize = child:getContentSize()
        
        ------------------------------------------
        if type(d.xy)=="function" then --function(parent,node) end
            local pos = d.xy(self,child)
            d.x, d.y = pos.x, pos.y

            d.use_box_size = true
            d.ignore_half_size = true
        end
        if d.use_box_size then
            contentSize = child:boundingBox().size
        end    
        ------------------------------------------

        if d.adjust_pos then
			self:adjustChildPosition(child, d.x, d.y, contentSize, d.adjust_pos)
        elseif d.ignore_half_size then
            child:setPosition(d.x, d.y)
        else
            child:setPosition(d.x + contentSize.width / 2, d.y + contentSize.height / 2)
        end     

		if nil ~= d.effect then self:addEff(child, d.effect) end
        
        if d.color then
            child:setColor(d.color)
        end
        if d.opacity then
            -- it doesn't work any more since Layer is NOT a CCLayerColor instanct now
            -- child:setOpacity(d.opacity)
            if d.class == SpriteLayer then
                child:getSprite():setOpacity(d.opacity)
            end
        end
        if d.visible ~= nil then
            child:setVisible(d.visible)
        end
        
        self:addChild(child, d.z, d.tag)

        if d.touch >= 0 then
            child:setTouchPriority(d.touch)
            self:addToTouchResponders(child)
        end

        if d.attributes then
            for k, v in pairs(d.attributes) do
                child[k] = v
            end
        end

        if d.layout then
            child:layout(d.layout)
        end
        if d.layoutEx and type(d.layoutEx)=="function" then
            local _tblLayout = d.layoutEx( child:getContentSize() )
            child:layout(_tblLayout)
        end
    end
end

function prototype:adjustChildPosition(child, x, y, size, anchorPoint)
	local horizontal = anchorPoint.x or 0.5
	local vertical = anchorPoint.y or 0.5
	local halfWidth = size.width/2
	local halfHeight = size.height/2
	if 1 == horizontal then
		x = x - halfWidth
	elseif 0 == horizontal then
		x = x + halfWidth
	--else --if 0.5 == horizontal then
		--x = x
	end
	if 1 == vertical then
		y = y - halfHeight
	elseif 0 == vertical then
		y = y + halfHeight
	--else --if 0.5 == vertical then
		--y = y
	end
	child:setPosition(ccp(x, y))
	child:setAnchorPoint(ccp(0.5, 0.5))
end

function prototype:addEff(child, eff)
	local array, action
	if eff == EFF_JELLY then
		array = CCArray:create()
		action = CCScaleTo:create(0.8, 1.06, 0.97)
		array:addObject(action)
		action = CCScaleTo:create(0.6, 1, 1)
		array:addObject(action)
		action = CCRepeatForever:create(CCSequence:create(array))
		child:runAction(action)
	end
end

function prototype:onEnter()
end

function prototype:onExit()
end

function prototype:onEnterTransitionFinish()
end

function prototype:onExitTransitionStart()
end

function prototype:onCleanup()
end

function  prototype:setGlobalTouchIntercepted(state)
    GLOBAL_TOUCH_INTERCEPTED = state
end

function prototype:enableKeypadHandling(enabled)
    -- it's used as the Android keypad handling for the time being
    if __G__isAndroid then
        self:setKeypadEnabled(enabled)  -- MUST DO

        if enabled then
            self:registerScriptKeypadHandler(
                function(eventType)
                    if eventType == "backClicked" then
                        Utils:sharedUtils():startAlertView(
                            "",
                            "Are you sure you want to quit the game? Your current progress will be lost.",
                            "Yes", "Cancel",
                            function(event, sender)
                                if event == "alertViewYes" then
                                    CCDirector:sharedDirector():endToLua()
                                end
                            end)
                    elseif eventType == "menuClicked" then
                    end
                end
            )
        else
            self:unregisterScriptKeypadHandler()
        end
    end
end

function prototype:runActionSafe(action)
    -- stop the currently running action if any
    if self._actionRunningSafe then
        self:stopAction(self._actionRunningSafe)
        self._actionRunningSafe = nil
        if self._origIsTouchEnabled ~= nil then
            self.isTouchEnabled = self._origIsTouchEnabled
        end
    end

    local a = CCArray:create()
    a:addObject(CCCallFunc:create(function() self._origIsTouchEnabled = self.isTouchEnabled; self.isTouchEnabled = false end))
    a:addObject(action)
    a:addObject(CCCallFunc:create(function() if self._origIsTouchEnabled ~= nil then self.isTouchEnabled = self._origIsTouchEnabled end end))

    self._actionRunningSafe = CCSequence:create(a)
    return self:runAction(self._actionRunningSafe)
end
