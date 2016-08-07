

local function createFullScreenDarkLayer()
    local ret = SpriteLayer.create(__G__canvasSize.width, __G__canvasSize.height)

    local darkLayer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 255 * 0.6), __G__canvasSize.width, __G__canvasSize.height)
    darkLayer:ignoreAnchorPointForPosition(false)
    darkLayer:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)

    ret:addChild(darkLayer, -100)
    return ret
end

--modify studio on iOS & Android

-- for example
-- if iOS & Android in same studio, pls fix it
local studio = config_game:studio()     ---- GGI KMI BCI BTI IPI IEL FDI FMI MSLPPI BGI PAI PFG

-- if you need to replace rateus you can use it
local function createRateUs(closeCallback)
    
    local popup = createFullScreenDarkLayer()
    local _layer = nil
    local closeButtonOffset = nil
    local rateButtonOffset = nil

    if __G__isOrientationLandscape then
        _layer = SpriteLayer.create(string.format("lib/rateus/%s/Lbg.png", studio))
        --when studio is GGI KMI. u need to set ccp(-6, 453)
        if studio == "BGI" then
            closeButtonOffset = ccp(0, 440)
            rateButtonOffset = ccp(210, 29)
        elseif studio == "PAI" then
            closeButtonOffset = ccp(-21, 455)
            rateButtonOffset = ccp(335, 60)
        elseif studio == "PFG" then
            closeButtonOffset = ccp(3, 425)
            rateButtonOffset = ccp(215, 9)
        else
            closeButtonOffset = ccp(-20, 458)
        end

    else
        _layer = SpriteLayer.create(string.format("lib/rateus/%s/bg.png", studio))
        --when studio is GGI KMI. u need to set ccp(-4, 605)
        if not __G__isAndroid then
            closeButtonOffset = ccp(-4, 605)
            rateButtonOffset = ccp(140, 80-40)
        else
            closeButtonOffset = ccp(-20, 620)
            rateButtonOffset = ccp(140, 30)
        end

        if studio == "BGI" then
            closeButtonOffset = ccp(0, 590)
            rateButtonOffset = ccp(135, 23)
        elseif studio == "PAI" then
            closeButtonOffset = ccp(-24, 612)
            rateButtonOffset = ccp(158, 27)
        elseif studio == "PFG" then
            closeButtonOffset = ccp(0, 649)
            rateButtonOffset = ccp(197, 17)
        elseif studio == "BCI" then
            closeButtonOffset = ccp(-20, 630)
            rateButtonOffset = ccp(140, 50)
        end

    end   
    popup:addChild(_layer,2)
    _layer:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)
    popup:addToTouchResponders(_layer)
    _layer.touchContainsExtendChildren = true
    _layer:layout({
      
        {
            x = closeButtonOffset.x,
            y = closeButtonOffset.y,
            z = 2,
            tag = 0,
            touch = 1,
            class = ButtonLayer,
            image = string.format("lib/rateus/%s/close.png", studio),
            attributes = {
                touchSound = config_sound_effects.common_popup_close,
                clickHandler =  closeCallback,
            },
        },
        {-- to set this position u need to do it yourself. NOT the same in different studio
            x = rateButtonOffset.x,
            y = rateButtonOffset.y,
            z = 3,
            tag = 0,
            touch = 1,
            class = ButtonLayer,
            image = string.format("lib/rateus/%s/rate.png", studio),
            attributes = {
                touchSound = config_sound_effects.common_bottom_icon_click,
                clickHandler =  function(s)
                    -- must delay a bit here to eliminate the button jittering on press, this is a Android related problem
                    performWithDelay(s, function()
                        if __G__isAndroid then
                            Utils:rateUsGP()
                        else
                            local url = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" .. __G__AppStoreID
                            Utils:sharedUtils():openURL(url)
                        end
                    end, 0.2)

                    --[[ remove this cause it doesn't work in Android when we call the "rate us" feature in delay mode
                    closeCallback(s)
                    ]]
                    
                end,
            },
        },
    })

    return popup
end

local function createADLoading(closeCallback)
    local popup = createFullScreenDarkLayer()
    local close = ButtonLayer.create("share/1.png")
    local size = close:getContentSize()
    close:setScale(75/size.width)
    popup:addChild(close, 1, 1)

    close:setPosition(50, __G__canvasSize.height - 50)
    popup:addToTouchResponders(close)
    close.clickHandler = function(s)
        closeCallback()
        __G__fromShowFail = false
    end
    return popup
end

local function createSaveImage(texture, closeCallback, ignoreWatermark)
    local popup = createFullScreenDarkLayer()
    local popupSize = popup:getContentSize()

    local sc  -- the actual screenshot layer (with watermark), declare here cause it's used the following layout code

    popup:layout({
        {
            x = __G__iOSValue(24,53,30),
            y = __G__iOSValue(23,83,23),
            z = 1,
            tag = 0,
            touch = -1,
            class = SpriteLayer,
            image = __G__iOSValue("share/i4.png","share/i5.png","share/ipad.png")
        },
        {
            x = __G__iOSValue(457,405,544),
            y = __G__iOSValue(31,100,30),
            z = 2,
            tag = 0,
            touch = 1,
            class = ButtonLayer,
            image = "share/2.png",
            attributes = {
                touchSound = config_sound_effects.common_bottom_icon_click,
                clickHandler =  function(s)
                    local filesaved = __G__saveImageFile(sc, "screenshot.jpg")
                    if filesaved then
                        Utils:sharedUtils():saveToPhotosAlbum(
                            filesaved,
                            function(e)
                                if e == "saveToPhotosAlbumSuccess" then
                                    Utils:sharedUtils():messageBox(
                                        "Photo Saved!",
                                        "Your image was saved to your Camera Roll!",
                                        "Ok",
                                        function()
                                            performWithDelay(popup, function() closeCallback(s) end, 0.2)
                                        end)
                                end
                            end)
                    end
                end,
            },
        },
        {
            x = __G__iOSValue(5,40,16),
            y = __G__iOSValue(897,1014,958),
            z = 2,
            tag = 0,
            touch = 1,
            class = ButtonLayer,
            image = "share/1.png",
            attributes = {
                touchSound = config_sound_effects.common_popup_close,
                clickHandler = closeCallback,
            },
        },
    })

    sc = SpriteLayer.create(popupSize.width, popupSize.height, ccc3(0, 0, 0), 0)

    texture:getSprite():getTexture():setAntiAliasTexParameters()
    texture:setPosition(popupSize.width / 2, popupSize.height / 2)
    sc:addChild(texture, 1)

    if not ignoreWatermark then
        local watermark = SpriteLayer.create("share/logo.png")
        local wmsize = watermark:getContentSize()
        local _offsetX = -5
        local _offsetY = 5
		local scale = 1.2
        watermark:setScale(scale)
        watermark:setPosition(__G__canvasSize.width - _offsetX - wmsize.width * scale / 2, wmsize.height * scale / 2 + _offsetY)
        sc:addChild(watermark, 2)
    end

    local container = SpriteLayer.create(popupSize.width, popupSize.height, ccc3(0, 0, 0), 0)
    sc:setPosition(popupSize.width / 2, popupSize.height / 2)
    container:addChild(sc)

    container:setScale(__G__iOSValue((540 / 640),(477 / 640),(540 / 640)))
    container:setPosition(popupSize.width / 2, popupSize.height / 2 + __G__iOSValue(20.5,20.5,20.5))
    popup:addChild(container, 10)

    return popup
end

--[[
the callback for IAP result:

- iapPurchaseCallback(type_, successOrNot, iapIndex)

    type_: "purchase" or "restore" ("type" is a keyword of Lua so we add an extra underscore)
    successOrNot: bool
    iapIndex: the index of IAP product (not the product id)

]]


local createShopScroll = function(w,h)
    local iapPurchase = IAPurchase:sharedPurchase()
    local scroll = ScrollLayer.create()

    scroll:setContentSize(w,h)
    scroll.paginated = false
    scroll.direction = SCROLL_DIRECTION_VERTICAL
    scroll:setupScroll() 
    scroll.container:setContentSize(w,154*6+10*5)

    for i=1,6 do
        local b = ButtonLayer.create(string.format("menu/shop/%d.png",i))
        b:setPosition(w/2,(154*6+10*5)-154/2*i-(i-1)*80)
        b:setTag(i)
        b.tapHandler = function()
            cclog(i)
            if __G__checkIAP(i) then
                Utils:sharedUtils():messageBox("", "You've already purchased this item!", "Ok", function() end)
                return
            end
            iapPurchase:startRequest(__G__iapIDs[i])
        end
        scroll.container:addChild(b,1,i-1+1)
        scroll.container:addToTouchResponders(b)
    end

    scroll.scrollView:setContentOffset(ccp(0, h-(154*6+10*5)), false)

    return scroll

end

local function createShop(closeCallback, iapPurchaseCallback)
    if not iapPurchaseCallback then
        iapPurchaseCallback = function(t, r, i) cclog("%s - %s - %d", t, tostring(r), i)  end
    end

    local function iapCallback(event, sender)
        local iapIndex = __G__iapIndex(sender:getCurrentProductId())

        if event == "productRequestBegin" then
            SimpleHUD:show()
        elseif event == "productRequestEnd" then
            SimpleHUD:hide()

        elseif event == "purchaseSuccess" then
            __G__setIAP(iapIndex)
            Utils:sharedUtils():messageBox("", "Thank you for your purchase.", "Ok", function()
                iapPurchaseCallback("purchase", true, iapIndex)
            end);

            closeCallback()

        elseif event == "purchaseFailed" then
            Utils:sharedUtils():messageBox("", "Purchase failed.", "Ok", function()
                iapPurchaseCallback("purchase", false, iapIndex)
            end);

        elseif event == "restoreFinishedWithPaymentTransitions" then
            Utils:sharedUtils():messageBox("", "Your content has been restored!", "Ok", function()
            end);

        elseif event == "restoreFinishedWithoutPaymentTransitions" then
            Utils:sharedUtils():messageBox("", "Sorry, it looks like you haven't purchased anything yet!", "Ok", function()
            end);

        elseif event == "purchaseRestored" then
            __G__setIAP(iapIndex)
            iapPurchaseCallback("restore", true, iapIndex)

            closeCallback()

        elseif event == "restoreFailed" then
            Utils:sharedUtils():messageBox("", "Sorry, restore transaction failed!", "Ok", function()
                iapPurchaseCallback("restore", false, iapIndex)
            end);

        elseif event == "productsNotReady" then
            Utils:sharedUtils():messageBox("Coming soon!", "There's nothing here yet but check back here after an upgrade in the near future!", "Thanks", function()
            end);

        end

        GlobalObj:removeAllADs()
    end

    local iapPurchase = IAPurchase:sharedPurchase()
    iapPurchase:registerScriptCallback(iapCallback)

    if GlobalObj:isIapPurchaseTest() and __G__isMacLuaPlayer then

        function iapPurchase:startRequest( iapID )
            local _iapIndex = __G__iapIndex(iapID)
            cclog("====================__G__iapPurchase_Test--->startRequest=====================")
            cclog('__G__iapPurchase_Test:    set "__G__iapTest" = true')
            cclog("__G__iapPurchase_Test:    iapIndex=%d",_iapIndex)
            cclog("__G__iapPurchase_Test:    iapCallback params: purchase, true, %d", _iapIndex)
            cclog("==============================================================================")
            
            __G__iapTest = true
            
            iapPurchaseCallback("purchase", true, _iapIndex)
            closeCallback()
        end

        function iapPurchase:restorePurchase( ... )
             __G__iapTest = true
            for i=1,#__G__iapIDs do
                local _iapIndex = i
                cclog("====================__G__iapPurchase_Test--->restorePurchase==================")
                cclog('__G__iapPurchase_Test:    set "__G__iapTest" = true');
                cclog("__G__iapPurchase_Test:    iapIndex=%d",_iapIndex)
                cclog("__G__iapPurchase_Test:    iapCallback params: restore, true, %d", _iapIndex)
                cclog("==============================================================================")

               iapPurchaseCallback("restore", true, _iapIndex)
            end
            closeCallback()
        end

    end

    local popup = createFullScreenDarkLayer()

    -- local _shopBasePath = string.format("menu/shop/%s/", __G__iOSValue("i4","i5","ipad"))
    local _shopBasePath = "shop/"
    local shop = SpriteLayer.create(_shopBasePath .. "bg.png")
    local _backScale = __G__iOSValue2(0.75, 0.95)
    shop:setScale(_backScale)

    shop:layout({
      
        {
            x = 39,
            y = 636,
            z = 2,
            scale = 1/_backScale,
            tag = 0,
            touch = 1,
            class = ButtonLayer,
            image = _shopBasePath .. "closed button.png",
            attributes = {
                clickHandler = closeCallback,
                touchSound = config_sound_effects.common_popup_close,
            },
        },
        {
        --restore
            x = 468,
            y = 20,
            z = 2,
            tag = 0,
            touch = 1,
            -- scale = 0.8,
            class = ButtonLayer,
            image = _shopBasePath .. "restore.png",
            attributes = {
                clickHandler = function() iapPurchase:restorePurchase() end,
                touchSound = config_sound_effects.common_bottom_icon_click,
            },
        },
        {--get it
            x = 243,
            y = 120,
            z = 2,
            tag = 0,
            touch = 1,
            -- scale = __G__iOSValue2(0.8,1.0), 
            class = ButtonLayer,
            image = _shopBasePath .. "getit2.png",
            attributes = {
                clickHandler = function()
                    if __G__checkIAP(1) then
                        Utils:sharedUtils():messageBox("", "You've already purchased this item!", "Ok", function() end)
                        return
                    end
                    iapPurchase:startRequest(__G__iapIDs[1])
                end,
                touchSound = config_sound_effects.common_bottom_icon_click,
            },
        },
        {--get it noadds
            x = 243,
            y = 473,
            z = 2,
            tag = 0,
            touch = 1,
            -- scale = __G__iOSValue2(0.8,1.0), 
            class = ButtonLayer,
            image = _shopBasePath .. "getit1.png",
            attributes = {
                clickHandler = function()
                    if __G__checkIAP(2) then
                        Utils:sharedUtils():messageBox("", "You've already purchased this item!", "Ok", function() end)
                        return
                    end
                    iapPurchase:startRequest(__G__iapIDs[2])
                end,
                touchSound = config_sound_effects.common_bottom_icon_click,
            },
        },
       
    })

    local bkgndSize = shop:getContentSize()
    local offsetX = (__G__canvasSize.width-bkgndSize.width*_backScale)/2.0
    local offsetY = (__G__canvasSize.height-bkgndSize.height*_backScale)/2.0
    shop:setAnchorPoint(ccp(0,0))
    shop:setPosition(__G__iOSValue(0,0,0)+offsetX ,__G__iOSValue(0,20,0)+offsetY)
    -- shop:setScale(0.8)

    -- popup:setScale(2.5)

    local pricesPositons = {
        ccp(395, 326),
        ccp(520, 712),
    }

    local pricesColor = 
    {
        ccc3(255,255,255),
        ccc3(255,255,255),
    }
    local pricesSize = 
    {
        36,
        36,
    }

    local baseTag = 1000

    local _money = ""
    if true and __G__isMacLuaPlayer then
        _money = "$$$$$"
    end
    for i, v in ipairs(pricesPositons) do
        local label1 = CCLabelTTF:create(_money, "Helvetica-Bold", pricesSize[i])
        label1:setAnchorPoint(ccp(0.5,0.5))
        -- label1:setRotation(-52)
        label1:setPosition(v)
        -- label1:setRotation(10)
        shop:addChild(label1, 100, baseTag+i)
        label1:setColor(pricesColor[i])
    end

    popup:addChild(shop, 110, 110)
    popup:addToTouchResponders(shop)
    shop.touchContainsExtendChildren = true

    popup.onExit = function(self)
        if self.checkIAPPricesAction then
            self:stopAction(self.checkIAPPricesAction)
            self.checkIAPPricesAction = nil
        end
    end

    local function _showIAPPrices()
        for i, v in ipairs(__G__iapPrices) do
            local aLabel = popup:getChildByTag(110):getChildByTag(baseTag + i)
            if aLabel then
                aLabel:setString(__G__iapPrices[i])
            end
        end
    end

    local function _checkToShowIAPPrices()
        cclog("check to show IAP prices...")
        if __G__isIAPPricesReady() then
            if popup.checkIAPPricesAction then
                popup:stopAction(popup.checkIAPPricesAction)
                popup.checkIAPPricesAction = nil
            end

            _showIAPPrices()
        else
            __G__getIAPPrices()
        end
    end

    if GlobalObj:isIapPurchaseTest() and __G__isMacLuaPlayer then
        --test body
    else
        if __G__isIAPPricesReady() then
            _showIAPPrices()
        else
            popup.checkIAPPricesAction = schedule(popup, _checkToShowIAPPrices, 5)
        end
    end

    -- local iapScroll = createShopScroll(454,676)
    -- iapScroll:setPosition(__G__visibleSize.width/2,__G__visibleSize.height/2-80)
    -- popup:addChild(iapScroll,3,9)
    -- popup:addToTouchResponders(iapScroll)

    
    return popup
end

local function createMoreGames(closeCallback, moreGamesData)
    local popup = createFullScreenDarkLayer()

 -- portrait / landscape config
    local imgPrefix = nil
    local bgOffset = nil
    local closeButtonOffset = nil
    local scrollSize = nil
    local scrollPosOffset = nil

    --modify studio  here
    --I had not landscape project if u need, u need to do yourself
    if __G__isOrientationLandscape then
        imgPrefix = string.format("lib/moregames/%s/landscape/", studio)
        -- bgOffset = ccp(__G__iOSValue2(126,115), __G__iOSValue2(80,115))
        closeButtonOffset = ccp(__G__iOSValue2(18,-13), __G__iOSValue2(485,500))
        scrollSize = CCSizeMake(__G__iOSValue2(639,717), __G__iOSValue2(430,500))
        scrollPosOffset = ccp(0, 0)
    else
        imgPrefix = string.format("lib/moregames/%s/", studio)
        -- bgOffset = ccp(__G__canvasSize.width / 2, __G__canvasSize.height / 2)
        closeButtonOffset = ccp(__G__iOSValue2(5,60), __G__iOSValue2(790,925))
        scrollSize = CCSizeMake(__G__iOSValue2(520,588), __G__iOSValue2(700,830))
        scrollPosOffset = ccp(0, 10)
    end
    local _layer = SpriteLayer.create(imgPrefix .. __G__iOSValue2("iphone/bg.png","ipad/bg.png"))
    popup:addChild(_layer, 1, 1)
    _layer:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)
    popup:addToTouchResponders(_layer)
    _layer.touchContainsExtendChildren = true

    _layer:layout({
        
        {
            x = closeButtonOffset.x,
            y = closeButtonOffset.y,
            z = 2,
            tag = 2,
            touch = 10,
            class = ButtonLayer,
            image = "lib/moregames/close.png",
            attributes = {
                touchSound = config_sound_effects.common_popup_close,
                clickHandler =  closeCallback,
            },
        },
       
    })

    local bg = popup:getChildByTag(1)
    local bgSize = bg:getContentSize()

    local apps = moreGamesData:getData().apps

    if #apps < 1 then  -- show "Coming Soon..." instead
        local fontSize = nil
        if __G__isOrientationLandscape then
            fontSize = __G__iOSValue2(70, 90)  -- may you prefer larger font size in landscape
        else
            fontSize = __G__iOSValue2(70, 90)
        end

        local text = CCLabelTTF:create("Coming Soon...", "Marker Felt", fontSize)
        bg:addChild(text)
        text:setPosition(bgSize.width / 2, bgSize.height / 2)
        text:setColor(ccc3(255, 255, 255))
    else
        -- build the scrolling part
        local scroll = config_sidebar.createSidebar(scrollSize.width, scrollSize.height, 0, 30, true, true)

        for i = #apps, 1, -1 do
            local app = apps[i]

            local cell = SpriteLayer.create(imgPrefix .. __G__iOSValue2("iphone/entry.png", "ipad/entry.png"))
            local cellSize = cell:getContentSize()

            local icon = CCSprite:create(app.icon_file)
            local iconSize = icon:getContentSize()
            icon:setAnchorPoint(ccp(0, 0))
            icon:setPosition(20, cellSize.height - iconSize.height - 20)
            cell:addChild(icon)

            local shadow = CCSprite:create("lib/moregames/6.png")
            shadow:setPosition(iconSize.width / 2, iconSize.height / 2)
            icon:addChild(shadow)

            local fontSize = 32
            local nameSize = CCSizeMake(cellSize.width - iconSize.width - 20 * 3, fontSize * 3)
            local name = CCLabelTTF:create(app.name, "Helvetica", fontSize,
                nameSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            name:setColor(ccc3(0, 0, 0))
            name:setAnchorPoint(ccp(0, 0))
            name:setPosition(icon:getPositionX() + iconSize.width + 20, icon:getPositionY() + iconSize.height - nameSize.height)
            cell:addChild(name)

            local button = ButtonLayer.create(imgPrefix .. __G__iOSValue2("iphone/free.png", "ipad/free.png"))
            local buttonSize = button:getContentSize()
            button.touchSound = config_sound_effects.common_bottom_icon_click
            button:setAnchorPoint(ccp(0, 0))
            button:setPosition(cellSize.width - buttonSize.width - 20, 20)
            cell:addChild(button)

            button.clickHandler = function(s)
                cclog("button %d clicked", i)

                if app.click_callback then
                    local utils = Utils:new()
                    utils:httpGet(app.click_callback, function() utils:release() end)
                end

                if app.url then
                     performWithDelay(s, function() Utils:sharedUtils():openURL(app.url) end, 0.2)
                end
            end

            local function onClick(sender, x, y)  -- sender is cell
                button.isTouchEnabled = true  -- let touchHit work
                if button:touchHit(x, y) then
                    button:onTouch("began", x, y)
                    button:onTouch("ended", x, y)
                end
            end

            scroll:addSubLayer(cell, i, onClick, nil)
        end

   
        scroll:setPosition(bgSize.width / 2 + scrollPosOffset.x, bgSize.height / 2 + scrollPosOffset.y)
        bg:addChild(scroll)
        bg:addToTouchResponders(scroll)
    end

    return popup

end

local function createResumeLoading(adType)
    local _checkCompletionInterval = 0.1
    local needShowBanner = nil
    local checkActionHandle = nil

    local CONST_SECONDS = 3
    local m_ad_has_shown = false
    local m_seconds = CONST_SECONDS
    local m_showAdFunc = false
    local adType = adType
    local m_retried = false
    local m_ad_has_shown_closed = false --广告显示后标记关闭

    local currScene = CCDirector:sharedDirector():getRunningScene()
    -- local imgBg = nil
    -- if not __G__isAndroid then
    --     imgBg = __G__iOSValue("menu/loadingbg/ios/i4.png", "menu/loadingbg/ios/i5.png","menu/loadingbg/ios/ipad.png")
    -- else
    --     -- imgBg = "menu/loadingbg/android/i5.png"
    --     imgBg = __G__iOSValue("menu/loadingbg/ios/i4.png", "menu/loadingbg/ios/i5.png","menu/loadingbg/ios/ipad.png")

    -- end

    -- local layer = SpriteLayer.create(imgBg)
    local layer = __G__popBG
    -- layer:getSprite():setOpacity(128)
    -- currScene:addChild(layer, 99999)
    -- layer:setPosition(__G__canvasCenter)

    local function performAddContentAndRun()
        -- layer:getSprite():setOpacity(128)
        currScene:addChild(layer, 5000, 5000)
        layer:setPosition(__G__canvasCenter)
    end

    if __G__isAndroid then
        performWithDelay(currScene, function()
            performAddContentAndRun()
        end, 0.1)
    else
        performAddContentAndRun()
    end

    local function FinishLoading()
         if checkActionHandle then
            layer:stopAction(checkActionHandle)
            checkActionHandle = nil
            cclog("＝1**************FinishLoading ------------>")
        else
            cclog("＝2**************FinishLoading ------------>")
            return
        end
        layer:removeFromParentAndCleanup(true)
        
        if __G__isAndroid then
            performWithDelay(currScene, function ()
                __G__ADLoadingCall = false
            end, 1)
        else
            __G__ADLoadingCall = false
        end
    end

    local function checkResourcesLoad()

        if (not m_showAdFunc) then
            return FinishLoading()
        end

        -- 广告已经显示
        if m_ad_has_shown then
            cclog("＝2**************＝m_retried＝＝＝dfdfdfdf end m_seconds")
            
            -- 广告已经显示
            print("-----m_ad_has_shown --",tostring(m_ad_has_shown_closed))

            if m_ad_has_shown_closed then

                return FinishLoading()
            else
                -- 等待

                return

            end
        end

        -- 广告未显示
        if m_seconds > 0 then
            m_seconds = m_seconds - _checkCompletionInterval
            print("*****************m_seconds",m_seconds)
            if m_seconds < 0 then
                if not m_retried then
                    m_retried = true
                    m_seconds = CONST_SECONDS
                    m_showAdFunc()
                    cclog("＝1**************＝m_retried＝＝＝dfdfdfdf end m_seconds")
                    return
                end
                -- 已经尝试过，并且时间已经到了
                m_seconds = 0

                if needShowBanner then
                    ---if banner hide in our control then show
                    AdsPopupManager:sharedManager():showBannerAd()
                    needShowBanner = nil
                end

                return FinishLoading()
            end
        end
    end
    
    if AdsPopupManager:sharedManager():bannerIsShowing() then
        ---- if banner here then hide
        AdsPopupManager:sharedManager():hideBannerAd()
        needShowBanner = true
    end

     -- 广告加载
    if adType == "CBCP" then
        m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitialCrossPromote() end
        performWithDelay(layer, m_showAdFunc, 0.5)
    elseif adType == "FULLAD" then
        m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitial() end
        performWithDelay(layer, m_showAdFunc, 0.5)
    else
        -- assert(adType == "TP", "ERROR adType!")
    end

    checkActionHandle = schedule(layer, checkResourcesLoad, _checkCompletionInterval)
    __G__ADLoadingCall = true
    __G__ADLoadingCallFunc = FinishLoading

    function currScene:AD_EVENT_HANDER(event)
        if event == "interstitialDidShow" then
            m_ad_has_shown = true
        end
        if event == "interstitialDidDismiss" then
            if needShowBanner then
                AdsPopupManager:sharedManager():showBannerAd()
                needShowBanner = nil
            end
            cclog("dddd######### interstitialDidDismiss")

            m_ad_has_shown_closed = true

            -- checkResourcesLoad()
            m_ad_has_shown = true
        end
    end

end

_G["config_popup"] = {
    createRateUs = createRateUs,
    createSaveImage = createSaveImage,
    createShop = createShop,
    createMoreGames = createMoreGames,
    createResumeLoading = createResumeLoading,
    createADLoading = createADLoading,
}
