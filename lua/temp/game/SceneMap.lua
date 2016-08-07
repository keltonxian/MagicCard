module(..., package.seeall)

-- ============== CONSTANT START =================
local TAG_SPA           = 11
local TAG_MAKE_UP       = 12
local TAG_DRESS_UP      = 13
local TAG_PARTNER_CLOSET= 14
local TAG_SHOP          = 15
local TAG_CHOCOLATE_SHOP= 16
local TAG_PARK          = 17
local TAG_RESTAURANT    = 18
local TAG_CARD_SHOP     = 19

local TAG_SUB_NODE      = 31
local TAG_BTN_SHOP      = 32
local TAG_BTN_HOME      = 33
local TAG_BTN_MORE      = 34

local TAG_ACTION_JUMP   = 99
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local listSoundMap = ConfigSound.listSoundMap
local v_layoutData = nil
-- declare layer name
local LayerMain = nil
local LayerBackground = nil
local LayerEntry = nil
local s_layerMain = nil
local v_soundWelcome = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
local function iapCallback(_type, success, iapIndex)
	return s_layerMain:iapCallback(_type, success, iapIndex)
end
-- ============== FUNCTION END   =================

-- ============== SCENE START =================
SceneMap = SceneMap or class("SceneMap", Scene)
SceneMap.res_flag = "SceneMap"

function SceneMap:ctor(...)
	self:initData()
	local pLayerMain = LayerMain.new()
	s_layerMain = pLayerMain
	self:addChild(pLayerMain)
end

function SceneMap:initData()
	v_layoutData = v_layoutData or GlobalObj:getLayoutData("LAYOUT_MAP")
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
	self:layout({
		{
			x = __G__iOSValue(29, 29, 29),
			y = __G__visibleSize.height - 120,
			z = 11,
			tag = TAG_BTN_HOME,
			touch = 12,
			class = ButtonLayer,
			image = "Button/4.png",
			attributes = {
				enableOnTouchAnimation = true,
				minClickInterval = 1,
				tapHandler = function(s)
                    AudioEngine.playEffect(config_sound_effects.common_menu_item_click, false)
					self._layerMenu:onHome()
				end
			},
		},
		{
			x = __G__iOSValue(135, 135, 145),
			y = __G__visibleSize.height - 120,
			z = 11,
			tag = TAG_BTN_SHOP,
			touch = 12,
			--visible =(not __G__isAndroid) and (not GlobalObj:checkHideShopButton()),
			class = ButtonLayer,
			image = "Button/3.png",
			attributes = {
				enableOnTouchAnimation = true,
				minClickInterval = 1,
				tapHandler = function(s)
                    AudioEngine.playEffect(config_sound_effects.common_popup_open, false)
					self._layerMenu:onShop(iapCallback)
				end
			},
		},
	})

	local layer = nil
	
	-- layer background
	layer = LayerBackground.new()
	self:addChild(layer, -999)
	layer.touchThroughTransparent = true
	layer:setTouchPriority(10)
	self:addToTouchResponders(layer)
	self._layerBackground = layer

	self._layerEntry = self._layerBackground._layerEntry

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

	self:initMoreGame()

	self:updateBtn()

	self:enableTouchDispatching(true)
	self:enableKeypadHandling(true)
end

function LayerMain:onEnter(...)
	-- kelton mark --
	--AdsPopupManager:sharedManager():hideBannerAd()
	AdsManager:getInstance():setVisiable(kTypeBannerAds, false)
	-- kelton mark --

	AudioEngine.stopMusic(true)
	AudioEngine.playMusic(listSoundMap.bgMusic, true)

	GlobalObj.m_showModel2 = false

	local spa = self._layerBackground._layerEntry:getChildByTag(TAG_SPA)
	if spa and game_app._fristtimeIntoMap then
		performWithDelay(self, function()
			v_soundWelcome = AudioEngine.playEffect(listSoundMap.onEnterEffect, false)
		end, 1)
	    print("-----------------------------------------_spa")
	    -- local brandSprite = parent:getChildByTag(_brandTag)
	    local pointX = spa:getPositionX()
	    local pointY = spa:getPositionY()
	    local action = CCRepeatForever:create(CCJumpBy:create(0.5, ccp(0,0), 20,1))
		action:setTag(TAG_ACTION_JUMP)
		spa:runAction(action)
	    game_app._fristtimeIntoMap = false
	end
end

function LayerMain:onExit(...)
	if nil ~= v_soundWelcome then
		AudioEngine.stopEffect(v_soundWelcome)
	end
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function LayerMain:initMenu(...)
	local layer = config_menu:createNoBannerMenu()
	layer.homeSceneCreateFunc = SceneHome
	return layer
end

function LayerMain:iapCallback(_type, success, iapIndex)
	if success then
		self:updateBtn()
	end
end

function LayerMain:updateBtn()
	if __G__isAndroid or GlobalObj:checkHideShopButton() then
		local btn = self:getChildByTag(TAG_BTN_SHOP)
		if nil ~= btn then
			self:removeFromTouchResponders(btn)
			btn:removeFromParentAndCleanup(true)
		end
		btn = self:getChildByTag(TAG_BTN_MORE)
		if nil ~= btn then
			btn:setPositionX(__G__iOSValue(135, 135, 145))
		end

		local _layerEntry = self._layerBackground._layerEntry
		if nil ~= _layerEntry then
			btn = _layerEntry:getChildByTag(TAG_SHOP)
			if nil ~= btn then
				_layerEntry:removeFromTouchResponders(btn)
				btn:removeFromParentAndCleanup(true)
			end
		end
	end
end

function LayerMain:initMoreGame()
	local btn = MoreGamesUI.createButton(__G__moreGamesData, false)
	local x = __G__iOSValue(240, 240, 265)
	local y = __G__visibleSize.height - 120
	--[[
	if __G__isAndroid or GlobalObj:checkHideShopButton() then
		x = __G__iOSValue(135, 135, 145)
		y = __G__visibleSize.height - 120
	end
	]]--
	btn:setAnchorPoint(ccp(0, 0))
	btn:setTouchPriority(30)
	btn:setPosition(ccp(x, y))
	self:addChild(btn, 11, TAG_BTN_MORE)
	self:addToTouchResponders(btn)
end
-- ============== LAYER MAIN END   =================

-- ============== LAYER BACKGROUND START =================
LayerBackground = class("LayerBackground",
	function(...)
		local obj = Layer.create()
		obj._layerEntry = nil
		return obj
	end
)
LayerBackground.__index = LayerBackground

function LayerBackground:onEnter(...)
end

function LayerBackground:onExit(...)
end

function LayerBackground:ctor(...)
	ButtonLayer.defaultTouchSound = config_sound_effects.commmon_menu_item_click
	local key = __G__iOSValue("i4", "i5", "ipad")
	local fname = string.format("map/%s/map_%s", key, key) 
	self:layout({
		{
			x = 0,
			y = 0,
			z = -1,
			tag = 111,
			touch = -1,
			class = SpriteLayer,
			image = string.format("%s.png", fname),
		},
	})

	-- layer entry
	layer = LayerEntry.new()
	self:addChild(layer, 1)
	layer.touchThroughTransparent = true
	layer:setTouchPriority(10)
	self:addToTouchResponders(layer)
	self._layerEntry = layer

	ButtonLayer.defaultTouchSound = nil

	self:fallParticle()
end

function LayerBackground:fallParticle()
	local pLayer = CCLayer:create()
	local x = __G__canvasOrigin.x + __G__canvasSize.width/2
	local y = __G__canvasOrigin.y + __G__canvasSize.height
	local p1 = CCParticleSystemQuad:create("particles/flower_drop2.plist")
	p1:setPosition(ccp(x, y))
	pLayer:addChild(p1)
	--p1:stopSystem()

	self:addChild(pLayer, 100)
end
-- ============== LAYER BACKGROUND END   =================

-- ============== LAYER ENTRY START =================
LayerEntry = class("LayerEntry",
	function(...)
		local obj = Layer.create()
		obj._layerParticle = nil
		return obj
	end
)
LayerEntry.__index = LayerEntry

function LayerEntry:onEnter(...)
end

function LayerEntry:onExit(...)
end

function LayerEntry:ctor(...)
	Helper:set_debug_func_SpriteLayer_setSprite()

	local dtype = __G__iOSValue("i4", "i5", "ipad")
	local lkey = { 
		-- key, tag, name png, name x, name y
		{ "SPA", TAG_SPA, "SPA.png", 20, 220, "1.png" },
		{ "Makeup", TAG_MAKE_UP, "Makeup.png", 0, 190, "2.png" },
		{ "Dress up", TAG_DRESS_UP, "Dress up.png", -30, 190, "3.png" },
		{ "Partner Closet", TAG_PARTNER_CLOSET, "Partner Closet.png", -50, 120, 
		  "5.png" },
		{ "Chocolate Shop", TAG_CHOCOLATE_SHOP, "Chocolate Shop.png", -40, 150, 
		  "6.png", sceneID=1 },
		{ "Park", TAG_PARK, "Park.png", 40, 140, "8.png", sceneID=2 },
		{ "Restaurant", TAG_RESTAURANT, "Restaurant.png", -50, 160, "9.png", 
		  sceneID=3 },
		{ "Card Shop", TAG_CARD_SHOP, "Card Shop.png", -20, 120, "4.png" },
	}
	if not __G__isAndroid and not GlobalObj:checkHideShopButton() then
		table.insert(lkey, { "Shop", TAG_SHOP, "Shop.png", 0, 165, "7.png" })
	end
	local list = {}
	for i = 1, #lkey do
		local d = lkey[i]
		local key = d[1]
		table.insert(list, {
			data = v_layoutData[key],
			tag = d[2],
			image = string.format("map/%s/%s", dtype, d[3]),
			sound = listSoundMap[key],
			sceneID = d.sceneID,

			subNode = {
				x = d[4],
				y = d[5],
				scale = 1,
				image = string.format("map/%s", d[6]),
			},
		})
	end
	local list_layout = {}
	for i = 1, #list do
		local d = list[i]
		local data = d.data
		local item = {}
		item.x = data.x - data.width/2
		item.y = data.y - data.height/2
		item.z = 1
		item.tag = d.tag
		item.scale = d.scale or 1
		item.touch = 11
		item.class = SpriteLayer
		item.image = d.image
		item.visible = d.visible
		item.opacity = d.opacity or 1

		if d.subNode then
			local sn = d.subNode
			local sub = {}
			sub.x = sn.x
			sub.y = sn.y
			sub.z = 1
			sub.tag = TAG_SUB_NODE
			sub.touch = item.touch or -1
			sub.class = SpriteLayer
			sub.image = sn.image
			sub.scale = (sn.scale or 1)/item.scale

			sub.attributes = {
				touchBeganHandler = function(s, x, y)
					return s:getParent().touchBeganHandler(s:getParent(), x, y)
				end
			}

			item.layout = { sub }
		end
		
		item.attributes = {
			touchContainsExtendChildren = true,
			touchBeganHandler = function(s, x, y)
				AudioEngine.playEffect(config_sound_effects.common_menu_item_click, false)
				self:setEmitter(x, y)
				GlobalObj.m_fromMap = true
				local sound = d.sound
				if nil ~= d.sceneID then
					GlobalObj.m_showSceneID = d.sceneID
				end
				if sound then
					AudioEngine.stopAllEffects()
					AudioEngine.playEffect(sound, false)
				end

				--brandAnimate(s, TAG_SUB_NODE)
				--_tapEmitter:setPosition(self:convertToNodeSpace(ccp(x, y)))
				--_tapEmitter:resetSystem()

				self.isTouchEnabled = false

				self:touchAction(item.tag, s)
			end
		}
		table.insert(list_layout, item)
	end
	self:layout(list_layout)
	self:createTapParticle()

	Helper:reset_debug_func_SpriteLayer_setSprite()
	--self:createParticleLayer()
end

function LayerEntry:touchAction(tag, sprite)
	local cs = __G__canvasSize
	local function getMoveDistance(t)
	    if TAG_PARK == tag then
			--return -cs.width * 0.1, -cs.height * 0.1
			return 0, -cs.height * 0.1
	    elseif TAG_CHOCOLATE_SHOP == tag then
			return 0, -cs.height * 0.1
	    elseif TAG_CARD_SHOP == tag then
			return -cs.width * 0.1, -cs.height * 0.1
	    elseif TAG_MAKE_UP == tag then
			return -cs.width * 0.1, 0
	    elseif TAG_DRESS_UP == tag then
			return cs.width * 0.1, 0
	    elseif TAG_SHOP == tag then
			return cs.width * 0.1, -cs.height * 0.1
	    elseif TAG_PARTNER_CLOSET == tag then
			return -cs.width * 0.1, -cs.height * 0.1
	    elseif TAG_RESTAURANT == tag then
			return 0, -cs.height * 0.1
	    elseif TAG_SHOP == tag then
			return 0, -cs.height * 0.1
	    else
	        return 0, 0
	    end
	end

	local parent = self:getParent()
	if parent then
		local function nameJump()
			AudioEngine.playEffect("sfx/common/2 - menu open.mp3", false)
			local n = self:getChildByTag(tag)
			if nil == n then return end
			local action = self:getChildByTag(TAG_SPA):getActionByTag(TAG_ACTION_JUMP)
			if nil ~= action then
				self:getChildByTag(TAG_SPA):stopAction(action)
			end
			action = n:getActionByTag(TAG_ACTION_JUMP)
			if nil ~= action then return end
			action = CCRepeatForever:create(CCJumpBy:create(0.5, ccp(0,0), 20,1))
			action:setTag(TAG_ACTION_JUMP)
			n:runAction(action)
		end
	    local callfunc_1 = CCCallFunc:create(function() 
			self.isTouchEnabled = false     
		end)
	    local scaleto = CCScaleTo:create(1.1, 1.2)
	    local dx, dy = getMoveDistance(t)
	    local moveby = CCMoveBy:create(1.1, ccp(dx, dy))
	    local sp = CCSpawn:createWithTwoActions(scaleto, moveby)
	    local callfunc = CCCallFunc:create(function() 
			self:onSelectFunc(tag , sprite) 
			performWithDelay(self, function() 
				self.isTouchEnabled = true 
			end, 0.75)
		end)
	    local arr = CCArray:create()
	    arr:addObject(CCCallFunc:create(nameJump))
	    arr:addObject(callfunc_1)
	    arr:addObject(sp)
	    arr:addObject(callfunc)
	    parent:runAction(CCSequence:create(arr))
	end
end

function LayerEntry:onSelectFunc(tag, sprite)
	local data = { adType = "FULLAD" }
	local func = {
		[TAG_SPA] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneSpa, data)
			end, 0.25)
		end,
		[TAG_MAKE_UP] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneMakeup, data)
			end, 0.25)
		end,
		[TAG_DRESS_UP] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneDress, data)
			end, 0.25)
		end,
		[TAG_CARD_SHOP] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneCard, data)
			end, 0.25)
		end,
		[TAG_SHOP] = function(...)
			performWithDelay(self, function()
				--s_layerMain._layerMenu:onShop(iapCallback)
				 local oldcloseCallback = nil
				 local function shopClose()
				     print("========closeCallback=======")
				     if oldcloseCallback then
				         oldcloseCallback()
				     end
				     local n = self:getChildByTag(TAG_SHOP)
				     if nil ~= n then 
					 	local action = n:getActionByTag(TAG_ACTION_JUMP)
						if nil ~= action then
							n:stopAction(action)
						end
					 end
				     local scaleto = CCScaleTo:create(0.5, 1)
				     local moveto = CCMoveTo:create(0.5, ccp(0, 0))
				     local sp = CCSpawn:createWithTwoActions(scaleto, moveto)
				     self:getParent():runAction(sp)
				 end
				 __G__showPopup(function(closeCallback) oldcloseCallback = closeCallback return config_popup.createShop(shopClose, iapCallback) end, s_layerMain, false)
			end, 0.25)
		end,
		[TAG_PARTNER_CLOSET] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneRole, data)
			end, 0.25)
		end,
		[TAG_CHOCOLATE_SHOP] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneShow, data)
			end, 0.25)
		end,
		[TAG_PARK] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneShow, data)
			end, 0.25)
		end,
		[TAG_RESTAURANT] = function(...)
			performWithDelay(self, function()
				game_app:switchWithScene(SceneShow, data)
			end, 0.25)
		end,
	}

	if func[tag] then
		func[tag]()
	end
end

function LayerEntry:createTapParticle()
	local pLayer = CCLayer:create()
	local pink = CCParticleSystemQuad:create("particles/pink-bubble.plist")
	pink:setPosition(ccp(0, -30))
	pLayer:addChild(pink, 13, 2)
	pink:stopSystem()

	self:addChild(pLayer, 130)
	self._layerParticle = pLayer
end

function LayerEntry:setEmitter(x, y)
	local l = self._layerParticle
	if nil == l then return; end
	l:setPosition(self:convertToNodeSpace(ccp(x, y)))
	--l:getChildByTag(1):resetSystem()
	l:getChildByTag(2):resetSystem()
	--l:getChildByTag(3):resetSystem()
	--l:getChildByTag(4):resetSystem()
end
-- ============== LAYER ENTRY END   =================



_G["SceneMap"] = SceneMap



