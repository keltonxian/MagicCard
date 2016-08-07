-- patch Widget objects as Layer

local function patchWidget(widget)
    widget.touchResponders = {}
    setmetatable(widget.touchResponders, { __mode = "v" })

    for k, v in pairs(Layer.prototype) do
        -- some attributes have been patched in previous recursive calls so we make a check here
        if k == "isTouchEnabled" then
            if type(widget.isTouchEnabled) == "function" then  -- not patched yet
                widget.isTouchEnabled = widget:isTouchEnabled()
            end
        elseif k == "touchPriority" and type(widget.touchPriority) == "number" then
            -- already patched
        elseif k == "touchHit" then
            -- override it later
        else
            widget[k] = v
        end
    end

    -- strange: MUST use Widget:hitTest here
    widget.touchHit = function(sender, x, y)
        if not sender.isTouchEnabled or not sender:isVisible() then
            return false
        end

        local ret = sender:hitTest(ccp(x, y))

        if ret then
            if sender.touchThroughTransparentStrict then
                -- do strict pixel transparency detection
                ret = not Utils:transparentHitTest(sender, ccp(x, y))
            elseif sender.touchThroughTransparent then
                ret = false  -- assume touch falls on transparent area

                -- check every sublayers see if touch really hit the transparent area
                for _, b in pairs(sender.touchResponders) do
                    if b:touchHit(x, y) then
                        ret = true
                        break
                    end
                end
            end
        end

        return ret
    end

    -- handle CCNode's onEnter and onExit event
    local function ccnodeEventHandler(eventType)
        if eventType == "enter" then
            widget:onEnter()
        elseif eventType == "exit" then
            widget:onExit()
        elseif eventType == "enterTransitionFinish" then
            widget:onEnterTransitionFinish()
        elseif eventType == "exitTransitionStart" then
            widget:onExitTransitionStart()
        elseif eventType == "cleanup" then
            widget:onCleanup()
        end
    end
    widget:registerScriptHandler(ccnodeEventHandler)
end

-- iterate the widget tree recursively
local patchWidgetTree = nil

patchWidgetTree = function(root, indent, indentStep)
    if not root then
        return
    end

    root = tolua.cast(root, "Widget")

    -- inject Layer's attributes; also register the script handler
    patchWidget(root)

    indent = indent and indent or 0
    indentStep = indentStep and indentStep or 4

    local spaces = ""

    for i = 0, indent - 1 do
        spaces = spaces .. " "
    end

    cclog("%s%s -- tag: %d -- touchable: %s  -- z: %d", spaces, type(root), root:getTag(), tostring(root.isTouchEnabled), root:getZOrder())

    local widgetChildren = root:getChildren()
    for i = 0, root:getChildrenCount() - 1 do
        local w = tolua.cast(widgetChildren:objectAtIndex(i), "Widget")

        -- NOTE: w is NOT patched yet so we call isTouchEnabled() and set touch priority manually
        if w:isTouchEnabled() then
            w.touchPriority = math.abs(w:getZOrder()) + 1
            -- the isTouchEnabled will be set once it's added to touch responders
            root:addToTouchResponders(w)
        end

        patchWidgetTree(w, indent + indentStep)
    end
end

_G["config_cocosstudio_ui"] = {
    patchWidget = patchWidget,
    patchWidgetTree = patchWidgetTree,
}