
--==================================================
--    @Brief:    特效工具
--    @Author:   Rios
--    @Date:     2015-07-17
--==================================================

----------------------------------------------------
-- 闪烁 Layer
----------------------------------------------------
local function blinkLayer(aLayer)
    aLayer:stopAllActions()
    -- 动画
    local arr = CCArray:create()
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(false)
    end))
    arr:addObject(CCDelayTime:create(0.15))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(true)
    end))
    arr:addObject(CCDelayTime:create(0.25))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(false)
    end))
    arr:addObject(CCDelayTime:create(0.15))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(true)
    end))
    aLayer:runAction(CCSequence:create(arr))
end

----------------------------------------------------
-- 循环闪烁 Layer
----------------------------------------------------
local function blinkRepeatLayer(aLayer)
    aLayer:stopAllActions()
    -- 动画
    local arr = CCArray:create()
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(false)
    end))
    arr:addObject(CCDelayTime:create(0.15))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(true)
    end))
    arr:addObject(CCDelayTime:create(0.25))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(false)
    end))
    arr:addObject(CCDelayTime:create(0.15))
    arr:addObject(CCCallFunc:create(function ()
        aLayer:setVisible(true)
    end))
    aLayer:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

----------------------------------------------------
-- 帧动画(打包图片格式:aIndexs={1,2,3,4,5...})
----------------------------------------------------
local function layerFrameAnimation(aLayer, aFrameFormat, aIndexs, aInterval, isLoop)
    return function()
        local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
        local animFrames = CCArray:create()
        if type(aIndexs) == "table" then
            for i,v in ipairs(aIndexs) do
                animFrames:addObject(cache:spriteFrameByName(string.format(aFrameFormat,v)))
            end
        end
        local animation = CCAnimation:createWithSpriteFrames(animFrames, aInterval)
        local animate = CCAnimate:create(animation)
        local aAnimateSprite = aLayer
        if type(aLayer) ~= "CCSprite" then
            aAnimateSprite = aLayer:getSprite()
        end
        if aLayer.layerFrameAnimation then aAnimateSprite:stopAction(aLayer.layerFrameAnimation) end
        if isLoop then
            aLayer.layerFrameAnimation = aAnimateSprite:runAction(CCRepeatForever:create(animate))
        else
            aLayer.layerFrameAnimation = aAnimateSprite:runAction(animate)
        end
    end
end

----------------------------------------------------
-- 帧动画(直接用图片格式aIndexs={1,2,3,4,5...})
----------------------------------------------------
local function layerChangeImageAnimation(aLayer, aImageFormat, aIndexs, aInterval, isLoop)
    return function()
        local arr = CCArray:create()
        if type(aIndexs) == "table" then
            for i,v in ipairs(aIndexs) do
                arr:addObject(CCCallFunc:create(function ()
                    aLayer:setSprite(string.format(aImageFormat,v))
                end))
                arr:addObject(CCDelayTime:create(aInterval))
            end
        end
        if aLayer.layerChangeImageAnimation then aLayer:stopAction(aLayer.layerChangeImageAnimation) end
        if isLoop then
            aLayer.layerChangeImageAnimation = aLayer:runAction(CCRepeatForever:create(CCSequence:create(arr)))
        else
            aLayer.layerChangeImageAnimation = aLayer:runAction(CCSequence:create(arr))
        end
    end
end

----------------------------------------------------
-- 根据触摸Touch 转动眼睛
----------------------------------------------------
local function configMovingEye(aData)
    local aEyesLayer = aData.eyesLayer
    local aTouchLayers = aData.touchLayers
    local aTools = aData.tools

    local eyesOrigPos = ccp(aEyesLayer:getPositionX(), aEyesLayer:getPositionY())
    local eyesMoveOrigin = eyesOrigPos  -- they are unnecessary to be the same I think
    local eyesMoveRadius = 5
    function updateEyesPosition(x, y)
        local dx = x - eyesMoveOrigin.x
        local dy = y - eyesMoveOrigin.y
        local angle = math.atan2(dy, dx)
        angle = math.rad(math.deg(angle) + 90)
        local nx = eyesMoveRadius * math.sin(angle)
        local ny = eyesMoveRadius * math.cos(angle)
        aEyesLayer:setPosition(eyesOrigPos.x + nx, eyesOrigPos.y - ny)
    end

    for i,v in ipairs(aTouchLayers) do
        function v:onTouchBegan(x, y)
            -- body
            updateEyesPosition(x, y)
            return Layer:onTouchBegan(x, y)
        end
        function v:onTouchMoved(x, y)
           -- body
           updateEyesPosition(x, y)
           return Layer:onTouchMoved(x, y)
       end
       function v:onTouchEnded(x, y)
           -- body
           aEyesLayer:setPosition(eyesOrigPos.x, eyesOrigPos.y)
           return Layer:onTouchEnded(x, y)
       end
    end

    for i,v in ipairs(aTools) do
        v:addTouchBeganAction(function(sender, x, y)
            updateEyesPosition(x, y)
        end)
        v:addTouchMovedAction(function(sender, x, y)
            updateEyesPosition(x, y)
        end)
        v:addTouchEndedAction(function(sender, x, y)
            aEyesLayer:setPosition(eyesOrigPos.x, eyesOrigPos.y)
        end)
    end
end

----------------------------------------------------
-- a board move from right to left appear
----------------------------------------------------
local function boardSlideAppear(aLayer)
    if aLayer == nil then return end
    aLayer:setVisible(true)
    aLayer:stopAllActions()
    aLayer:getParent():setVisible(true)
    aLayer:setPosition(__G__canvasSize.width+aLayer:getContentSize().width, __G__canvasSize.height/2)
    local move = CCMoveBy:create(1.3, CCPointMake(__G__canvasSize.width/2+aLayer:getContentSize().width, 0))
    local move_ease_inout1 = CCEaseElasticInOut:create(move, 0.3)
    local move_ease_inout_back1 = move_ease_inout1:reverse()
    local arr1 = CCArray:create()
    arr1:addObject(move_ease_inout_back1)
    local seq1 = CCSequence:create(arr1)
    aLayer:runAction(seq1)
end

----------------------------------------------------
-- 工具拿起特效
----------------------------------------------------
local function toolPickupEffect(aTool, isPickup)
    local scale1 = CCScaleTo:create(.27, 1.2,0.8)
    local scale2 = CCScaleTo:create(.27, 0.9,1.1)
    local scale3 = CCScaleTo:create(.27, 1.0,1.0)
    local arr1 = CCArray:create()
    if not isPickup then
        arr1:addObject(CCDelayTime:create(0.18))
    end
    arr1:addObject(scale1)
    arr1:addObject(scale2)
    arr1:addObject(scale3)
    local seq1 = CCSequence:create(arr1)
    aTool:runAction(seq1)
end

----------------------------------------------------
-- 批量添加涂抹层
----------------------------------------------------
local function addScratchLayers(aData, aParentLayer, aBrushLayer)
    --[[eg:
    local aScratchData = {
            {
                "lv3/hair/0.png",true,65,31,_z.hair, _tag.hair
            },
        }
    ]]
    local defaultParentLayer = aParentLayer
    local defaultBrushSprite = aBrushLayer
    for i,v in ipairs(aData) do
        local scratchImage, isScratchOut, x, y, z, tag = v[1],v[2],v[3],v[4],v[5],v[6]
        local scratch = ScratchLayer.create()

        scratch.scratchOut = isScratchOut
        scratch.scratchSprite = CCSprite:create(scratchImage)
        scratch.scratchSprite:retain()
        scratch.brushSprite = defaultBrushSprite
        scratch:setupScratch()
        scratch:reset()
        scratch.isTouchEnabled = true  -- let the touchHit method work

        scratch.renderTexture:getSprite():getTexture():setAntiAliasTexParameters()

        local s = scratch:getContentSize()
        scratch:setPosition(x + s.width / 2, y + s.height / 2)

        function scratch:onEnter()
            if self.scratchSprite == nil and self.scratchImageBackup then
                scratch.scratchSprite = CCSprite:create(scratchImage)
                scratch.scratchSprite:retain()
            end

            ScratchLayer.onEnter(self)
        end

        function scratch:onExit()
            cclog("cleanup the scratch layer (tag %d) on exit", self:getTag())

            self.scratchImageBackup = scratchImage  -- save it in order to recreate it when return from next scene
            self.scratchSprite:release()
            self.scratchSprite = nil
        end

        defaultParentLayer:addChild(scratch, z, tag)
    end
end

----------------------------------------------------
-- 重置涂抹层
----------------------------------------------------
local function resetMaskLayer(layerTag, aParentLayer)
    local scratch = aParentLayer:getChildByTag(layerTag)
    scratch:reset()
    scratch:setVisible(true)
end

----------------------------------------------------
-- 获取掉落物体数组
----------------------------------------------------
local function getOneByOneLayers(aData, aParentLayer)
    local parentLayer = aParentLayer-- aData.parentLayer
    local baseTag = aData.baseTag
    local cout = aData.cout

    local tableRes = {}
    for i=1,cout do
        local aDropThings = parentLayer:getChildByTag(baseTag+i)
        if aDropThings then
            table.insert(tableRes,aDropThings)
        end
    end

    return tableRes
end

----------------------------------------------------
-- 创建掉落物体（单个放置->触摸掉落）
----------------------------------------------------
local function newOneByOneLayers(aData, aParentLayer, isHide)

    local parentLayer = aParentLayer
    local z = aData.z
    local baseTag = aData.baseTag
    local cout = aData.cout
    local xy = aData.xy
    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    if aData.plist then
        cache:addSpriteFramesWithFile(aData.plist, aData.plistImage);
    end
    for i=1,cout do
        local aDropThings = parentLayer:getChildByTag(baseTag+i)
        if aDropThings then
            local hideAction = CCFadeIn:create(0)
            aDropThings:runAction(hideAction)
        else
            -- normal image format
            if aData.imageFormat then
                aDropThings = CCSprite:create(string.format(aData.imageFormat,i))           
                parentLayer:addChild(aDropThings, z,baseTag+i)
            end
            -- for animation 
            if aData.animateImages then
                local animFrames = CCArray:create()
                for p=1, #aData.animateImages do
                    animFrames:addObject(cache:spriteFrameByName(aData.animateImages[p]));
                end
                aDropThings = CCSprite:createWithSpriteFrameName(aData.animateImages[1]);          
                parentLayer:addChild(aDropThings, z,baseTag+i)

                local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.5)
                local animate = CCAnimate:create(animation);
                aDropThings:runAction(CCRepeatForever:create(animate))
            end
            -- for image list
            if aData.plistImageFormat then
                aDropThings=CCSprite:createWithSpriteFrameName(string.format(aData.plistImageFormat,i));
                parentLayer:addChild(aDropThings, z,baseTag+i)
            end
        end
        -- reset position
        local s = aDropThings:getContentSize()
        aDropThings:setPosition((xy[i]).x+s.width / 2,(xy[i]).y+s.height / 2)
        aDropThings.isDrop = false
        aDropThings:setVisible(true)

        if isHide then
            aDropThings:setVisible(false)
        end
    end
end

----------------------------------------------------
-- 在layer 上添加箭头(循环播放)
----------------------------------------------------
local function addArrowToLayer(aLayer, aDirection, isRepeat, isHide, aPostion)
    if not aLayer.arrowLayer then
        local aArrow = CCSprite:create(string.format("menu/arrow/%d.png",aDirection))
        local aLayerSize = aLayer:getContentSize()
        local aArrowSize = aArrow:getContentSize()
        if aPostion then
            aArrow:setPosition(aPostion)
        else
            local poses = {
                ccp(aLayerSize.width/2, aLayerSize.height+aArrowSize.height/2),
                ccp(aLayerSize.width+aArrowSize.width/4, aLayerSize.height+aArrowSize.height/4),
                ccp(aLayerSize.width+aArrowSize.width/2, aLayerSize.height/2),
                ccp(aLayerSize.width+aArrowSize.width/4, -aArrowSize.height/4),
                ccp(aLayerSize.width/2, -aArrowSize.height/4),
                ccp(-aArrowSize.width/4, -aArrowSize.height/4),
                ccp(-aArrowSize.width/2, aLayerSize.height/2),
                ccp(-aArrowSize.width/4, aLayerSize.height+aArrowSize.height/4),
            }
            if aDirection <= #poses then
                aArrow:setPosition(poses[aDirection])
            end
        end
        aLayer:addChild(aArrow,1)
        aLayer.arrowLayer = aArrow
        if isRepeat then
            common_effect.blinkRepeatLayer(aArrow)
        end
        if isHide then
            aArrow:setVisible(false)
        end
    end
end

----------------------------------------------------
-- 批量添加 静态 Layer
----------------------------------------------------
local function modelStaticLayoutData(aStaticData)
    local aLayoutData = {}
    for i,v in ipairs(aStaticData) do
        table.insert(aLayoutData,{x = v[1], y = v[2], z = v[3], tag = v[4], touch = -1, class = SpriteLayer, image = v[5]})
    end
    return aLayoutData
end

----------------------------------------------------
-- 批量添加 动画 Layer
----------------------------------------------------
local function modelFrameAnimationLayoutData(aStaticData)
    local aLayoutData = {}
    for i,v in ipairs(aStaticData) do
        table.insert(aLayoutData,{x = v[1], y = v[2], z = v[3], tag = v[4], touch = -1, class = SpriteLayer, spriteFrameName = v[5]})
    end
    return aLayoutData
end

----------------------------------------------------
-- 批量添加 按钮
----------------------------------------------------
local function modelButtonLayoutData(aButtonData)
    local aLayoutData = {}
    for i,v in ipairs(aButtonData) do
        table.insert(aLayoutData,{x = v[1], y = v[2], z = v[3], tag = v[4], touch = 1, class = ButtonLayer, image = v[5], 
            attributes = { 
                dimOnPress = false,
                enableOnTouchAnimation = false,
                touchThroughTransparentStrict = true,
                minClickInterval = 0.5,
                clickHandler = function(s)
                    v[6](s)
                end,
                },})
    end
    return aLayoutData
end

----------------------------------------------------
-- 批量添加 按钮（带特效）
----------------------------------------------------
local function modelButtonEffectLayoutData(aButtonData)
    local aLayoutData = {}
    for i,v in ipairs(aButtonData) do
        table.insert(aLayoutData,{x = v[1], y = v[2], z = v[3], tag = v[4], touch = 1, class = ButtonLayer, image = v[5], 
            attributes = { 
                dimOnPress = true,
                enableOnTouchAnimation = true,
                touchThroughTransparentStrict = true,
                minClickInterval = 0.5,
                clickHandler = function(s)
                    v[6](s)
                end,
                },})
    end
    return aLayoutData
end

----------------------------------------------------
-- 批量添加 工具
----------------------------------------------------
local function modelToolLayoutData(aToolData)
    local aLayoutData = {}
    for i,v in ipairs(aToolData) do
        table.insert(aLayoutData,{x = v[1], y = v[2], z = v[3], tag = v[4], touch = 1, class = ToolLayer, image = v[5], attributes = { canPickUp = true, pickUpEffect = true },})
    end
    return aLayoutData
end

----------------------------------------------------
-- 接口
----------------------------------------------------
_G["effect_kit"] = {
    blinkLayer = blinkLayer,
    blinkRepeatLayer = blinkRepeatLayer,
    layerFrameAnimation = layerFrameAnimation,
    layerChangeImageAnimation = layerChangeImageAnimation,
    configMovingEye = configMovingEye,
    boardSlideAppear = boardSlideAppear,
    toolPickupEffect = toolPickupEffect,
    addScratchLayers = addScratchLayers,
    resetMaskLayer = resetMaskLayer,
    getOneByOneLayers = getOneByOneLayers,
    newOneByOneLayers = newOneByOneLayers,
    addArrowToLayer = addArrowToLayer,
    modelStaticLayoutData = modelStaticLayoutData,
    modelFrameAnimationLayoutData = modelFrameAnimationLayoutData,
    modelButtonLayoutData = modelButtonLayoutData,
    modelButtonEffectLayoutData = modelButtonEffectLayoutData,
    modelToolLayoutData = modelToolLayoutData,
}
