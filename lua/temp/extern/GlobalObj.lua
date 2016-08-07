module (...,package.seeall)

require "extern/Helper"
require "game/GameData"

----------------------------------------------------
--从dress场景跳转时默认展示的场景id
local _defaultShowSceneID = 1
----------------------------------------------------

local GlobalObj = class("GlobalObj",
	function ( ... )
		local obj = {}
			--游戏数据对象唯一实例
			obj.m_objGameData = GameDataInstance();

			obj.m_homeToMap = nil
			obj.m_fromMap = nil
			obj.m_showModel2 = nil
			
			obj.m_defaultSceneID = _defaultShowSceneID
			obj.m_showSceneID = nil

			obj.m_layerMakeup = nil
			obj.m_enterDressScene = nil

			obj.m_layerDesign = nil

			obj.m_layoutDatas = {}
		return obj

	end)
GlobalObj.__index = GlobalObj

function GlobalObj:ctor( ... )
	self:initGame()
end

function GlobalObj:initGame( ... )
	cclog("---------------初始化游戏数据----------------")
	
	self.m_objGameData:initData()

	self.m_homeToMap = false
	self.m_fromMap = false
	self.m_showModel2 = false
	self.m_enterDressScene = false
	
	self:resetSceneID()
	self:releaseMakeupLayer()
	self:releaseDesignLayer()
end

function GlobalObj:checkHideShopButton( ... )
	local beHide = false

---[[	
	--iso下在用户购买了对应id的产品时，有时需要隐藏伸缩菜单上的shop按钮
	if __G__checkIAP(2) and not __G__iapTest  then
		beHide = true
	end
--]]	
	
	return beHide
end

function GlobalObj:checkUnlockItem( ... )
	local beUnlock = false

	--是否可以解锁
	if __G__checkIAP(1, 2) then
		beUnlock = true
	end

	return beUnlock
end

function GlobalObj:checkRemoveAllAds( ... )
	local beRemove = false
		
---[[	
	--iso下在用户购买了对应id的产品时，有时需要隐藏所有广告
	if __G__checkIAP(2) and not __G__iapTest then
		beRemove = true
	end
--]]	
	print("================GlobalObj:checkRemoveAllAds()---------->", beRemove)
	
	return beRemove
end

function GlobalObj:isIapPurchaseTest( ... )
	return __G__isMacLuaPlayer
end


function GlobalObj:getDefaultSceneID( ... )
	return self.m_defaultSceneID
end

function GlobalObj:resetSceneID( ... )
	self.m_showSceneID = self.m_defaultSceneID
end


function GlobalObj:isDefaultSceneID( ... )
	return self.m_showSceneID == self.m_defaultSceneID
end

function GlobalObj:releaseMakeupLayer()
	cclog("-------------- call GlobalObj:releaseMakeupLayer() ----------------")
	if self.m_layerMakeup then
		cclog("-------------- GlobalObj.m_layerMakeup release ----------------")
		self.m_layerMakeup:release()
		self.m_layerMakeup = nil
	else
		cclog("-------------- GlobalObj.m_layerMakeup is already nil ----------------")
	end
end

function GlobalObj:releaseDesignLayer( ... )
	cclog("-------------- call GlobalObj:releaseDesignLayer() ----------------")
	if self.m_layerDesign then
		cclog("-------------- GlobalObj.m_layerDesign release ----------------")
		self.m_layerDesign:release()
		self.m_layerDesign = nil
	else
		cclog("-------------- GlobalObj.m_layerDesign is already nil ----------------")
	end
end

function GlobalObj:detachLayer( layer )
	print("-------- call GlobalObj:detachLayer() ----->layer:getParent():",layer:getParent())
	if layer and layer:getParent() then
		layer:removeFromParentAndCleanup(false)
	end
end

-- iap with no ads for ios
function GlobalObj:removeAllADs()
    if not __G__isAndroid and self:checkRemoveAllAds() then
    	print("================GlobalObj:removeAllADs()================")
        AdsPopupManager:sharedManager():hideBannerAd()
        AdsPopupManager = {
            sharedManager = function() return {
                showBannerAd = function() end,
                hideBannerAd = function() end,
                showInterstitialCrossPromote = function() end,
                showInterstitial = function() end,
                dismissInterstitial = function() end,
                bannerIsShowing = function() return false end,
            } end,
        }

        _G["AdsPopupManager"] = AdsPopupManager

    end
end


function GlobalObj:getLayoutData( str_key )
	local _data = self.m_layoutDatas[str_key]
	if not _data then
		if str_key=="LAYOUT_SPA" then
			_data = Helper:getTableByJsonFile("layout/spa.json")

		elseif str_key=="LAYOUT_MAKEUP" then
			_data = Helper:getTableByJsonFile("layout/makeup.json")

		elseif str_key=="LAYOUT_LIPSTICK" then
			_data = Helper:getTableByJsonFile("layout/minigame.json")
			
		elseif str_key=="LAYOUT_DRESSUP" then
			_data = Helper:getTableByJsonFile("layout/dressup.json")

		elseif str_key=="LAYOUT_DRESSUP_PARTNER" then
			_data = Helper:getTableByJsonFile("layout/dressup_partner.json")

		elseif str_key=="LAYOUT_MAP" then
			_data = Helper:getTableByJsonFile(string.format("layout/map_%s.json", __G__iOSValue("i4","i5","ipad")))

		end

		self.m_layoutDatas[str_key] = _data
	end

	return _data
end

local s_instGlobalObj = s_instGlobalObj or nil
function getGlobalInstance( )
	if not s_instGlobalObj then
		s_instGlobalObj = GlobalObj.new()

		GlobalObj.new = function ( ... )
			error("\"GlobalObj\" 为全局单例类，外部无法使用\"new()\"创建新对象")
		end
	end
	return s_instGlobalObj
end

_G["GlobalObj"] = getGlobalInstance()
