--==================================================
--    @Brief:   Loading layer ui
--    @Author:  Rios
--    @Date:    2015-10-12
--==================================================

module (...,package.seeall)
local LoadingLayerUI = LoadingLayerUI or class("LoadingLayerUI")

local _tagBg = 10
local _tagProgressBg = 11
local _tagProgress = 12

local _loadingLayouts = 
{
    BCI = function( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/BCI/landscape/640x960.png", "lib/loadings/BCI/landscape/640x1136.png","lib/loadings/BCI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/BCI/landscape/1.png"
            progressBgImg2 = "lib/loadings/BCI/landscape/2.png"
            progressBg_x=__G__iOSValue(297,390,332)
            progressBg_y=__G__iOSValue(6,5,19)
        else
            bgImg = __G__iOSValue("lib/loadings/BCI/portrait/640x960.png", "lib/loadings/BCI/portrait/640x1136.png","lib/loadings/BCI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/BCI/portrait/1.png"
            progressBgImg2 = "lib/loadings/BCI/portrait/2.png"
            progressBg_x=__G__iOSValue(134,137,197)
            progressBg_y=__G__iOSValue(133,206,146)
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
            aProgress:setPosition(ccp(size.width/2, size.height/2))
            bg:addChild(aProgress,10,_tagProgress)
        end

        return layer
    end,

    BGI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/BGI/landscape/640x960.png", "lib/loadings/BGI/landscape/640x1136.png","lib/loadings/BGI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/BGI/landscape/1.png"
            progressBgImg2 = "lib/loadings/BGI/landscape/2.png"
            progressBg_x=__G__iOSValue(232,320,264)
            progressBg_y=__G__iOSValue(60,61,108)
        else
            bgImg = __G__iOSValue("lib/loadings/BGI/portrait/640x960.png", "lib/loadings/BGI/portrait/640x1136.png","lib/loadings/BGI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/BGI/portrait/1.png"
            progressBgImg2 = "lib/loadings/BGI/portrait/2.png"
            progressBg_x=__G__iOSValue(72,72,136)
            progressBg_y=__G__iOSValue(72,87,99)
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

        return layer
    end,

    BTI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/BTI/landscape/640x960.png", "lib/loadings/BTI/landscape/640x1136.png","lib/loadings/BTI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/BTI/landscape/1.png"
            progressBgImg2 = "lib/loadings/BTI/landscape/2.png"
            progressBg_x=__G__iOSValue(346,439,375)
            progressBg_y=__G__iOSValue(72,54,64)
        else
            bgImg = __G__iOSValue("lib/loadings/BTI/portrait/640x960.png", "lib/loadings/BTI/portrait/640x1136.png","lib/loadings/BTI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/BTI/portrait/1.png"
            progressBgImg2 = "lib/loadings/BTI/portrait/2.png"
            progressBg_x=__G__iOSValue(183,190,245)
            progressBg_y=__G__iOSValue(125,170,128)
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

        return layer
    end,

    FDI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/FDI/landscape/640x960.png", "lib/loadings/FDI/landscape/640x1136.png","lib/loadings/FDI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/FDI/landscape/1.png"
            progressBgImg2 = "lib/loadings/FDI/landscape/2.png"
            progressBg_x=__G__iOSValue(330,418,362)
            progressBg_y=__G__iOSValue(84,87,113)
        else
            bgImg = __G__iOSValue("lib/loadings/FDI/portrait/640x960.png", "lib/loadings/FDI/portrait/640x1136.png","lib/loadings/FDI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/FDI/portrait/1.png"
            progressBgImg2 = "lib/loadings/FDI/portrait/2.png"
            progressBg_x=__G__iOSValue(170,170,234)
            progressBg_y=__G__iOSValue(159,161,177)
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
            aProgress:setPosition(ccp(size.width/2, size.height/2))
            bg:addChild(aProgress,10,_tagProgress)
        end
        
        return layer
    end,

    FMI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/FMI/landscape/640x960.png", "lib/loadings/FMI/landscape/640x1136.png","lib/loadings/FMI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/FMI/landscape/1.png"
            progressBgImg2 = "lib/loadings/FMI/landscape/2.png"
            progressBg_x=__G__iOSValue(230,310,260)
            progressBg_y=__G__iOSValue(160,140,160)
        else
            bgImg = __G__iOSValue("lib/loadings/FMI/portrait/640x960.png", "lib/loadings/FMI/portrait/640x1136.png","lib/loadings/FMI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/FMI/portrait/1.png"
            progressBgImg2 = "lib/loadings/FMI/portrait/2.png"
            progressBg_x=__G__iOSValue(60,60,125)
            progressBg_y=__G__iOSValue(200,300,200)
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
            aProgress:setPosition(ccp(size.width/2+4, size.height/2-1))
            bg:addChild(aProgress,10,_tagProgress)
        end
        
        return layer
    end,

    GGI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/GGI/landscape/640x960.png", "lib/loadings/GGI/landscape/640x1136.png","lib/loadings/GGI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/GGI/landscape/1.png"
            progressBgImg2 = "lib/loadings/GGI/landscape/2.png"
            progressBg_x=__G__iOSValue(230,310,260)
            progressBg_y=__G__iOSValue(160,140,160)
        else
            bgImg = __G__iOSValue("lib/loadings/GGI/portrait/640x960.png", "lib/loadings/GGI/portrait/640x1136.png","lib/loadings/GGI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/GGI/portrait/1.png"
            progressBgImg2 = "lib/loadings/GGI/portrait/2.png"
            progressBg_x=__G__iOSValue(60,60,125)
            progressBg_y=__G__iOSValue(200,300,200)
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
            aProgress:setPosition(ccp(size.width/2+4, size.height/2-1))
            bg:addChild(aProgress,10,_tagProgress)
        end
        
        return layer
    end,
    
    IEL = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/IEL/landscape/640x960.png", "lib/loadings/IEL/landscape/640x1136.png","lib/loadings/IEL/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/IEL/landscape/1.png"
            progressBgImg2 = "lib/loadings/IEL/landscape/2.png"
            progressBg_x=__G__iOSValue(356,443,385)
            progressBg_y=__G__iOSValue(63,60,85)
        else
            bgImg = __G__iOSValue("lib/loadings/IEL/portrait/640x960.png", "lib/loadings/IEL/portrait/640x1136.png","lib/loadings/IEL/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/IEL/portrait/1.png"
            progressBgImg2 = "lib/loadings/IEL/portrait/2.png"
            progressBg_x=__G__iOSValue(197,195,253)
            progressBg_y=__G__iOSValue(112,136,125)
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
            aProgress:setPosition(ccp(size.width/2, size.height/2))
            bg:addChild(aProgress,10,_tagProgress)
        end
        
        return layer
    end,
    
    IPI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/IPI/landscape/640x960.png", "lib/loadings/IPI/landscape/640x1136.png","lib/loadings/IPI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/IPI/landscape/1.png"
            progressBgImg2 = "lib/loadings/IPI/landscape/2.png"
            progressBg_x=__G__iOSValue(353,443,410)
            progressBg_y=__G__iOSValue(58,52,76)
        else
            bgImg = __G__iOSValue("lib/loadings/IPI/portrait/640x960.png", "lib/loadings/IPI/portrait/640x1136.png","lib/loadings/IPI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/IPI/portrait/1.png"
            progressBgImg2 = "lib/loadings/IPI/portrait/2.png"
            progressBg_x=__G__iOSValue(192,194,255)
            progressBg_y=__G__iOSValue(124,179,107)
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
            aProgress:setPosition(ccp(size.width/2, size.height/2))
            bg:addChild(aProgress,10,_tagProgress)
        end
        
        return layer
    end,
    
    KMI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/KMI/landscape/640x960.png", "lib/loadings/KMI/landscape/640x1136.png","lib/loadings/KMI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/KMI/landscape/1.png"
            progressBgImg2 = "lib/loadings/KMI/landscape/2.png"
            progressBg_x=__G__iOSValue(230,310,260)
            progressBg_y=__G__iOSValue(160,140,160)
        else
            bgImg = __G__iOSValue("lib/loadings/KMI/portrait/640x960.png", "lib/loadings/KMI/portrait/640x1136.png","lib/loadings/KMI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/KMI/portrait/1.png"
            progressBgImg2 = "lib/loadings/KMI/portrait/2.png"
            progressBg_x=__G__iOSValue(60,60,125)
            progressBg_y=__G__iOSValue(200,300,200)
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
        
        return layer
    end,
    
    MSLPPI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/MSLPPI/landscape/640x960.png", "lib/loadings/MSLPPI/landscape/640x1136.png","lib/loadings/MSLPPI/landscape/768x1024.png")
        else
            bgImg = __G__iOSValue("lib/loadings/MSLPPI/portrait/640x960.jpg", "lib/loadings/MSLPPI/portrait/640x1136.jpg","lib/loadings/MSLPPI/portrait/768x1024.jpg")
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
        })

        return layer
    end,
    
    PAI = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/PAI/landscape/640x960.png", "lib/loadings/PAI/landscape/640x1136.png","lib/loadings/PAI/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/PAI/landscape/1.png"
            progressBgImg2 = "lib/loadings/PAI/landscape/2.png"
            progressBg_x=__G__iOSValue(270,358,302)
            progressBg_y=__G__iOSValue(58,66,64)
        else
            bgImg = __G__iOSValue("lib/loadings/PAI/portrait/640x960.png", "lib/loadings/PAI/portrait/640x1136.png","lib/loadings/PAI/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/PAI/portrait/1.png"
            progressBgImg2 = "lib/loadings/PAI/portrait/2.png"
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

        return layer
    end,
    
    PFG = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        local progressBgImg1,progressBgImg2 = nil,nil
        local progressBg_x,progressBg_y,progressBgScale=0,0,1.0
        if __G__isOrientationLandscape then
            bgImg = __G__iOSValue("lib/loadings/PFG/landscape/640x960.png", "lib/loadings/PFG/landscape/640x1136.png","lib/loadings/PFG/landscape/768x1024.png")
            progressBgImg1 = "lib/loadings/PFG/landscape/1.png"
            progressBgImg2 = "lib/loadings/PFG/landscape/2.png"
            progressBg_x=__G__iOSValue(310,394,342)
            progressBg_y=__G__iOSValue(19,38,31)
        else
            bgImg = __G__iOSValue("lib/loadings/PFG/portrait/640x960.png", "lib/loadings/PFG/portrait/640x1136.png","lib/loadings/PFG/portrait/768x1024.png")
            progressBgImg1 = "lib/loadings/PFG/portrait/1.png"
            progressBgImg2 = "lib/loadings/PFG/portrait/2.png"
            progressBg_x=__G__iOSValue(150,150,214)
            progressBg_y=__G__iOSValue(100,138,85)
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

        return layer
    end,   

    LAUNCH = function ( ... )
        local layer = Layer.create()

        local bgImg = nil
        bgImg = __G__iOSValue("i4.png", "i5.png", "ipad.png")

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
        })

        return layer
    end
}
function LoadingLayerUI:ctor( ... )
    self.m_layerResume = nil
    self.m_loadingLayouts = _loadingLayouts

    -- self:initResumeLoadingLayer(config_game:studio())
    if __G__isAndroid then
        self:initResumeLoadingLayer(config_game:studio())
    else
        self:initResumeLoadingLayer("LAUNCH")
    end
end

function LoadingLayerUI:initResumeLoadingLayer( studio )
    if not self.m_layerResume then
        self.m_layerResume = self:getStudioLoadingLayer(studio)

        self.m_layerResume:retain()
    end
end

function LoadingLayerUI:getStudioLoadingLayer( studio )
    local createFunc = self.m_loadingLayouts[studio]
    local layer = createFunc and createFunc() or nil
    if layer then
        --背景大图
        function layer:getLoadingBg( ... )
            return self:getChildByTag(_tagBg)
        end
        --进度条背景
        function layer:getProgressBg( ... )
            return self:getChildByTag(_tagProgressBg)
        end
        --进度条
        function layer:getProgressing( ... )
            local _node = nil
            local _itemBg = self:getProgressBg()
            if _itemBg then
                _node = _itemBg:getChildByTag(_tagProgress)           
            end
            return _node
        end
    else
        error("找不到对应studio的Loading配置！")     
    end

    return layer
end

-- 全局单例
local _loadingui_instance = nil
function LoadingLayerUI:getInstance()
    if not _loadingui_instance then
        _loadingui_instance = LoadingLayerUI.new()
    end

    LoadingLayerUI.new = function ( ... )
        error("LoadingLayerUI.new()--->access error!")
    end

    return _loadingui_instance
end

_G["config_loadingUI"] = LoadingLayerUI:getInstance()


