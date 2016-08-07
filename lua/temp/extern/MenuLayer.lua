--[[---------------------------------------------------------
common menu layer which appears in spa, makeup and dress scenes
-----------------------------------------------------------]]

-- require("common")
require("base/Layer")
require("base/ButtonLayer")
require("config/config_popup")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

local SCENE_TRANSITION_DURATION = 0.2

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "MenuLayer"
local ccParent = Layer  -- any Cocos2d-X class or its subclass (both native subclass and Lua subclass are ok)

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- super class's methods are invoked through this member variable
    superClass = ccParent,

    -- coordinates
    topLeftOffset = nil,  -- a { x =, y = } table
    topRightOffset = nil,  -- a { x =, y = } table
    vButtonPadding = 9,
    hButtonPadding = 9,

    -- menu button type, should not change the values, use them as constants
    typeSound = 13,
    typeReset = 14,
    typeCamera = 15,
    typeRateUs = 16,
    typeMorePage = 17,
    typeShop = 18,
    typeHome = 19,
    -- special button types
    typeMenu = 12,
    typeForward = 10,
    typeBackward = 11,

    -- button click sound
    defaultClickSound = nil,

    -- other member variables which affect the button behavior
    -- functions to create CCScene objects for going forward and backward in the game
    nextSceneCreateFunc = nil,
    previousSceneCreateFunc = nil,
    homeSceneCreateFunc = nil,

    -- CCNode object for screenshot taken
    screenshotLayer = nil,

    -- menu status: closed or expanded
    isExpanded = false,

    isActing = false,

    ignoreWatermark = false,

    menuExpandSpeed = 0.5,

    -- used inside onHome method: (sceneStackDepth - 1) scenes are poped before the home scene is shown (replace the original root scene)
    sceneStackDepth = 1,

    -- need to hide banner when popup shown?
    needHideBannerAdOnPopup = true,

    -- misc settings
    defaultClickInterval = 0.5,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- add a specified menu button; assuming all non-arrow buttons are of the same size
    --[[
    HButton: button expanded horizontally
    VButton: button expanded vertically
    arguments: type, normalSprite, selectedSprite (can be nil), clickSound (nil for default sound), closeMenuAfterClick (nil for default true), isFixed (nil for default false)
    ]]
    addHButton = nil,
    addVButton = nil,
    -- special buttons require special button types: typeMenu, typeForward, typeBackward
    -- arguments: type, normalSprite, selectedSprite (can be nil), clickSound (nil for default sound), closeMenuAfterClick (nil for default true)
    addMetaButton = nil,

    -- menu button handler, all are function callbacks which will be called with a single argument: sender (the MenuLayer object itself)
    -- override them when needed (say, we probably want to override the onReset method)
    onForward = nil,
    onBackward = nil,
    onMenu = nil,
    onSound = nil,
    onScreenshot = nil,
    preScreenShotHandle = nil,
    afterScreenShotHandle = nil,
    onReset = nil,
    onRateUs = nil,
    onShop = nil,  -- it takes 1 extra argument, a function as the IAP result callback, see config_popup for detail
    onHome = nil,
    onMorePage = nil,

    -- close / expand menu, with 1 argument: animated
    closeMenu = nil,
    expandMenu = nil,
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
        local obj = ccParent:create()

        -- IMPORTANT: make the touch falls through when it hits no buttons
        obj.touchThroughTransparent = true

        -- MUST copy the prototype attributes to it
        for k, v in pairs(prototype) do
            obj[k] = v
        end

        obj.vButtonTags = {}
        obj.hButtonTags = {}
        setmetatable(obj.vButtonTags, { __mode = "v" })
        setmetatable(obj.hButtonTags, { __mode = "v" })

        obj.vFixedButtons = 0
        obj.hFixedButtons = 0

        return obj
    end
)

-- constructor definition
-- arguments: attributes (table object)
-- return the object of class
function cls.create(attrs)
    local obj = cls.new()

    if type(attrs) == "table" then
        for k, v in pairs(attrs) do
            obj[k] = v
        end
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

-- default click handler for each button type
local _buttonClickHandler = {}
_buttonClickHandler[prototype.typeForward]  = "onForward"
_buttonClickHandler[prototype.typeBackward] = "onBackward"
_buttonClickHandler[prototype.typeSound]    = "onSound"
_buttonClickHandler[prototype.typeReset]    = "onReset"
_buttonClickHandler[prototype.typeCamera]   = "onScreenshot"
_buttonClickHandler[prototype.typeRateUs]   = "onRateUs"
_buttonClickHandler[prototype.typeShop]     = "onShop"
_buttonClickHandler[prototype.typeHome]     = "onHome"
_buttonClickHandler[prototype.typeMenu]     = "onMenu"
_buttonClickHandler[prototype.typeMorePage] = "onMorePage"

function prototype:addButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, isFixed)
    local button = nil

    if type_ == self.typeMorePage then
        button = MoreGamesUI.createButton(__G__moreGamesData)
    else
        button = ButtonLayer.create(normalSprite, selectedSprite)
        button.enableAutoState = false
        button.touchSound = clickSound and clickSound or self.defaultClickSound
    end

    button.closeMenuAfterClick = (closeMenuAfterClick == nil) and true or closeMenuAfterClick
    button.isFixed = isFixed

    local s = button:getContentSize()

    if type_ == self.typeSound and selectedSprite then
        if __G__isSoundMute then
            button:setState("selected")
        end
    end

    local layerSize = self:getContentSize()
    button.closePosition = ccp(self.topLeftOffset.x + s.width / 2, layerSize.height - self.topLeftOffset.y - s.height / 2)
    button:setPosition(button.closePosition)

    if type_ ~= self.typeMorePage then
        -- DO NOT use clickHandler for the time being cause the "isTouchEnabled = false / true" doesn't work as expected inside clickHandler
        -- this is the problem in the implementation of onTouchAnimation (just check out the ButtonLayer.lua)
        --
        -- IMPORTANT: DO NOT invoke native popup (like UIKit's UIAlertView inside a onTouchBegan method, otherwise system eats your touch events)
        button.tapHandler = function(sender)
            self[ _buttonClickHandler[sender:getTag()] ](self)

            if sender.closeMenuAfterClick then
                self:closeMenu(true)
            end
        end
    end

    -- set type as the tag
    self:addChild(button, 1, type_)

    button:setTouchPriority(1)
    self:addToTouchResponders(button)

    button.isTouchEnabled = button.isFixed

    -- setup the interval between 2 clicks
    if not button.closeMenuAfterClick then  -- closeMenu / expandMenu will disable / enable button accordingly
        button.minClickInterval = self.defaultClickInterval
    end

    if type_ == self.typeMenu then
        button.minClickInterval = self.menuExpandSpeed + 0.1  -- disable it when menu is expanding / closing
    end

    return button
end

function prototype:addHButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, isFixed)
    if type_ ~= self.typeMenu and type_ ~= self.typeForward and type_ ~= self.typeBackward then
        local lastButton = (#self.hButtonTags > 0) and self:getChildByTag(self.hButtonTags[#self.hButtonTags]) or nil

        local button = self:addButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, isFixed)
        table.insert(self.hButtonTags, button:getTag())

        local s = nil
        if type_ == self.typeMorePage and lastButton then
            s = lastButton:getContentSize()
        else
            s = button:getContentSize()
        end

        button.expandPosition = ccp(button.closePosition.x + (#self.hButtonTags) * (s.width + self.hButtonPadding), button.closePosition.y)

        if isFixed then
            self.hFixedButtons = self.hFixedButtons + 1
            button.closePosition = ccp(button.closePosition.x + self.hFixedButtons * (s.width + self.hButtonPadding), button.closePosition.y)
            button:setPosition(button.closePosition)
        else
            button:setZOrder(-#self.hButtonTags)
        end

        if type_ ~= self.typeMenu and type_ ~= self.typeMorePage then
            button:getSprite():setOpacity(0)
        end
    end
end

function prototype:addVButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, isFixed)
    if type_ ~= self.typeMenu and type_ ~= self.typeForward and type_ ~= self.typeBackward then
        local lastButton = (#self.vButtonTags > 0) and self:getChildByTag(self.vButtonTags[#self.vButtonTags]) or nil

        local button = self:addButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, isFixed)
        table.insert(self.vButtonTags, button:getTag())

        local s = nil
        if type_ == self.typeMorePage and lastButton then
            s = lastButton:getContentSize()
        else
            s = button:getContentSize()
        end

        button.expandPosition = ccp(button.closePosition.x, button.closePosition.y - (#self.vButtonTags) * (s.height + self.vButtonPadding))

        if isFixed then
            self.vFixedButtons = self.vFixedButtons + 1
            button.closePosition = ccp(button.closePosition.x, button.closePosition.y - self.vFixedButtons * (s.height + self.vButtonPadding))
            button:setPosition(button.closePosition)
        else
            button:setZOrder(-#self.vButtonTags)
        end

        if type_ ~= self.typeMenu and type_ ~= self.typeMorePage then
            button:getSprite():setOpacity(0)
        end
    end
end

function prototype:addMetaButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick)
    if type_ == self.typeMenu or type_ == self.typeForward or type_ == self.typeBackward then
        local button = self:addButton(type_, normalSprite, selectedSprite, clickSound, closeMenuAfterClick, true)
        local s = button:getContentSize()
        local layerSize = self:getContentSize()

        if type_ == self.typeMenu then
            --
        elseif type_ == self.typeForward then
            button:setPosition(layerSize.width - self.topRightOffset.x - s.width / 2, layerSize.height - self.topRightOffset.y - s.height / 2)
        elseif type_ == self.typeBackward then
            button:setPosition(layerSize.width - self.topRightOffset.x - s.width - self.hButtonPadding - s.width / 2, layerSize.height - self.topRightOffset.y - s.height / 2)
        end
    end
end

function prototype:closeMenu(animated)
    if not self.isExpanded then
        return
    end

    function doClose(buttons)
        for _, t in pairs(buttons) do
            local b = self:getChildByTag(t)

            if b:isVisible() then
                b.isTouchEnabled = b.isFixed

                if animated then
                    self.isActing = true

                    --b:runAction(CCEaseBackIn:create(CCMoveTo:create(self.menuExpandSpeed, b.closePosition)))
                    local arr = CCArray:create()
                    arr:addObject(CCEaseBackIn:create(CCMoveTo:create(self.menuExpandSpeed, b.closePosition)))
                    arr:addObject(CCCallFuncN:create(function(sender)
                            if t ~= self.typeMenu and t ~= self.typeMorePage then
                                b:getSprite():setOpacity(0)
                            end
                        end))
                    b:runAction(CCSequence:create(arr))

                else
                    b:setPosition(b.closePosition)
                    if t ~= self.typeMenu and t ~= self.typeMorePage then
                        b:getSprite():setOpacity(0)
                    end
                end
            end
        end
    end

    doClose(self.hButtonTags)
    doClose(self.vButtonTags)

    local menuBtn = self:getChildByTag(self.typeMenu)

    if animated then
        performWithDelay(menuBtn,
            function()
                menuBtn:setState("normal")
                self.isActing = false
            end,
            self.menuExpandSpeed)
    else
        if menuBtn.selectedSprite then
            menuBtn:setState("normal")
        end
    end

    self.isExpanded = false
end

function prototype:expandMenu(animated)
    if GlobalObj and GlobalObj:checkHideShopButton() then
        self:hideShopButton()
    end

    function doExpand(buttons)
        for _, t in pairs(buttons) do
            local b = self:getChildByTag(t)

            if b:isVisible() then
                if t ~= self.typeMenu and t ~= self.typeMorePage then
                    b:getSprite():setOpacity(255)
                end

                if animated then
                    local arr = CCArray:create()
                    arr:addObject(CCEaseBackOut:create(CCMoveTo:create(self.menuExpandSpeed, b.expandPosition)))
                    arr:addObject(CCCallFuncN:create(function(sender)
                            sender.isTouchEnabled = true
                        end))
                    b:runAction(CCSequence:create(arr))
                else
                    b:setPosition(b.expandPosition)
                end
            end
        end
    end

    doExpand(self.hButtonTags)
    doExpand(self.vButtonTags)

    local menuBtn = self:getChildByTag(self.typeMenu)

    if menuBtn.selectedSprite then
        menuBtn:setState("selected")
    end

    self.isExpanded = true
end

function prototype:onForward()
    if self.nextSceneCreateFunc then
        --[[
        CCDirector:sharedDirector():replaceScene(CCTransitionFade:create(SCENE_TRANSITION_DURATION, self.nextSceneCreateFunc()))
        ]]
        -- change the default behavior to using loading scene, but no preload resources specified
        CCDirector:sharedDirector():replaceScene(scene_loading.create(
            nil,
            nil,
            nil,
            self.nextSceneCreateFunc
        ))
    end
end

function prototype:onBackward()
    if self.previousSceneCreateFunc then
        --[[
        CCDirector:sharedDirector():replaceScene(CCTransitionFade:create(SCENE_TRANSITION_DURATION, self.previousSceneCreateFunc()))
        ]]
        -- change the default behavior to using loading scene, but no preload resources specified
        CCDirector:sharedDirector():replaceScene(scene_loading.create(
            nil,
            nil,
            nil,
            self.previousSceneCreateFunc
        ))
    end
end

function prototype:onMenu()
    if self.isActing then
        return
    end

    if self.isExpanded then
        self:closeMenu(true)
    else
        self:expandMenu(true)
    end
end

function prototype:onSound()
    local button = self:getChildByTag(self.typeSound)

    if __G__isSoundMute then
        __G__soundMute(false)
        button:setState("normal")
    else
        __G__soundMute(true)
        button:setState("selected")
    end
end

-- argument: popupCreateFunc, a function takes 1 argument which is the popup dismiss callback
function prototype:showPopup(popupCreateFunc)
    __G__showPopup(popupCreateFunc, self:getParent(), self.needHideBannerAdOnPopup)
end

function prototype:onScreenshot()
    if self.screenshotLayer then
        -- render screen to texture
        local GL_DEPTH24_STENCIL8 = 0x88F0
        local tx = CCRenderTexture:create(__G__canvasSize.width, __G__canvasSize.height, kTexture2DPixelFormat_RGB565, GL_DEPTH24_STENCIL8)
        
        if self.preScreenShotHandle then
            self.preScreenShotHandle()
        end

        tx:begin()
        self.screenshotLayer:visit()
        tx:endToLua()       

        if self.afterScreenShotHandle then
            self.afterScreenShotHandle()
        end 

        self:showPopup(function(closeCallback) return config_popup.createSaveImage(tx, closeCallback, self.ignoreWatermark) end)
    end
end

function prototype:onRateUs()
    self:showPopup(config_popup.createRateUs)
end

function prototype:onShop(iapCallback)
    if __G__isAndroid then
        return
    else
        self:showPopup(function(closeCallback) return config_popup.createShop(closeCallback, iapCallback) end)
    end
    
end

function prototype:onHome()
    if self.homeSceneCreateFunc then
        Utils:sharedUtils():startAlertView("",
            "Are you sure you want to return to the main menu? Your current progress will be lost.",
            "Yes", "Cancel",
            function(event, sender)
                -- delay the callback otherwise it may crash on Android:
                -- we use JNI a lot on Android native dialog, that may cause problem due to UI thread refreshing
                performWithDelay(self, function()
                    if event == "alertViewYes" then
                        -- DO NOT use popToRootScene, see: http://www.cocos2d-x.org/forums/6/topics/51658
                        -- CCDirector:sharedDirector():popToRootScene()

                        for _ = self.sceneStackDepth, 2, -1 do
                            CCDirector:sharedDirector():popScene()  -- IMPORTANT, otherwise there may be unused scene in stack
                        end

                        local scene_data = {adType = "CBCP"}
                        game_app:switchWithScene(self.homeSceneCreateFunc, scene_data)
                        -- no ad when returning to home scene
                        -- performWithDelay(self, function() AdsPopupManager:sharedManager():showInterstitial() end, 2)
                    end
                end, 0.2)
            end)
    end
end

function prototype:onMorePage()
    AboutUsPage:sharedAboutUsPage():show()
end

function prototype:onReset()
end

function prototype:hideShopButton( ... )
    --hide shop
    local tagHide = self.typeShop
    local btn = self:getChildByTag(tagHide)
    
    if btn then
        if not btn:isVisible() then
            return
        end
        btn:setVisible(false)
    else
        return
    end
    
    if true then
        local pos = nil
        for _, t in pairs(self.hButtonTags) do
            local b = self:getChildByTag(t)
            if pos then
                local tmp = b.expandPosition
                b.expandPosition = pos
                pos = tmp
            end
            if t == tagHide then
                pos = b.expandPosition
            end           
        end
        if not pos then
            for _, t in pairs(self.vButtonTags) do
                local b = self:getChildByTag(t)
                if pos then
                    local tmp = b.expandPosition
                    b.expandPosition = pos
                    pos = tmp
                end
                if t == tagHide then
                    pos = b.expandPosition
                end           
            end
        end
    end
end
