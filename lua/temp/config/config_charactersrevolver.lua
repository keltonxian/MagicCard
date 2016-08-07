-- create a layer which is able to revolve the characer images (horizontally) by swipe

require("base/SpriteLayer")

local modCfgSounds = require "game.ConfigSounds"
local tblSceneSounds = modCfgSounds.tblCharacter --这里要修改为对应的tbl
local randSounds = tblSceneSounds.randSounds
local tblCommonSounds = modCfgSounds.tblCommon



-- revolver layer size
local _width = __G__canvasSize.width
local _height = __G__canvasSize.height
-- imagine all the character images form a circle
local _nCharacters = 4
local _angleBetween = 360 / _nCharacters
local _revolvingCenterX = _width / 2
local _revolvingRadiusFactor = __G__iOSValue(180,180,200)
local _revolvingRadius = _revolvingRadiusFactor / math.sin(math.rad(_angleBetween))
-- character visual factors
local _minScale = __G__iOSValue(0.8,1.0,0.9)
local _maxScale = __G__iOSValue(0.8,1.0,0.9)
local _minZ = 10
local _maxZ = 100
local _minCharacterY = __G__iOSValue(400,450,400)-80
local _maxCharacterY = _minCharacterY + __G__iOSValue(120,135,120)
-- other settings
local _autoCenterAnimationDuration = 0.17
local _minCharacterChosenAngle = 3
-- for debug
local _testBlockSize = CCSizeMake(400, 750)

local _modelScale = __G__iOSValue(1,1,1)

local _characters = {
    {
        image = "characters/model/1.png",
        name = "characters/model/1a.png",
        sound = tblSceneSounds[1],
        tag = 1,
        anchorPoint = {x = 0.4, y = 0.5}, 
        centerOffsetX = 0, --有时候UI出的图人物不居中
        nameOffset = {x=-50,y=-100},
    },
    {
        image = "characters/model/2.png",
        name = "characters/model/2a.png",
        sound = tblSceneSounds[2],
        tag = 2,
        anchorPoint = {x = 0.4, y = 0.5}, 
        centerOffsetX = 0,
        nameOffset = {x=-50,y=-100},
    }, 
    {
        image = "characters/model/3.png",
        name = "characters/model/3a.png",
        sound = tblSceneSounds[3],
        tag = 3,
        centerOffsetX = 0,
        nameOffset = {x=0,y=-100},
    }, 
    {        
        image = "characters/model/4.png",
        name = "characters/model/4a.png",
        sound = tblSceneSounds[4],
        tag = 4,
        centerOffsetX = 0,
        nameOffset = {x=0,y=-100},
    },
         
}

local _tagName = 50
local _tagLock = 60
local _tagHiddenMenu = 100

local _tagHome = 121
local _tagMore = 122
local _tagShop = 123

local hiddenMenu

local iapCallback = nil
--[[
definitions:
move: the actual horizontal moving offset of the character images
swipe: the horizontal moving offset on user finger swipe
angle: the character image angle between itself and the zero-point (the revolving center), in degree
]]
local function swipeToAngle(dx)
    return _angleBetween * dx / (_width / 2)
end

local function angleToMove(d)
    return _revolvingRadius * math.sin(math.rad(d))
end

local function angleToSwipe(d)
    return (_width / 2) * d / _angleBetween
end

local function normalizeAngle(d)
    return d % 360
end

-- return the calculated scale, z and y for a given character revolving angle; arguments: the revolving angle (normalized) of character
local function angleToScaleZAndY(angle)
    local factor = math.abs(math.sin(math.rad(angle)))
    local scale, z, y

    local halfScale = _minScale + (_maxScale - _minScale) / 2
    local halfZ = _minZ + (_maxZ - _minZ) / 2
    local halfY = _minCharacterY + (_maxCharacterY - _minCharacterY) / 2

    if angle > 90 and angle < 270 then
        scale = _minScale - factor * (_minScale - halfScale)
        z = _minZ - factor * (_minZ - halfZ)
        y = _maxCharacterY - factor * (_maxCharacterY - halfY)
    else
        scale = _maxScale - factor * (_maxScale - halfScale)
        z = _maxZ - factor * (_maxZ - halfZ)
        y = _minCharacterY - factor * (_minCharacterY - halfY)
    end
    scale = scale*_modelScale
    return scale, z, y
end

-- argument: callback function on character image clicked; the character sprite object is passed to it as the only 1 argument
local function createCharactersRevolver(onCharacterClick)
    local layer = SpriteLayer.create()

    layer.characters = {}
    setmetatable(layer.characters, { __mode = "v" })

    local angle = 0
    local i = _tagLock -1
    for _, v in pairs(_characters) do
        -- local sprite = SpriteLayer.create(_testBlockSize.width, _testBlockSize.height, ccc3(255, 0, 0), 255 * 0.6)
        local sprite = SpriteLayer.create(v.image)
        sprite.touchThroughTransparentStrict = false
        local x = _revolvingCenterX + angleToMove(angle) + (v.centerOffsetX or 0)

        local scale, z, y = angleToScaleZAndY(angle)
        sprite:setPosition(x, y)
        sprite:setScale(scale)
        if v.anchorPoint then
            sprite:setAnchorPoint(v.anchorPoint.x, v.anchorPoint.y)
        end
        layer:addChild(sprite, z, v.tag)
        sprite.centerOffsetX = v.centerOffsetX or 0
        table.insert(layer.characters, sprite)

        sprite.revolvingAngle = angle
        angle = angle + _angleBetween

        -- add name and lock images
        local name = CCSprite:create(v.name)
        name:setVisible(false)
        
        local _modelNameOffsetX = sprite:getContentSize().width/2+v.nameOffset.x
        local _modelNameOffsetY = sprite:getContentSize().height/2+v.nameOffset.y

        name:setPosition(_modelNameOffsetX, _modelNameOffsetY)
        name:setScale(1/_modelScale)       
        
        local lock = CCSprite:create("characters/lock.png")
        lock:setVisible(false)
        
        lock:setPosition(_modelNameOffsetX, _modelNameOffsetY-40)
        lock:setScale(1/_modelScale)
       
        i = i +1
        sprite:addChild(name, 100, _tagName)
        sprite:addChild(lock, 200, _tagLock)
    end

    -- helper functions

    -- return: character, the angle between the character and center; if character is nil, no character is centered
    layer.findCenteredCharacter = function(self)
        local minAngle = 360
        local centerCharacter = nil
        for _, v in pairs(self.characters) do
            local d = math.min(v.revolvingAngle - 0, 360 - v.revolvingAngle)
            if d < minAngle then
                minAngle = d
                centerCharacter = v
            end
        end

        return centerCharacter, minAngle
    end

    layer.toggleNameAndLock = function(self, character, onOrOff)
        character.nameShown = onOrOff

        local name = character:getChildByTag(_tagName)
        local lock = character:getChildByTag(_tagLock)
        local hideLock = true

        --加解锁控制语句
        if character:getTag() ~= 1 then
            if not onOrOff then
                hideLock = true
            else
                if character:getTag() == 2 then  
                    hideLock = GlobalObj:checkUnlockItem()
                    

                elseif character:getTag() == 3 then 
                    hideLock = GlobalObj:checkUnlockItem()
                    
                end
            end
        end

        local nameAnim = onOrOff and CCFadeIn or CCFadeOut
        local lockAnim = hideLock and CCFadeOut or CCFadeIn

        if onOrOff then
            name:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(function() name:setVisible(onOrOff) end), nameAnim:create(0.2)))
        else
            name:runAction(CCSequence:createWithTwoActions(nameAnim:create(0.2), CCCallFunc:create(function() name:setVisible(onOrOff) end)))
        end
 
        if character:getTag() ~= 1 then
            if hideLock then
                lock:runAction(CCSequence:createWithTwoActions(lockAnim:create(0.2), CCCallFunc:create(function() lock:setVisible(not hideLock) end)))
            else
                lock:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(function() lock:setVisible(not hideLock) end), lockAnim:create(0.2)))
            end
        end

        -- disabled touch when playing animation
        self.isTouchEnabled = false
        performWithDelay(self, function() self.isTouchEnabled = true end, 0.2)
    end

    -- override the touch event handlers
    layer.onTouchBegan = function(self, x, y)
        self.touchStartLocal = self:convertToNodeSpace(ccp(x, y))
        self.touchLastLocal = self.touchStartLocal
        self.touchMoveDistance = 0
        return true
    end

    layer.onTouchMoved = function(self, x, y)
        local touchCurrentLocal = self:convertToNodeSpace(ccp(x, y))
        local dx = touchCurrentLocal.x - self.touchLastLocal.x

        for _, v in pairs(self.characters) do
            v.revolvingAngle = normalizeAngle(v.revolvingAngle + swipeToAngle(dx))
            local newx = _revolvingCenterX + angleToMove(v.revolvingAngle)
            local scale, z, newy = angleToScaleZAndY(v.revolvingAngle)

            v:setPosition(newx+v.centerOffsetX, newy)
            v:setScale(scale)
            v:setZOrder(z)

            if v.nameShown and math.abs(swipeToAngle(touchCurrentLocal.x - self.touchStartLocal.x)) >= 15 then
                self:toggleNameAndLock(v, false)
            end
        end

        self.touchLastLocal = touchCurrentLocal
        self.touchMoveDistance = self.touchMoveDistance + math.abs(dx)
    end

    layer.onTouchEnded = function(self, x, y)
        -- look for the character which revolving angle is close to 0 most
        local minAngle = 360
        local centerCharacter = nil
        centerCharacter, minAngle = self:findCenteredCharacter()
 
        centerCharacter.isTouchEnabled = true  -- for touchHit test

        if minAngle > 90 then
            -- no character is in foreground
        else
            if centerCharacter:touchHit(x, y) and centerCharacter.nameShown and minAngle <= _minCharacterChosenAngle then
                -- character chosen
                AudioEngine.playEffect(config_sound_effects.common_arrow, false)

                --- check IAP
                if centerCharacter:getChildByTag(_tagLock):isVisible() then
                    --layer:getChildByTag(_tagHiddenMenu):onShop(iapCallback)
                    if layer.hiddenMenu then
                        layer.hiddenMenu:onShop(iapCallback)
                    end
                    return
                end

                layer.isTouchEnabled = false

                Utils:sharedUtils():setColorDim(centerCharacter, true)
                performWithDelay(self, function() Utils:sharedUtils():setColorDim(centerCharacter, false) end, 0.2)

                local actions = CCArray:create()
                actions:addObject(CCScaleBy:create(0.2, 1.2))
                if onCharacterClick then
                    actions:addObject(CCCallFunc:create(function() onCharacterClick(centerCharacter) end))
                end
                centerCharacter:runAction(CCSequence:create(actions))

                --- don't play character name voice over
                self.noNameVoicePlayed = true
            end

            -- auto revolve to center
            local swipe = angleToSwipe(minAngle)

            if centerCharacter.revolvingAngle > 0 and centerCharacter.revolvingAngle < 90 then
                swipe = -swipe
            end

            self.isTouchEnabled = false
            self.revolveAnimationDuration = _autoCenterAnimationDuration
            self.doingAutoCenter = true
            self.centerOffset = swipe
            self.totalRevolveAngle = minAngle
            self.doing360AutoRevolving = false
        end
    end

    layer.tick = function(self)
        if self.doingAutoCenter then
            if self.framesToGo == nil then
                self.framesToGo = self.revolveAnimationDuration * 60  -- 60 frames per second
                self.swipePerFrame = self.centerOffset / self.framesToGo
            end

            if self.framesToGo > 0 then
                if not self.doing360AutoRevolving then
                    local c, _ = self:findCenteredCharacter()

                    if c.revolvingAngle >= 358 or c.revolvingAngle <= 2 then
                        -- already "centered", don't over revolve
                        self.framesToGo = 0
                        return
                    end
                end

                self:onTouchBegan(0, 0)
                self:onTouchMoved(self.swipePerFrame, 0)
                self.framesToGo = self.framesToGo - 1
            else
                self.isTouchEnabled = true
                self.doingAutoCenter = false
                self.framesToGo = nil

                local c, _ = self:findCenteredCharacter()
                if not c.nameShown then
                    self:toggleNameAndLock(c, true)
                end

                if not self.noNameVoicePlayed then
                    AudioEngine.playEffect(_characters[c:getTag()].sound, false)
                    cclog("----------Center model tag = %d----------",c:getTag())
                else
                    self.noNameVoicePlayed = false
                end
            end
        end
    end

    layer.revolve360 = function(self, duration)
        self.isTouchEnabled = false
        self.revolveAnimationDuration = duration
        self.doingAutoCenter = true
        self.centerOffset = angleToSwipe(360)
        self.doing360AutoRevolving = true
    end

    layer.onEnter = function(self)
        cclog("register characters-revolver tick callback")
        if not self.scheduleTickHandle then
            self.scheduleTickHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:tick() end, 0, false)
        end

        SpriteLayer.superClass.onEnter(self)
    end

    layer.onExit = function(self)
        cclog("unregister characters-revolver tick callback")
        if self.scheduleTickHandle then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleTickHandle)
            self.scheduleTickHandle = nil
        end

        SpriteLayer.superClass.onExit(self)
    end

    function createParticle()
        local particleLayer = CCLayer:create()
        -- 1
        local emitter = CCParticleSystemQuad:create("particles/heart.plist")
        emitter:setPosition(__G__canvasCenter.x, __G__canvasCenter.y)
        particleLayer:addChild(emitter)

        -- -- 2
        -- local emitter2 = CCParticleSystemQuad:create(__G__iOSValue2("particles/snow2.plist","particles/snow2-ipad.plist"))
        -- emitter2:setPosition(__G__canvasCenter.x, __G__canvasCenter.y)
        -- particleLayer:addChild(emitter2)

        --  -- 3
        --  local emitter3 = CCParticleSystemQuad:create(__G__iOSValue2("particles/snow3.plist","particles/snow3-ipad.plist"))
        --  emitter3:setPosition(__G__canvasCenter.x, __G__canvasCenter.y)
        --  particleLayer:addChild(emitter3)

        --  -- 4
        --  local emitter4 = CCParticleSystemQuad:create(__G__iOSValue2("particles/snow4.plist","particles/snow4-ipad.plist"))
        --  emitter4:setPosition(__G__canvasCenter.x, __G__canvasCenter.y)
        --  particleLayer:addChild(emitter4)

        return particleLayer
    end

    -- layer:addChild(createParticle(),8)

    -- add a hidden menu object for IAP
    hiddenMenu = config_menu.createNoBannerMenu()
    hiddenMenu.needHideBannerAdOnPopup = false
    hiddenMenu.homeSceneCreateFunc = scene_home
    --layer:addChild(hiddenMenu, -1000, _tagHiddenMenu)
    hiddenMenu:setVisible(false)
    layer.hiddenMenu = hiddenMenu
    hiddenMenu:retain()

    iapCallback = function(type_, success, iapIndex)
                            if success then
                                local _parent = layer:getParent()
                                if _parent and _parent.updateShopMenuState then
                                    _parent:updateShopMenuState()
                                end

                                local _centerCharacter = layer:findCenteredCharacter()
                                cclog("CenterCharacter tag:%i,iapIndex:%i",_centerCharacter:getTag(),iapIndex)
                                if GlobalObj:checkUnlockItem() then
                                    _centerCharacter:getChildByTag(_tagLock):setVisible(false)
                                    
                                end
                            end
                        end

    layer.iapCallback = iapCallback

    return layer
end



_G["config_charactersrevolver"] = {
    createCharactersRevolver = createCharactersRevolver,
}
