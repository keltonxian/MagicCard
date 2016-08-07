local _tagBg = 10
local _tagProgressBg = 11
local _tagProgress = 12
local _checkCompletionInterval = 0.1

--[[
arguments:
    images: (OPTIONAL) table, images to load
    sounds: (OPTIONAL) table, sound effects to load
    musics: (OPTIONAL) table, background musics to load
    nextSceneCreateFunc: (REQUIRED) create the targeted scene, takes no arguments
]]
local function create(images, sounds, musics, nextSceneCreateFunc, adType)
     -- 场景数据定义
    local CONST_SECONDS = 3 -- 再次发起广告显示的间隔
    local m_ad_has_shown = false -- 标记广告是否已经显示
    local m_seconds = CONST_SECONDS -- 倒计时剩余时间
    local m_showAdFunc = false  -- 广告显示调用函数
    local adType = adType -- 定义广告类型： "CBCP" --自推广告   "TP" -- short for third part
    -- local adType = "CBCP" -- 测试


    local layer = Layer.create()

    local bgImg = nil
    local progressBgImg1,progressBgImg2 = nil,nil
    local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
    if __G__isOrientationLandscape then
        bgImg = __G__iOSValue("loadings/PAI/landscape/640x960.png", "loadings/PAI/landscape/640x1136.png","loadings/PAI/landscape/768x1024.png")
        progressBgImg1 = "loadings/PAI/landscape/1.png"
        progressBgImg2 = "loadings/PAI/landscape/2.png"
        progressBg_x=__G__iOSValue(270,358,302)
        progressBg_y=__G__iOSValue(58,66,64)
    else
        bgImg = __G__iOSValue("loadings/PAI/portrait/640x960.png", "loadings/PAI/portrait/640x1136.png","loadings/PAI/portrait/768x1024.png")
        progressBgImg1 = "loadings/PAI/portrait/1.png"
        progressBgImg2 = "loadings/PAI/portrait/2.png"
        progressBg_x=__G__iOSValue(108,110,174)
        progressBg_y=__G__iOSValue(143,220,112)
    end

    layer:layout({
        {
            x = 0,
            y = 0,
            z = 0,
            tag = _tagBg,
            touch = -1,
            class = SpriteLayer,
            image = bgImg,
        },
        {
            x = progressBg_x,
            y = progressBg_y,
            z = 1,
            tag = _tagProgressBg,
            touch = -1,
            class = SpriteLayer,
            image = progressBgImg2,
            scale = progressBgScale,
        },
    })

    -- progress
    if true then
        local bg = layer:getChildByTag(_tagProgressBg)
        local size = bg:getContentSize()
        local aProgress = CCProgressTimer:create(CCSprite:create(progressBgImg1))
        aProgress:setType(kCCProgressTimerTypeBar)
        aProgress:setMidpoint(CCPointMake(0,0))
        aProgress:setBarChangeRate(CCPointMake(1, 0))
        aProgress:setPosition(ccp(size.width/2+1, size.height/2-2))
        bg:addChild(aProgress,10,_tagProgress)
    end

    local loadResourcesDone = false
    local checkActionHandle = nil

    local function FinishLoading()
        if checkActionHandle then
            layer:stopAction(checkActionHandle)
            checkActionHandle = nil
        end

        -- animate the background then switch to next scene
        local bg = layer:getChildByTag(_tagBg)
        local arr = CCArray:create()
        arr:addObject(CCFadeOut:create(0.5))
        arr:addObject(CCCallFunc:create(function()
                CCDirector:sharedDirector():replaceScene(nextSceneCreateFunc())
                -- return nextSceneCreateFunc()
            end))
        bg:getSprite():runAction(CCSequence:create(arr))

        -- progress fade
        layer:getChildByTag(_tagProgressBg):getSprite():runAction(CCFadeOut:create(0.5))
        layer:getChildByTag(_tagProgressBg):getChildByTag(_tagProgress):runAction(CCFadeOut:create(0.5))
    end

    local function checkResourcesLoad()
        if not loadResourcesDone then return end -- 资源必须加载完毕

        if (not m_showAdFunc) then
            return FinishLoading()
        end

        -- 广告已经显示
        if m_ad_has_shown then
            return FinishLoading()
        end

        -- 广告未显示
        if m_seconds > 0 then
            m_seconds = m_seconds - _checkCompletionInterval
            if m_seconds < 0 then
                if not m_retried then
                    m_retried = true
                    m_seconds = CONST_SECONDS
                    m_showAdFunc()
                    return
                end
                -- 已经尝试过，并且时间已经到了
                m_seconds = 0
                return FinishLoading()
            end
        end
    end

    function layer:onEnter()
        -- hide banner ads unconditionally
        AdsPopupManager:sharedManager():hideBannerAd()

                       -- 广告加载
        if adType == "CBCP" then
            print("============================================================================")
            m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitialCrossPromote() end
            performWithDelay(self, m_showAdFunc, 1.5)
        elseif adType == "FULLAD" then
            print("============================================================================")
            m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitial() end
            performWithDelay(self, m_showAdFunc, 1.5)
        else
            -- assert(adType == "TP", "ERROR adType!")
        end
    end

    function layer:onExit()
    end

    function layer:onEnterTransitionFinish()
        -- start the completion check function
        checkActionHandle = schedule(layer, checkResourcesLoad, _checkCompletionInterval)

        performWithDelay(self, function()
            -- release the texture cached in previous scene
            CCTextureCache:sharedTextureCache():removeUnusedTextures()

            -- preload resources
            __G__loadResources(images, sounds, musics)
            loadResourcesDone = true
        end, 0.3)

        performWithDelay(self, function()
            local aProgress = self:getChildByTag(_tagProgressBg):getChildByTag(_tagProgress)
            aProgress.stepCount = _progressStepCount
            aProgress:runAction(CCProgressTo:create(0.5, 100))
        end, 0.0)

    end

    function layer:onExitTransitionStart()
    end

    function layer:onCleanup()
    end

    local scene = CCScene:create()
    scene:addChild(layer)


             -- 广告事件监听函数定义
    function scene:AD_EVENT_HANDER(event)
        if event == "interstitialDidShow" then
            m_ad_has_shown = true
        elseif event == "interstitialDidDismiss" then
            
        end
    end


    return scene
end


_G["scene_loading"] = {
    create = create,
}
