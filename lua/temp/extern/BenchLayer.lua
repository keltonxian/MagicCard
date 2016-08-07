--[[---------------------------------------------------------
encapsulate basic functions for SALON game's bench
-----------------------------------------------------------]]

require("base/ScrollLayer")
require("extern.LayerIndicator")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "BenchLayer"
local ccParent = ScrollLayer  -- any Cocos2d-X class or its subclass (both native subclass and Lua subclass are ok)

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = ccParent,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- add tool object to bench
    -- arguments: tool, tag, page, x, y, shadow, shadowX, shadowY
    -- tool: the tool object (Layer instance)
    -- page: on which page
    -- x, y: bottom left position on the given page
    -- z: z order of the tool
    -- shadow: the shadow of the tool (the image file path or Layer instance)
    -- shadowX, shadowY: the bottom left position on the given page
    -- * all shadow arguments are optional
    -- * a benchParent attribute is attached to the tool object automatically
    addTool = nil,

    -- arguments: (tool tag) or (page #, tool #)
    -- return the tool object
    getTool = nil,

    -- toggle tool shadow visibility
    -- arguments: tool tag, state (true or false)
    toggleToolShadow = nil,
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
        local obj = ccParent:create()

        -- MUST copy the prototype attributes to it
        for k, v in pairs(prototype) do
            obj[k] = v
        end

        -- keep a table for page # and tool # mapping
        obj._toolPages = {}

        return obj
    end
)

-- create the bench layer object
-- arguments: width, height, pages (count of pages, must >= 1)
function cls.create(width, height, pages)
    local obj = cls.new()

    obj:setContentSize(CCSizeMake(width, height))
    obj.paginated = true
    obj.pages = pages
    obj:setupScroll()

    -- IMPORTANT: set it to false to allow drawing items outside of the scroll view
    obj.scrollView:setClippingToBounds(false)
   
    for i = 1, pages do
        local t = {}
        setmetatable(t, { __mode = "v" })
        table.insert(obj._toolPages, t)
    end

    if pages > 1 then
        local layerIndicator = LayerIndicator:create(pages, nil, nil, width, height)
        if layerIndicator then
            obj:addChild(layerIndicator, 1005)
        end
        obj.layerIndicator = layerIndicator
    end

    return obj
end

-- let the cls inherit all the attributes from prototype
setmetatable(cls, { __index = prototype })

-- export the cls to package
_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

local _SHADOW_TAG_START = 246800000

function prototype:addTool(tool, tag, page, x, y, z, shadow, shadowX, shadowY)
    local benchSize = self:getContentSize()
    -- local toolSize = tool:getContentSize()
    local toolSize = tool:boundingBox().size

    tool:setPosition((page - 1) * benchSize.width + x + toolSize.width / 2, y + toolSize.height / 2)
    if tool.canPickUp then
        tool:setTouchPriority(2)
    else
        tool:setTouchPriority(1)
    end
    self.container:addChild(tool, z, tag)
    self.container:addToTouchResponders(tool)

    if shadow then
        if type(shadow) == "string" then
            shadow = CCSprite:create(shadow)
        end

        -- default shadow positions are the same as the tool's
        shadowX = shadowX and shadowX or x
        shadowY = shadowY and shadowY or y

        shadow:setScale(tool:getScale())
        shadow:setRotation(tool:getRotation())
        -- local s = shadow:getContentSize()
        local s = shadow:boundingBox().size
        shadow:setPosition((page - 1) * benchSize.width + shadowX + s.width / 2, shadowY + s.height / 2)
        self.container:addChild(shadow, -1, _SHADOW_TAG_START + tag)
    end

    tool.benchParent = self

    table.insert(self._toolPages[page], tool)
end

function prototype:getTool(arg1, arg2)
    if not arg2 then
        return self.container:getChildByTag(arg1)
    end

    return self._toolPages[arg1][arg2]
end

function prototype:toggleToolShadow(toolTag, state)
    local s = self.container:getChildByTag(_SHADOW_TAG_START + toolTag)
    if s then
        s:setVisible(state)
    end
end

