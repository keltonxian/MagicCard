module(..., package.seeall)

-- ============== CONSTANT START =================
local TAG_T_BG       = 10
local TAG_T_T1       = 11
local TAG_T_T2       = 12
local TAG_T_T3       = 13
local TAG_T_T4       = 14
local TAG_T_T5       = 15
local TAG_T_M1       = 16
local TAG_T_M2       = 17
local TAG_T_H1       = 18
local TAG_T_H2       = 19
local TAG_T_PARTICLE = 20
local TAG_P_1        = 21
local TAG_P_2        = 22
local TAG_P_3        = 23
local TAG_MODEL_1    = 31
local TAG_MODEL_2    = 32
local TAG_MODEL_3    = 33
local TAG_MODEL_4    = 34
local TAG_NAME_1     = 41
local TAG_NAME_2     = 42
local TAG_NAME_3     = 43
local TAG_NAME_4     = 44
local TAG_LOCK_1     = 51
local TAG_LOCK_2     = 52
local TAG_LOCK_3     = 53
local TAG_LOCK_4     = 54
local TAG_BTN_LIKE   = 101
local TAG_BTN_MUTE   = 102
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local listSoundHome = ConfigSound.listSoundHome
-- declare layer name
local LayerMain = nil
local LayerBackground = nil
local LayerModel = nil
local s_layerMain = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
local function iapCallback(_type, success, iapIndex)
	return s_layerMain:iapCallback(_type, success, iapIndex)
end

local function showJelly(sprite)
	local s = sprite:getScale()
	local array = CCArray:create()
	action = CCScaleTo:create(0.8, s*1.06, s*0.97)
	array:addObject(action)
	action = CCScaleTo:create(0.6, s, s)
	array:addObject(action)
	action = CCRepeatForever:create(CCSequence:create(array))
	sprite:runAction(action)
end

local function actionPopShow(sprite, delay, eff)
	delay = delay or 0
	local scale = sprite:getScale()
	sprite:setScale(scale * 1.2)
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCCallFunc:create(function()
		sprite:setVisible(true)
	end))
	array:addObject(CCScaleTo:create(0.2, scale * 1.5))
	array:addObject(CCScaleTo:create(0.1, scale * 0.8))
	array:addObject(CCScaleTo:create(0.1, scale * 1.1))
	array:addObject(CCScaleTo:create(0.1, scale))
	if eff == "jelly" then
		array:addObject(CCCallFunc:create(function()
			showJelly(sprite)
		end))
	end
	sprite:runAction(CCSequence:create(array));
end

local function actionFallDown(sprite, delay)
	delay = delay or 0
	local offset = 400
	local bounce = 30
	local y = sprite:getPositionY()
	sprite:setPositionY(y + offset)
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCCallFunc:create(function()
		sprite:setVisible(true)
	end))
	array:addObject(CCMoveBy:create(0.5, ccp(0, -offset - bounce)))
	array:addObject(CCMoveBy:create(0.2, ccp(0, bounce)))
	sprite:runAction(CCSequence:create(array));
end

local function actionMoveFrom(sprite, from, delay)
	delay = delay or 0
	local bounce = 15
	local x = sprite:getPositionX()
	local y = sprite:getPositionY()
	local offsetx = x > from.x and bounce or -bounce
	local offsety = y > from.y and bounce or -bounce
	sprite:setPosition(ccp(from.x, from.y))
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCCallFunc:create(function()
		sprite:setVisible(true)
	end))
	array:addObject(CCMoveTo:create(0.5, ccp(x + offsetx, y + offsety)))
	array:addObject(CCMoveBy:create(0.2, ccp(-offsetx, -offsety)))
	sprite:runAction(CCSequence:create(array));
end
-- ============== FUNCTION END   =================

-- ============== SCENE START =================
SceneHome = SceneHome or class("SceneHome", Scene)
SceneHome.res_flag = "SceneHome"

function SceneHome:ctor(...)
	self:initData()
	local pLayerMain = LayerMain.new()
	s_layerMain = pLayerMain
	self:addChild(pLayerMain)
end

function SceneHome:initData()
	GlobalObj:initGame()
end
-- ============== SCENE END   =================

-- ============== LAYER MAIN START =================
LayerMain = class("LayerMain", 
	function(...)
		local obj = Layer.create()
		obj._layerBackground = nil
		obj._layerMenu = nil
		return obj
	end
)
LayerMain.__index = LayerMain

function LayerMain:ctor(...)
	--self:layout({})
	local layer = nil
	
	-- layer background
	layer = LayerBackground.new()
	self:addChild(layer, -999)
	layer.touchThroughTransparent = true
	self:addToTouchResponders(layer)
	self._layerBackground = layer

	-- layer menu
	layer = self:initMenu()
	if layer then
		local canSee = false
		if canSee then
			self:addChild(layer, 1003)
			self:addToTouchResponders(layer)
			layer:setTouchPriority(20)
		else
			self:addChild(layer, -1000)
		end
		self._layerMenu = layer
	end

	self:enableTouchDispatching(true)
	self:enableKeypadHandling(true)
end

function LayerMain:onEnter(...)
	AudioEngine.stopMusic(true)
	AudioEngine.playMusic(listSoundHome.bgMusic, true)

	performWithDelay(self, function()
		AudioEngine.playEffect(listSoundHome.onEnterEffect, false)
	end, 2.2)
	
	-- kelton mark --
	game_app:showNewsBlast()
	--[[
	local adsManager = AdsPopupManager:sharedManager()
	adsManager:hideBannerAd()
	if __G__isHomeInit then
		performWithDelay(self, function()
			adsManager:showNewsBlast()
			GlobalObj:removeAllADs()
		end, 1.5)
	end
	]]--
	-- kelton mark --
end

function LayerMain:onExit(...)
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function LayerMain:initMenu(...)
	local layer = config_menu:createNoBannerMenu()
	return layer
end

function LayerMain:iapCallback(_type, success, iapIndex)
	if success then
		local bg = self._layerBackground
		bg:updateBtn()
		if GlobalObj:checkUnlockItem() then
			local model = bg._layerModel
			local list = { TAG_LOCK_1, TAG_LOCK_2, TAG_LOCK_3, TAG_LOCK_4 }
			for i = 1, #list do
				local tag = list[i]
				local s = model:getChildByTag(tag)
				if nil ~= s then
					s:setVisible(false)
				end
			end
		end
	end
end
-- ============== LAYER MAIN END   =================

-- ============== LAYER BACKGROUND START =================
LayerBackground = class("LayerBackground",
	function(...)
		local obj = Layer.create()
		obj._layerModel = nil
		return obj
	end
)
LayerBackground.__index = LayerBackground

function LayerBackground:onEnter(...)
	self:titleAction()
end

function LayerBackground:onExit(...)
end

function LayerBackground:ctor(...)
	ButtonLayer.defaultTouchSound = config_sound_effects.common_menu_item_click
	self:layout({
		{
			x = 0,
			y = 0,
			z = -1,
			tag = 0,
			touch = -1,
			class = SpriteLayer,
			image = __G__iOSValueP("home/", "i4.png", "i5.png", "ipad.png"),
		},
		{
			x = __G__canvasSize.width/2,
			y = __G__iOSValue(765, 900, 780)+90,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 100,
			tag = TAG_T_BG,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t0.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue2(200, 200),
			y = __G__iOSValue(765, 900, 780)+80,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 101,
			tag = TAG_T_M1,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/x0.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue2(200, 200),
			y = __G__iOSValue(765, 900, 780)+80,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 103,
			tag = TAG_T_H1,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/x1.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue2(200, 200),
			y = __G__iOSValue(765, 900, 780)+80,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 104,
			tag = TAG_T_H2,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/x3.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue2(200, 200),
			y = __G__iOSValue(765, 900, 780)+80,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 106,
			tag = TAG_T_M2,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/x4.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(0, 0, 0) - 87,
			y = __G__iOSValue(765, 900, 790) + 115,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 111,
			tag = TAG_T_T1,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t1.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(0, 0, 20) + 35,
			y = __G__iOSValue(765, 900, 790) + 115,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 111,
			tag = TAG_T_T2,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t2.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(0, 0, 50) + 180,
			y = __G__iOSValue(765, 900, 790) + 115,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 111,
			tag = TAG_T_T3,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t3.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(0, 0, -6) - 40,
			y = __G__iOSValue(765, 900, 770) + 40,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 111,
			tag = TAG_T_T4,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t4.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(0, 0, 43) + 160,
			y = __G__iOSValue(765, 900, 770) + 40,
			adjust_pos = ANCHOR_CENTER_CENTER,
			z = 111,
			tag = TAG_T_T5,
			scale = __G__iOSValue2(0.8, 1.0),
			touch = -1,
			visible = false,
			class = SpriteLayer,
			image = "home/t5.png",
		},
		{
			x = __G__AndroidOriOSValue(420, 420, 545, 310, 310, 430),
			y = __G__iOSValue(4, 10, 10),
			z = 11,
			tag = 25,
			touch = 100,
			class = ButtonLayer,
			visible =(not __G__isAndroid) and (not GlobalObj:checkHideShopButton()),
			image = "Button/3.png",
			attributes = {
				clickHandler = function(s)
                    AudioEngine.playEffect(config_sound_effects.common_popup_open, false)
					local menu = s_layerMain._layerMenu
					if menu then
						menu:onShop(iapCallback)
					end
				end
			},
		},
		{
			x = __G__AndroidOriOSValue(310, 310, 430, 200, 200, 320),
			y = __G__iOSValue(4, 10, 10),
			z = 11,
			tag = TAG_BTN_MUTE,
			touch = 100,
			class = ButtonLayer,
			image = __G__isSoundMute and "Button/6.png" or "Button/7.png",
			attributes = {
				clickHandler = function(s)
                    --AudioEngine.playEffect(config_sound_effects.common_menu_item_click, false)
					__G__soundMute(not __G__isSoundMute)
					local f = __G__isSoundMute and "Button/6.png" or "Button/7.png"
					s:setStateSprite(f, "normal")
				end
			},
		},
		--[[
		{
			x = __G__AndroidOriOSValue(200, 200, 315, 90, 90, 210),
			y = __G__iOSValue(4,10,10),
			z = 11,
			tag = TAG_BTN_LIKE,
			touch = 100,
			class = ButtonLayer,
			image = "Button/12.png",
			attributes = {
				clickHandler = function(s)
					performWithDelay(s, function()
						--AudioEngine.playEffect(config_sound_effects.common_menu_item_click, false)
						local url = "https://www.facebook.com/pages/Beauty-Girls-Inc/101754906838836?fref=ts"
						Utils:sharedUtils():openURL(url)
					end, 0.2)
				end
			},
		},
		]]--
	})
	ButtonLayer.defaultTouchSound = nil

	
	self:initMoreGame()
	self:updateBtn()

	local layer = LayerModel.new()
	layer.touchThroughTransparent = true
	self:addChild(layer, 10)
	self:addToTouchResponders(layer)
	self._layerModel = layer

	self:starParticle()
	--self:fallParticle()

	--self:resetBtnPosition()
end

function LayerBackground:updateBtn()
	if __G__isAndroid or GlobalObj:checkHideShopButton() then
		local s, x
		s = self:getChildByTag(TAG_BTN_MUTE)
		if nil ~= s then
			x = s:getPositionX()
			x = x + __G__AndroidOriOSValue(110, 110, 115, 110, 110, 110)
			s:setPositionX(x)
		end
		--[[
		s = self:getChildByTag(TAG_BTN_LIKE)
		x = s:getPositionX()
		x = x + __G__AndroidOriOSValue(110, 110, 115, 110, 110, 110)
		s:setPositionX(x)
		]]--
	end
end

function LayerBackground:initMoreGame()
	local btn = MoreGamesUI.createButton(__G__moreGamesData, false)
	btn:setAnchorPoint(ccp(0, 0))
	btn:setTouchPriority(30)
	btn:setPosition(__G__iOSValue(524, 525, 653), __G__iOSValue(4, 10, 10))
	self:addChild(btn, 11, 3)
	self:addToTouchResponders(btn)
end

function LayerBackground:starParticle()
	local pLayer = CCLayer:create()
	local title = self:getChildByTag(TAG_T_BG)
	local size = title:getContentSize()
	local starLight = CCParticleSystemQuad:create("particles/starlight.plist")
	starLight:setPosition(ccp(size.width/2, size.height/2))
	pLayer:addChild(starLight, 10, TAG_P_1)

	local littleStar = CCParticleSystemQuad:create("particles/littlestar.plist")
	littleStar:setPosition(ccp(size.width/2, size.height/2))
	pLayer:addChild(littleStar, 10, TAG_P_2)

	--title:addChild(pLayer, 110)
	title:addChild(pLayer, 100, TAG_T_PARTICLE)
end

function LayerBackground:fallParticle()
	local pLayer = CCLayer:create()
	local title = self:getChildByTag(TAG_T_BG)
	local size = title:getContentSize()
	local x, y = title:getPosition()
	local p1 = CCParticleSystemQuad:create("particles/snow1.plist")
	p1:setPosition(ccp(x, y))
	pLayer:addChild(p1, 10, TAG_P_1)
	p1:stopSystem()

	--[[
	local p2 = CCParticleSystemQuad:create("particles/snow2.plist")
	p2:setPosition(ccp(size.width/2, size.height/2))
	pLayer:addChild(p2, 10, TAG_P_2)
	p2:stopSystem()

	local p3 = CCParticleSystemQuad:create("particles/snow3.plist")
	p3:setPosition(ccp(size.width/2, size.height/2))
	pLayer:addChild(p3, 10, TAG_P_3)
	p3:stopSystem()
	]]--

	self:addChild(pLayer, 100, TAG_T_PARTICLE)
end

function LayerBackground:titleAction()
	performWithDelay(self, function()
		local t
		-- bg
		t = self:getChildByTag(TAG_T_BG)
		actionPopShow(t, 0)
		-- letter
		t = self:getChildByTag(TAG_T_T1)
		actionFallDown(t, 0.2)
		t = self:getChildByTag(TAG_T_T2)
		actionFallDown(t, 0.2)
		t = self:getChildByTag(TAG_T_T3)
		actionFallDown(t, 0.2)
		t = self:getChildByTag(TAG_T_T4)
		actionFallDown(t, 0)
		t = self:getChildByTag(TAG_T_T5)
		actionFallDown(t, 0)
		-- mail
		t = self:getChildByTag(TAG_T_M1)
		actionMoveFrom(t, ccp(-400, __G__canvasSize.height/4*3), 0.1)
		t = self:getChildByTag(TAG_T_M2)
		actionMoveFrom(t, ccp(-400, __G__canvasSize.height/4*3), 0.1)
		-- heart
		t = self:getChildByTag(TAG_T_H1)
		actionPopShow(t, 0.6, "jelly")
		t = self:getChildByTag(TAG_T_H2)
		actionPopShow(t, 0.7, "jelly")
		-- show particle
		--t = self:getChildByTag(TAG_T_PARTICLE)
		t = self:getChildByTag(TAG_T_BG):getChildByTag(TAG_T_PARTICLE)
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.3))
		array:addObject(CCCallFunc:create(function()
			t:getChildByTag(TAG_P_1):resetSystem()
			t:getChildByTag(TAG_P_2):resetSystem()
			--t:getChildByTag(TAG_P_3):resetSystem()
		end))
		t:runAction(CCSequence:create(array));
	end, 2.5)
end

-- ============== LAYER BACKGROUND END   =================

-- ============== LAYER MODEL START =================
LayerModel = class("LayerModel",
	function(...)
		local obj = Layer.create()
		obj._layerParticle = nil
		obj.list_mode = nil
		return obj
	end
)
LayerModel.__index = LayerModel

function LayerModel:onEnter(...)
	self:modelAction(TAG_MODEL_1, ccp(1030, 0), ccp(-30, 0), 1.5)
	self:modelAction(TAG_MODEL_2, ccp(-830, 0), ccp(30, 0), 2.0)
	self:modelAction(TAG_MODEL_3, ccp(830, 0), ccp(-30, 0), 0.2)
	self:modelAction(TAG_MODEL_4, ccp(-1030, 0), ccp(30, 0), 0.7)
	
	if GlobalObj:checkUnlockItem() then
		local l = { TAG_LOCK_1, TAG_LOCK_2, TAG_LOCK_3, TAG_LOCK_4 }
		for i = 1, #l do
			local lock = self:getChildByTag(l[i])
			if nil ~= lock then
				lock:setVisible(false)
			end
		end
	end
end

function LayerModel:onExit(...)
end

function LayerModel:ctor()
	self.list_model = {
		{
			x = __G__canvasSize.width/2 - __G__iOSValue(100, 100, 100) - 1000,
			y = __G__iOSValue(-450, -330, -400),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 11,
			tag = TAG_MODEL_1,
			image = "home/1.png",
			touch = 10,
			cid = 1, -- lily
			sound = listSoundHome.model[1],
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(170, 170, 230) + 800,
			y = __G__iOSValue(-320, -200, -400),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 5,
			tag = TAG_MODEL_2,
			image = "home/2.png",
			touch = 5,
			cid = 2, -- sophia
			sound = listSoundHome.model[2],
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue(230, 230, 280) - 800,
			y = __G__iOSValue(-320, -200, -280),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 5,
			tag = TAG_MODEL_3,
			image = "home/3.png",
			touch = 5,
			cid = 3, -- riley
			sound = listSoundHome.model[3],
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(60, 60, 110) + 1000,
			y = __G__iOSValue(-240, -120, -280),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 4,
			tag = TAG_MODEL_4,
			image = "home/4.png",
			touch = 3,
			cid = 4, -- alice
			sound = listSoundHome.model[4],
		},
	}

	local lmodel = {}
	for i = 1, #self.list_model do
		local d = self.list_model[i]
		local l = {
			x = d.x,
			y = d.y,
			adjust_pos = d.adjust_pos,
			z = d.z,
			tag = d.tag,
			image = d.image,
			touch = d.touch,
			class = SpriteLayer,
			attributes = {
				--touchHitScaleX = 0.6,
				--touchHitScaleY = 0.8,
				touchThroughTransparentStrict = true,
				touchBeganHandler = function(s, x, y)
					self:setEmitter(x, y)
					self:changeNameState(d.tag)
				end
			},
		}
		table.insert(lmodel, l)
	end
	self:layout(lmodel)

	self:layout({
		{
			x = __G__canvasSize.width/2 - __G__iOSValue(100, 100, 100),
			y = __G__iOSValue(100, 220, 200),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 50,
			ignore_half_size = true,
			tag = TAG_NAME_1,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "home/1_lily.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(170, 170, 230),
			y = __G__iOSValue(260, 380, 200),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 50,
			ignore_half_size = true,
			tag = TAG_NAME_2,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "home/2_sophia.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(170, 170, 230),
			y = __G__iOSValue(210, 330, 150),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 51,
			ignore_half_size = true,
			tag = TAG_LOCK_2,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "tools/lock.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue(210, 210, 270),
			y = __G__iOSValue(260, 380, 280),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 50,
			ignore_half_size = true,
			tag = TAG_NAME_3,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "home/3_riley.png",
		},
		{
			x = __G__canvasSize.width/2 - __G__iOSValue(210, 210, 270),
			y = __G__iOSValue(210, 330, 230),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 51,
			ignore_half_size = true,
			tag = TAG_LOCK_3,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "tools/lock.png",
		},
		{
			x = __G__canvasSize.width/2 + __G__iOSValue(60, 60, 110),
			y = __G__iOSValue(400, 520, 280),
			adjust_pos = ANCHOR_CENTER_BOTTOM,
			z = 50,
			ignore_half_size = true,
			tag = TAG_NAME_4,
			touch = -1,
			scale = 0.0,
			class = SpriteLayer,
			image = "home/4_alice.png",
		},
	})

	self:createTapParticle()
end

function LayerModel:createTapParticle()
	local pLayer = CCLayer:create()
	--[[
	local blue = CCParticleSystemQuad:create("particles/blue-bubble.plist")
	blue:setPosition(ccp(0, -30))
	pLayer:addChild(blue, 13, 1)
	]]--
	local pink = CCParticleSystemQuad:create("particles/pink-bubble.plist")
	pink:setPosition(ccp(0, -30))
	pLayer:addChild(pink, 13, 2)
	--[[
	local green = CCParticleSystemQuad:create("particles/green-bubble.plist")
	green:setPosition(ccp(0, -30))
	pLayer:addChild(green, 13, 3)
	local purple = CCParticleSystemQuad:create("particles/purple-bubble.plist")
	purple:setPosition(ccp(0, -30))
	pLayer:addChild(purple, 13, 4)
	]]--

	--blue:stopSystem()
	pink:stopSystem()
	--green:stopSystem()
	--purple:stopSystem()

	self:addChild(pLayer, 130)
	self._layerParticle = pLayer
end

function LayerModel:setEmitter(x, y)
	local l = self._layerParticle
	if nil == l then return; end
	l:setPosition(self:convertToNodeSpace(ccp(x, y)))
	--l:getChildByTag(1):resetSystem()
	l:getChildByTag(2):resetSystem()
	--l:getChildByTag(3):resetSystem()
	--l:getChildByTag(4):resetSystem()
end

function LayerModel:changeNameState(tag)
	AudioEngine.playEffect("sfx/common/952play.mp3", false)
	for i = 1, #(self.list_model or {}) do
		local d = self.list_model[i]
		local model = self:getChildByTag(d.tag)
		local name = self:getChildByTag(d.tag-TAG_MODEL_1+TAG_NAME_1)
		local lock = self:getChildByTag(d.tag-TAG_MODEL_1+TAG_LOCK_1)
		if d.tag == tag then
			if name:getScale() > 0 then
				self.isTouchEnabled = false
				performWithDelay(self, function()
					self.isTouchEnabled = true
					GlobalObj.m_homeToMap = true
					GlobalObj.m_objGameData:setModelID1(d.cid)
					if nil ~= lock then
						if not GlobalObj:checkUnlockItem() then
							s_layerMain._layerMenu:onShop(iapCallback)
							return
						end
					end
					print("=========== go next scene ===============")
					game_app:switchWithScene(SceneMap, { adType = "CBCP" })
				end, 1.0)
			else
				performWithDelay(self, function()
					AudioEngine.playEffect(d.sound)
				end, 0.5)
				performWithDelay(name, function()
					name:runAction(CCScaleTo:create(0.3, 1.0))
				end, 0.2)
				if nil ~= lock then
					performWithDelay(lock, function()
						lock:runAction(CCScaleTo:create(0.3, 1.0))
					end, 0.2)
				end
			end
		else
			if name:getScale() > 0 then
				performWithDelay(name, function()
					name:runAction(CCScaleTo:create(0.3, 0.0))
				end, 0.2)
			end
			if nil ~= lock and lock:getScale() > 0 then
				performWithDelay(lock, function()
					lock:runAction(CCScaleTo:create(0.3, 0.0))
				end, 0.2)
			end
		end
	end
end

function LayerModel:modelAction(tag, pos1, pos2, time)
	performWithDelay(self, function()
		local character = self:getChildByTag(tag)
		character.touchThroughTransparentStrict = true
		local array = CCArray:create()
		array:addObject(CCMoveBy:create(0.5, pos1))
		array:addObject(CCMoveBy:create(0.2, pos2))
		character:runAction(CCSequence:create(array));
	end, time)
end
-- ============== LAYER MODEL END   =================

-- ============== FUNCTION START =================

-- ============== FUNCTION END   =================


_G["SceneHome"] = SceneHome

