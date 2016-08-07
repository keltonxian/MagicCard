-- tools configuration helpers

local function bounceAnotherTool(tool1, tool2)
    tool2.bounceTool = tool1

    tool1:addTouchBeganAction(
        function(sender, x, y)
            if not tool2.isTouchEnabled then
                return
            end

            local actionArray = CCArray:create()
            actionArray:addObject(CCCallFuncN:create(function(sender)
                sender.isTouchEnabled = false
                tool2.benchParent:toggleToolShadow(tool2:getTag(), false)
            end))
            local _zorder = tool2:getZOrder()
            tool2:setZOrder(tool1:getZOrder()+1)
            actionArray:addObject(CCJumpBy:create(0.5, ccp(0,0), 30, 1))
            actionArray:addObject(CCCallFuncN:create(function(sender)
                sender.isTouchEnabled = true
                tool2.benchParent:toggleToolShadow(tool2:getTag(), true)
                tool2:setZOrder(_zorder)
            end))

            tool2:runAction(CCSequence:create(actionArray))
        end
    )
end

--[[ arguments:
    tool: the ToolLayer instance which works with the particle emitter
    particlePlist: the particle plist file
    particlePosition: the position of emitter (MUST use tool's coordinate system), use tool's toolPointLocal if nil
    particleZ: the Z order of the emitter, -1 if nil
    particleLayer: OPTIONAL, if nil, the emitter is attached to the tool, otherwise emitter is added to the particleLayer and moved along as the tool moves
]]
local function withParticleAnimation(tool, particlePlist, particlePosition, particleZ, particleLayer)
    local function resetEmitterPosition(emitter, toolLocalPosition)
        local worldPos = tool:convertToWorldSpace(toolLocalPosition)
        local newPos = particleLayer:convertToNodeSpace(worldPos)
        emitter:setPosition(newPos.x, newPos.y)
    end

    local emitter = CCParticleSystemQuad:create(particlePlist)
    emitter:setPositionType(kCCPositionTypeFree)  -- IMPORTANT: make particles detached from the emitter once spawned
    emitter:stopSystem()

    if not particleZ then
        particleZ = -1
    end

    if not particlePosition then
        particlePosition = ccp(tool.toolPointLocal.x, tool.toolPointLocal.y)
    end

    if particleLayer then
        particleLayer:addChild(emitter, particleZ)
    else
        emitter:setPosition(particlePosition.x, particlePosition.y)
        tool:addChild(emitter, particleZ)
    end

    -- NOTE: DO NOT scale the emitter otherwise the position type "kCCPositionTypeFree" doesn't work at all
    -- see the discussion here: http://stackoverflow.com/questions/10093112/cocos2d-particles-follow-the-emitter-instead-of-staying-at-the-position-they-w
    -- emitter:setScale(tool.scaleOnPickUp)
    -- emitter:setRotation(-tool.rotateOnPickUp)

    tool:addTouchBeganAction(
        function(sender, x, y)
            if particleLayer then
                resetEmitterPosition(emitter, particlePosition)
            end
            emitter:resetSystem()
        end
    )

    tool:addTouchEndedAction(
        function(sender, x, y)
            emitter:stopSystem()
        end
    )

    if particleLayer then
        tool:addTouchMovedAction(
            function(sender, x, y)
                resetEmitterPosition(emitter, particlePosition)
            end
        )
    end
end

--[[ arguments:
    tool: the TooLayer instance
    scratch: the ScratchLayer instance
    scratchOutOrNot: true for scratchOut, false for scratchIn
    brushSprite:  a layer instancethe, or a function which returns a layer instance; the layer instance MUST be retained outside of this call of function
    percentageCallback (OPTIONAL): called on touch ended, with 1 argument, percentage of transparency
    scratchOpacity: the one and only factor which affects the scratch-in / scratch-out look and feel, use the following values as references:
        - scratch-in with color blending: 0.6
        - scratch-in without color blending: 1.0
        - scratch-out with prossively erasing: 0.9
        - scratch-out without prossively erasing: 0.0
        DEFAULT: 0.9 for scratch-out and 1.0 for scratch-in
]]
local function performScratch(tool, scratch, scratchOutOrNot, brushSprite, percentageCallback, scratchOpacity, eraseOnScratch)
    local brushType = scratchOutOrNot and eScribbleBrushTypeEaser or eScribbleBrushTypeBrush
    local brushBlending = false

    if not scratchOpacity then
        scratchOpacity = scratchOutOrNot and 0.9 or 1.0
    end

    if (not scratchOutOrNot) and scratchOpacity < 1.0 then
        brushBlending = true
    end

    tool:addTouchBeganAction(
        function(sender, x, y)
            local brush

            if type(brushSprite) == "function" then
                brush = brushSprite()
            else
                brush = brushSprite
            end

            if not sender.scribblePainter then
                sender.scribblePainter = Scribble:new(brush)
            end

            if brushBlending then
                sender.scribblePainter:saveCanvasTexture(scratch.renderTexture)
            end
        end
    )

    tool:addTouchMovedAction(
        function(sender, x, y)
            local brush = sender.scribblePainter:getBrush()

            if eraseOnScratch then  -- do erase before other scratch stuff
                brush:setOpacity(0.0)
                sender.scribblePainter:setBrushType(eScribbleBrushTypeEaser, brushBlending)
                sender.scribblePainter:paint(scratch.scratchSprite, scratch.renderTexture, sender.toolPoint)
            end

            brush:setOpacity(255 * scratchOpacity)
            sender.scribblePainter:setBrushType(brushType, brushBlending)
            sender.scribblePainter:paint(scratch.scratchSprite, scratch.renderTexture, sender.toolPoint)
        end
    )

    tool:addTouchEndedAction(
        function(sender, x, y)
            if sender.scribblePainter then
                sender.scribblePainter:delete()
                sender.scribblePainter = nil
            end

            if percentageCallback then
                percentageCallback(scratch:getPercentageTransparent())
            end
        end
    )

end


--[[ arguments
tool: TooLayer instance
areaRect: the rect (should be create with CCRectMake) of the target area
detectPoint: the point to detect, use toolPointLocal if nil
insideAction: callback function when inside the area, passed arguments: tool, x, y
outsideAction: callback function when outside the area
touchBeganAction (OPTIONAL)
touchEndedAction (OPTIONAL)
]]
local function actionInsideArea(tool, areaRect, detectPoint, insideAction, outsideAction, touchBeganAction, touchEndedAction)
    tool:addTouchMovedAction(
        function(sender, x, y)
            local nx, ny  -- the point to detect

            if detectPoint then
                nx, ny = detectPoint.x, detectPoint.y
            else
                nx, ny = sender.toolPoint.x, sender.toolPoint.y
            end

            if areaRect:containsPoint(ccp(nx, ny)) then
                if insideAction then
                    insideAction(sender, x, y)
                end
            else
                if outsideAction then
                    outsideAction(sender, x, y)
                end
            end
        end
    )

    if touchBeganAction then
        tool:addTouchBeganAction(touchBeganAction)
    end

    if touchEndedAction then
        tool:addTouchEndedAction(touchEndedAction)
    end
end

local function playLoopSoundInsideArea(tool, areaRect, detectPoint, sound)
    actionInsideArea(tool, areaRect, detectPoint,
        -- inside area
        function(sender, x, y)
            if not sender.playingSoundInside then
                sender.playingSoundInside = true
                if sender.loopSoundHandle then
                    AudioEngine.stopEffect(sender.loopSoundHandle)
                end
                sender.loopSoundHandle = AudioEngine.playEffect(sound, true)
            end
        end,
        -- outside area
        function(sender, x, y)
            if sender.playingSoundInside then
                sender.playingSoundInside = false
                AudioEngine.stopEffect(sender.loopSoundHandle)
            end
        end,
        -- touch began
        function(sender, x, y)
            sender.playingSoundInside = false
        end,
        -- touch ended
        function(sender, x, y)
            if sender.playingSoundInside then
                sender.playingSoundInside = false
                AudioEngine.stopEffect(sender.loopSoundHandle)
            end
        end
    )
end

local function playOneOffSoundInsideArea(tool, areaRect, detectPoint, sound, playOnceGlobally)
    actionInsideArea(tool, areaRect, detectPoint,
        -- inside area
        function(sender, x, y)
            if playOnceGlobally and sender.oneOffSoundPlayedGlobally then
                return
            end

            if not sender.oneOffSoundPlayed then
                sender.oneOffSoundPlayed = true
                sender.oneOffSoundPlayedGlobally = true
                AudioEngine.playEffect(sound, false)
            end
        end,
        -- outside area
        function(sender, x, y)
        end,
        -- touch began
        function(sender, x, y)
            sender.oneOffSoundPlayed = false
        end,
        -- touch ended
        function(sender, x, y)
            sender.oneOffSoundPlayed = false
        end
    )
end

local function playSoundOnPickup(tool, sound, isLoop)
    tool:addTouchBeganAction(
        function(sender, x, y)
            sender.soundOnPickupHandle = AudioEngine.playEffect(sound, isLoop)
        end
    )

    tool:addTouchEndedAction(
        function(sender, x, y)
            AudioEngine.stopEffect(sender.soundOnPickupHandle)
        end
    )
end

--当第times次触碰tool时播放一次音效
local function playOnTimesOnPickup(tool, sound, times)
    tool:addTouchBeganAction(
        function(sender, x, y)
            if not sender.touchCounts then
                sender.touchCounts = 0    
            end

            sender.touchCounts = sender.touchCounts + 1

            if sender.touchCounts == times then
                AudioEngine.playEffect(sound, false)
            end
        end
    )

    tool:addTouchEndedAction(
        function(sender, x, y)  
        end
    )
end

--随机播放数组里的音效
local function playSoundInArray(array)
    if #array > 0 then
        AudioEngine.playEffect(array[math.random(#array)], false)
    end
    
end

--工具拾起时播放音效1，放下后播放音效2
local function playSoundOnBeginAndEnd(tool,sound1,sound2,onetime)
    if sound1 then

        if sound1 then
            tool:addTouchBeganAction(function()
                tool.playEndSound = false

                if onetime then
                    if not tool.oneOffSoundOnFirstPickup then
                        tool.oneOffSoundOnFirstPickup = true 
                        tool.soundOnPickupHandle1 = AudioEngine.playEffect(sound1,false) 
                    end
                else
                    tool.soundOnPickupHandle1 = AudioEngine.playEffect(sound1,false)
                end
                
                
            end)
        end
        if sound2 then
            tool:addTouchMovedAction(function()
                tool.playEndSound = true
            end)
            tool:addTouchEndedAction(function()
                if onetime then
                    if not tool.oneOffSoundOnFirstPutdown then 
                        tool.oneOffSoundOnFirstPutdown = true
                        AudioEngine.stopEffect(tool.soundOnPickupHandle1)
                        
                        if tool.playEndSound then
                            AudioEngine.playEffect(sound2,false)
                        end
                         
                    end
                else
                    AudioEngine.stopEffect(tool.soundOnPickupHandle1)
                    if tool.playEndSound then
                        AudioEngine.playEffect(sound2,false)
                    end
                end
                       
            end)
        end
    end
end

local function moveEyesWithTouch(layer, eyes, moveRadius)

    local eyesOrigPos = ccp(eyes:getPositionX(), eyes:getPositionY())

    local eyesMoveOrigin = eyesOrigPos  -- they are unnecessary to be the same I think
    local eyesMoveRadius = moveRadius

    local function updateEyesPosition(x, y)
        local dx = x - eyesMoveOrigin.x
        local dy = y - eyesMoveOrigin.y
        local angle = math.atan2(dy, dx)

        angle = math.rad(math.deg(angle) + 90)

        local nx = eyesMoveRadius * math.sin(angle)
        local ny = eyesMoveRadius * math.cos(angle)

        eyes:setPosition(eyesOrigPos.x + nx, eyesOrigPos.y - ny) 
    end

    ----------------------------------------------------------------

    local oldOnTouch = layer.onTouch

    layer.onTouch = function(s, e, x, y)
    
        if e == "began" then
            updateEyesPosition(x, y)
        elseif e == "moved" then
            updateEyesPosition(x, y)
        elseif e == "ended" then
            eyes:setPosition(eyesOrigPos.x, eyesOrigPos.y)
        end

        return oldOnTouch(s, e, x, y)
    end

--[[
   function layer:onTouchBegan(x, y)
        cclog("=====================layer from spa onTouchBegan")
        updateEyesPosition(x, y)
        return Layer:onTouchBegan(x, y)
    end

    function layer:onTouchMoved(x, y)
        cclog("======================layer from spa onTouchMoved")
       updateEyesPosition(x, y)
       return Layer:onTouchMoved(x, y)
   end

   function layer:onTouchEnded(x, y)
        cclog("=======================layer from spa onTouchEnded")
       eyes:setPosition(eyesOrigPos.x, eyesOrigPos.y)
       return Layer:onTouchEnded(x, y)
   end
]]
end

_G["config_tools"] = {
    bounceAnotherTool = bounceAnotherTool,
    withParticleAnimation = withParticleAnimation,
    performScratch = performScratch,
    actionInsideArea = actionInsideArea,
    playLoopSoundInsideArea = playLoopSoundInsideArea,
    playOneOffSoundInsideArea = playOneOffSoundInsideArea,
    playSoundOnPickup = playSoundOnPickup,
    playOnTimesOnPickup = playOnTimesOnPickup,
    playSoundInArray = playSoundInArray,
    playSoundOnBeginAndEnd = playSoundOnBeginAndEnd,
    moveEyesWithTouch = moveEyesWithTouch,
}
