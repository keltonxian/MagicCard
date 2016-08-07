local _checkCompletionInterval = 0.1

require "config/config_loadingUI"

local LoadingScene = LoadingScene or class("LoadingScene", Scene)
LoadingScene.s_isShowing = false

function LoadingScene:ctor( images, sounds, musics, nextSceneCreateFunc, adType, isResumeLoading )

    local currScene = CCDirector:sharedDirector():getRunningScene()
    
    --从后台返回时，如果当前场景就是SceneLoading场景或者config_scene_effects中定义的特效场景，则不需要再处理
    if isResumeLoading then
        if currScene.__cname == LoadingScene.__cname or currScene.__cname == config_scene_effects.__cname then
            print("================LoadingScene is Showing================")
            return
        end
    end

    --避免android多次显示
    if LoadingScene.s_isShowing then 
        return 
    end

    LoadingScene.s_isShowing = true

    self.m_nextSceneCreateFunc = nextSceneCreateFunc
    self.m_adType = adType
    self.m_isResumeLoading = isResumeLoading

    self.m_layerLoading = nil
    
    self.m_seconds = 3
    self.m_ad_has_shown = false -- 广告是否已经显示
    self.m_checkActionHandle = nil
    self.m_loadResourcesDone = false
    self.m_ad_has_shown_closed = false --广告显示后标记关闭

	print(' --- XXX TODELETE SceneLoading AdsPopupManager bannerIsShowing ')
    --self.m_needShowBanner = AdsPopupManager:sharedManager():bannerIsShowing()
	self.m_needShowBanner = false
    
    local _objScene = self
    -- loading layer ui 
    local layer = nil
    
    --从后台返回
    if self.m_isResumeLoading then
        --使用config_loadingUI实例化时保存的m_layerResume
        layer = config_loadingUI.m_layerResume
        self.m_layerLoading = layer


        --在当前场景添加loading背景图
        currScene:addChild(layer, 5000, 5000)
        --隐藏进度条
        if layer:getProgressBg() then
            layer:getProgressBg():setVisible(false)
        end
        --先还原背景的显示
        -- layer:getLoadingBg():getSprite():runAction(CCFadeIn:create(0))
        layer:getLoadingBg():getSprite():setOpacity(255)
        
        if currScene.handleEvent and not currScene.handleEventOld then
            currScene.handleEventOld = currScene.handleEvent
            function currScene:handleEvent( ... )
                --currScene调用handleEvent时，_objScene可能已经释放
                if _objScene and _objScene.handleEvent then
                    _objScene:handleEvent(...)
                end
            end
        else
            function currScene:handleEvent( ... )
                --currScene调用handleEvent时，_objScene可能已经释放
                if _objScene and _objScene.handleEvent then
                    _objScene:handleEvent(...)
                end
            end
            --避免重复赋值
            currScene.handleEventOld = currScene.handleEvent
        end

		print('--- XXX TODELETE SceneLoading self scheduleShowAd()')
        --self:scheduleShowAd()       

        self:retain()

    else
        layer = config_loadingUI:getStudioLoadingLayer(config_game:studio())
        self.m_layerLoading = layer

        function layer:onEnterTransitionFinish()
            performWithDelay(self, function()
                -- release the texture cached in previous scene
                CCTextureCache:sharedTextureCache():removeUnusedTextures()

                -- preload resources
                __G__loadResources(images, sounds, musics)
                _objScene.m_loadResourcesDone = true
            end, 0.3)

            local _progressNode = self:getProgressing()
            if _progressNode then
                performWithDelay(self, function()
                    _progressNode.stepCount = _progressStepCount
                    _progressNode:runAction(CCProgressTo:create(0.5, 100))
                end, 0.0)
            end

        end
        self:addChild(layer)
    end

	print(' --- XXX TODELETE SceneLoading AdsPopupManager hideBannerAd ')
    -- hide banner ads unconditionally
    --AdsPopupManager:sharedManager():hideBannerAd()
            
    local function checkResourcesLoad()
        if (not self.m_isResumeLoading and not self.m_loadResourcesDone) then return end -- 资源必须加载完毕

        return self:checkFinishLogic()
        
    end
    -- start the completion check function
    layer.m_checkActionHandle = schedule(layer, checkResourcesLoad, _checkCompletionInterval)

    self.m_loadingBgSprite = layer:getLoadingBg()
    self.m_progressBgSprite = layer:getProgressBg()
    self.m_progressNode = layer:getProgressing()
    
end

function LoadingScene:checkFinishLogic( ... )
    local function FinishLoading()
        if self.m_layerLoading.m_checkActionHandle then
            self.m_layerLoading:stopAction(self.m_layerLoading.m_checkActionHandle)
            self.m_layerLoading.m_checkActionHandle = nil
        else
            return
        end
       
        -- animate the background then switch to next scene
        if self.m_loadingBgSprite then
            local arr = CCArray:create()
            arr:addObject(CCFadeOut:create(0.5))
            arr:addObject(CCCallFunc:create(function()

                    LoadingScene.s_isShowing = false

                    if self.m_isResumeLoading then
                        self.m_layerLoading:removeFromParentAndCleanup(false)

                        if self.m_needShowBanner then
                            AdsPopupManager:sharedManager():showBannerAd()
                        end

                        self:release()

                    else
                        return self.m_nextSceneCreateFunc()
                    end
                end))
            self.m_loadingBgSprite:getSprite():runAction(CCSequence:create(arr))
        end

        if self.m_progressBgSprite and self.m_progressNode then
            -- progress fade
            self.m_progressBgSprite:getSprite():runAction(CCFadeOut:create(0.5))
            self.m_progressNode:runAction(CCFadeOut:create(0.5))
        end
    end

    if (config_game and config_game.DebugNoLoadingAdvertisement) or (not self.m_showAdFunc) then
        return FinishLoading()
    end

    -- 广告已经显示
    if self.m_ad_has_shown then
        -- 广告已经关闭
        if self.m_ad_has_shown_closed then
            return FinishLoading()

        else
            -- 等待
            return

        end
    end

    -- 广告未显示
    if self.m_seconds > 0 then
        self.m_seconds = self.m_seconds - _checkCompletionInterval
        if self.m_seconds <= 0 then
            if not self.m_retried then
                self.m_retried = true
                self.m_seconds = 3
                self.m_showAdFunc()
                return
            end
            -- 已经尝试过，并且时间已经到了
            self.m_seconds = 0
            return FinishLoading()
        end
    end
end

function LoadingScene:scheduleShowAd( ... )
    local adType = self.m_adType
    
    if not adType then return end

    if config_game and config_game.DebugNoLoadingAdvertisement then
       return     
    end

    if not __G__isAndroid then
        --已经去广告
        if GlobalObj and GlobalObj:checkRemoveAllAds() then
            print("=============已经去广告==============")
            return
        end
    end   
    
    if adType == "CBCP" then
        self.m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitialCrossPromote() end
    elseif adType == "FULLAD" then
        self.m_showAdFunc = function() AdsPopupManager:sharedManager():showInterstitial() end
    end
    performWithDelay(self.m_layerLoading, self.m_showAdFunc, 1.5)
end

--[[
function LoadingScene:onEnterTransitionFinish()
    -- hide banner ads unconditionally
    AdsPopupManager:sharedManager():hideBannerAd()
    performWithDelay(self, function()
                -- release the texture cached in previous scene
                CCTextureCache:sharedTextureCache():removeUnusedTextures()

                -- preload resources
                __G__loadResources(self.images, self.sounds, self.musics)
                self.m_loadResourcesDone = true
            end, 0.3)

end
]]--

function LoadingScene:onEnter()  
	print('--- XXX TODELETE SceneLoading onEnter scheduleShowAd()')
    --self:scheduleShowAd()
end

function LoadingScene:onExit( ... )   
end

function LoadingScene:handleEvent( event_id, event_data )
    if event_id == Event.AdEvent then
        if event_data == "interstitialDidShow" then
            cclog("dddd######### interstitialDidShow")
            self.m_ad_has_shown = true
        elseif event_data == "interstitialDidDismiss" then

            cclog("dddd######### interstitialDidDismiss")

            self.m_ad_has_shown_closed = true

            self.m_ad_has_shown = true
        end
    end
end

_G["scene_loading"] = LoadingScene

