--[[---------------------------------------------------------
used as the replacement of CCScrollView, adding pagination and other features
refer: http://blog.leafsoar.com/archives/2013/07-27.html
NOTICE:
1. to add items to ScrollLayer, should do this way scrollLayer.container:addChild(...) or scrollLayer.container:layout(...)
2. should be added to a higher level touch dispatcher, like, layer:addToTouchResponders(scroll)
-----------------------------------------------------------]]

require("base/Layer")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

SCROLL_DIRECTION_HORIZONTAL = kCCScrollViewDirectionHorizontal
SCROLL_DIRECTION_VERTICAL = kCCScrollViewDirectionVertical
SCROLL_MOVE_THRESHOLD = 5
SCROLL_TOOL_PICKUP_THRESHOLD = __G__iOSValue2(30, 30)
SCROLL_STATIC_TOOL_CLICK_MOVE_THRESHOLD = __G__iOSValue2(20, 30)
-- SCROLL_BORDER_RESTRICTION_FACTOR * scroll view size = the max distance we can drag the scroll layer at border
SCROLL_BORDER_RESTRICTION_FACTOR = 3 / 4
SCROLL_MOVE_DURATION = 0.2
TOUCH_CONTAINER_DELAY = 0.08

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "ScrollLayer"

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = Layer,
    -- allow pagination or not
    paginated = true,
    pages = 1,
    -- paginating occurs when scroll move over paginateFactor * pageSize
    paginateFactor = 1 / 8,
    currentPage = 1,

    -- the callback handler which will be called on pagination done with 3 arguments: ScrollLayer object itself, currentPage, previousPage
    onPagingDone = nil,

    -- scroll direction
    direction = SCROLL_DIRECTION_HORIZONTAL,
    -- containerSize will be automatically caculated (based on pages and self contentSize) when self.paginated is true
    containerSize = nil,
    -- container is an instance of Layer, the addChild(item, ...) should go to the container
    container = nil,
    -- the reference to a CCScrollView instance, for internal use
    scrollView = nil,
    -- status indicator
    isScrollTouched = false,
    isScrollMoving = false,
    isScrollEnded = true,

    -- bench page indicator
    layerIndicator = nil,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- get prepared for scroll, no argument, no return value
    setupScroll = nil,
    -- no argument, return true or false
    hasContainerItemTouched = nil,
    -- passing touch location to container, arguments: x, y
    touchContainer = nil,
    -- override parent's onTouch method
    onTouch = nil,
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

function prototype:setupScroll()
    if not self.scrollView then
        local scrollView = CCScrollView:create()

        scrollView:ignoreAnchorPointForPosition(false)
        scrollView:setAnchorPoint(ccp(0.5, 0.5))
        scrollView:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        scrollView:setViewSize(self:getContentSize())

        -- take over all the touch event handling
        scrollView:setTouchEnabled(false)

        self.scrollView = scrollView
        self:addChild(scrollView)
    end

    if not self.container then
        self.container = Layer.create()
        -- don't set ontainer's position, it's set automatically inside CCScrollView:setContainer
        self.scrollView:setContainer(self.container)
        self.scrollView:updateInset()
    end

    if self.paginated then
        local viewSize = self:getContentSize()
        if self.direction == SCROLL_DIRECTION_HORIZONTAL then
            self.containerSize = CCSizeMake(self.pages * viewSize.width, viewSize.height)
        else
            self.containerSize = CCSizeMake(viewSize.width, self.pages * viewSize.height)
        end
    else
        self.containerSize = self:getContentSize()
    end

    self.container:setContentSize(self.containerSize)
end

function prototype:hasContainerItemTouched()
    local ret = false

    if #self.container.touchResponders > 0 then
        ret = (self.container.touchResponders[1].touchPriority == MAX_TOUCH_PRIORITY)
    end

    return ret
end

function prototype:touchContainer(x, y)
    self.containerTouched = true
    self.container:onTouch("began", x, y)
end

function prototype:onTouch(eventType, x, y)
    -- must change the status before running the following code
    if eventType == "began" then
        self.isScrollTouched = true
        self.isScrollEnded = false
    elseif eventType == "ended" then
        self.isScrollTouched = false
        self.isScrollMoving = false
        self.isScrollEnded = true
    end

    local touchInLayer = ccp(x, y)

    if eventType == "began" then
        self.touchPoint = touchInLayer
        self.lastPoint = touchInLayer
        self.touchOffset = self.scrollView:getContentOffset()
        self.totalMoveDistance = 0

        -- look for non-draggable tool (static tool) which hit the touch then save it for later use
        self.toolTouched = nil
        local hitTool = nil

        for _, t in pairs(self.container.touchResponders) do
            if t:touchHit(x, y) then
                if (not hitTool) or (t.touchPriority > hitTool.touchPriority) then
                    hitTool = t
                end
            end
        end

        if hitTool then  -- dim the tool no matter it's a draggable or static one
            self.toolTouched = hitTool
			if true ~= hitTool.noTouchDim then
				Utils:sharedUtils():setColorDim(hitTool, true)
			end
        end

    elseif eventType == "moved" then
        if self.containerTouched and self:hasContainerItemTouched() then
            self.container:onTouch(eventType, x, y)

        else
            -- diff: decide how the scroll view scrolls; diff2: decide whether a tool is picked up
            local diff, diff2, newOffset, pageSize
            local viewSize = self:getContentSize()
            local containerSize = self.container:getContentSize()
            local doScroll = false

            if self.direction == SCROLL_DIRECTION_HORIZONTAL then
                diff = touchInLayer.x - self.touchPoint.x
                diff2 = touchInLayer.y - self.touchPoint.y
                newOffset = ccp(self.touchOffset.x + diff, self.touchOffset.y)
                pageSize = self:getContentSize().width
                self.totalMoveDistance = self.totalMoveDistance + math.abs(touchInLayer.x - self.lastPoint.x)

                if diff >= 0 then
                    doScroll = (newOffset.x <= SCROLL_BORDER_RESTRICTION_FACTOR * viewSize.width)
                else
                    doScroll = (newOffset.x >= -containerSize.width + viewSize.width - SCROLL_BORDER_RESTRICTION_FACTOR * viewSize.width)
                end
            else
                diff = touchInLayer.y - self.touchPoint.y
                diff2 = touchInLayer.x - self.touchPoint.x
                newOffset = ccp(self.touchOffset.x, self.touchOffset.y + diff)
                pageSize = self:getContentSize().height
                self.totalMoveDistance = self.totalMoveDistance + math.abs(touchInLayer.y - self.lastPoint.y)

                if diff >= 0 then
                    doScroll = (newOffset.y <= SCROLL_BORDER_RESTRICTION_FACTOR * viewSize.height)
                else
                    doScroll = (newOffset.y >= -containerSize.height + viewSize.height - SCROLL_BORDER_RESTRICTION_FACTOR * viewSize.height)
                end
            end

            local toolPickedUp = false

            if ((not self.toolTouched) or (self.toolTouched.moveOnTouch)) and  -- no tool hit or no static tool hit
                (math.abs(diff2) >= SCROLL_TOOL_PICKUP_THRESHOLD) and  -- move along the tool for a given distance
                (math.abs(diff2) > math.abs(diff)) and  -- should not move along the scroll direction too much
                (math.abs(diff) <= pageSize * self.paginateFactor) then  -- same as above but even more strictly
                -- test a series of points: from self.touchPoint to current location
                local segments = 3
                local dx = (touchInLayer.x - self.touchPoint.x) / segments
                local dy = (touchInLayer.y - self.touchPoint.y) / segments

                local hitX, hitY = self.touchPoint.x, self.touchPoint.y
                local hitTest = false

                for i = 0, segments do
                    for _, t in pairs(self.container.touchResponders) do
                        if t:touchHit(hitX, hitY) then
                            hitTest = true
                            break
                        end
                    end

                    if hitTest then
                        break
                    end

                    hitX = hitX + dx
                    hitY = hitY + dy                    
                end

                if hitTest then
                    self:touchContainer(hitX, hitY)  -- touchBegan sent here

                    if self.containerTouched and self:hasContainerItemTouched() then
                        -- move the tool then release the touch of (pretend to be touch ended) the scroll view
                        toolPickedUp = true
                        self.container:onTouch(eventType, x, y)  -- touchMoved to container
                        self.untouchScrollOnToolPickup = true
                        self:onTouch("ended", x, y)  -- release the touch of scroll view

                        if self.toolTouched then
                            Utils:sharedUtils():setColorDim(self.toolTouched, false)
                        end
                    else
                        -- nothing hit the touch so we need to end the touch detection by sending touchEnded event
                        -- otherwise the following touch detection will fail (cause touchHasBegan)
                        self.container:onTouch("ended", hitX, hitY)
                    end
                end
            end

            if not toolPickedUp then
                if not self.isScrollMoving and diff >= -SCROLL_MOVE_THRESHOLD and diff <= SCROLL_MOVE_THRESHOLD then
                    -- do nothing cause scroll move doesn't start yet and the touch distance is too small
                else
                    self.isScrollMoving = true
                    if doScroll then
                        self.scrollView:setContentOffset(newOffset, false)
                    end
                end
            end
        end

        self.lastPoint = touchInLayer

    elseif eventType == "ended" then
        -- reposition the scroll view if "a draggable tool picked up" or "no tool picked up"
        if self.untouchScrollOnToolPickup or (not self:hasContainerItemTouched()) then
            if self.paginated then
                local diff, pageSize
                local previousPage = self.currentPage
                if self.direction == SCROLL_DIRECTION_HORIZONTAL then
                    diff = touchInLayer.x - self.touchPoint.x
                    pageSize = self:getContentSize().width
                else
                    diff = touchInLayer.y - self.touchPoint.y
                    pageSize = self:getContentSize().height
                end

                if (not self.untouchScrollOnToolPickup) and (diff <= -pageSize * self.paginateFactor or diff >= pageSize * self.paginateFactor) then
                    if diff < 0 then
                        self.currentPage = math.min(self.currentPage + 1, self.pages)
                    else
                        self.currentPage = math.max(self.currentPage - 1, 1)
                    end

                    AudioEngine.playEffect(diff < 0 and config_sound_effects.common_swipe_left or config_sound_effects.common_swipe_right, false)
                end

                local offset
                if self.direction == SCROLL_DIRECTION_HORIZONTAL then
                    offset = ccp(-pageSize * (self.currentPage - 1), self.touchOffset.y)
                else
                    offset = ccp(self.touchOffset.x, -pageSize * (self.currentPage - 1))
                end
                self.scrollView:setContentOffsetInDuration(offset, SCROLL_MOVE_DURATION)

                if previousPage ~= self.currentPage then
                    if self.onPagingDone then
                        self.onPagingDone(self, self.currentPage, previousPage)
                    end
                    if self.layerIndicator then
                        self.layerIndicator:showCurrIndicator(self.currentPage)
                    end
                end
            else
                local viewSize = self:getContentSize()
                local containerSize = self.container:getContentSize()

                if self.direction == SCROLL_DIRECTION_HORIZONTAL then
                    local newOffsetX = nil
                    local diff = touchInLayer.x - self.touchPoint.x

                    if diff > 0 and self.touchOffset.x + diff > 0 then
                        newOffsetX = 0
                    elseif diff < 0 and self.touchOffset.x + diff < (viewSize.width - containerSize.width) then
                        newOffsetX = viewSize.width - containerSize.width
                    end

                    if newOffsetX then
                        self.scrollView:setContentOffsetInDuration(ccp(newOffsetX, self.touchOffset.y), SCROLL_MOVE_DURATION)
                    end
                else
                    local newOffsetY = nil
                    local diff = touchInLayer.y - self.touchPoint.y

                    if diff > 0 and self.touchOffset.y + diff > 0 then
                        newOffsetY = math.max(0, viewSize.height - containerSize.height)
                    elseif diff < 0 and self.touchOffset.y + diff < (viewSize.height - containerSize.height) then
                        newOffsetY = viewSize.height - containerSize.height
                    end

                    if newOffsetY then
                        self.scrollView:setContentOffsetInDuration(ccp(self.touchOffset.x, newOffsetY), SCROLL_MOVE_DURATION)
                    end
                end
            end
        end

        if self.untouchScrollOnToolPickup then
            self.untouchScrollOnToolPickup = false
        else
            -- the tool touched is a static one or it's a draggable one but not ever picked up
            if self.toolTouched and (not self:hasContainerItemTouched()) then
                Utils:sharedUtils():setColorDim(self.toolTouched, false)

                -- invoke the "click on tool" action
                if self.totalMoveDistance <= SCROLL_STATIC_TOOL_CLICK_MOVE_THRESHOLD then
                    self.toolTouched:onTouch("began", x, y)
                    self.toolTouched:onTouch("ended", x, y)
                end
            end

            -- send the "ended" event to container no matter it has item touched or not
            if self.containerTouched then
                self.containerTouched = false
                self.container:onTouch(eventType, x, y)
            end
        end
    else  -- "cancelled"
        --
    end

    -- must return true specially when eventType=began
    return true
end
