
--==================================================
--    @Brief:   game config
--    @Author:  Rios
--    @Date:    2015-10-12
--==================================================

module (...,package.seeall)

local GameConfig = GameConfig or class("GameConfig")

function GameConfig:getEnterScene( ... )
	return SceneTest
end

function GameConfig:configDebug()	

	_G["__G__iapTest"] = false
	__G__soundMute(false)

	--------------------------------------------------
	-- 标记Loading期间跳过广告加载模块
    self.DebugNoLoadingAdvertisement = true and __G__isMacLuaPlayer

    -- 标记跳过剧情
    self.DebugNoStory = true

    -- 地图界面中显示show界面按钮
    self.DebugShowSceneButton = true
    --------------------------------------------------
end

function GameConfig:studio()
	
	--GGI / MSLPPI / KMI / BTI / BCI / IPI / IEL / FMI / BGI / PAI / PFG / FDI

	local _studio = nil
	
	if __G__isAndroid then
		_studio = "BGI"
	else
		_studio = "PAI"
	end
	return _studio
end

function GameConfig:getFaceBookUrl( studio )
    if not studio then
        studio = self:studio()
    end

    local _tblURL = {
    --Salon™
        PPI = "https://www.facebook.com/pages/Salon-My-Styling-Lounge/650573658373878?fref=ts",
        GGI = "https://www.facebook.com/pages/Salon-My-Styling-Lounge/650573658373878?fref=ts",

    --Baby Care Inc.
        KMI = "",
        BCI = "https://www.facebook.com/pages/Baby-Care-Inc/202760293257853?fref=ts",

    --Beauty Inc.
        BTI = "https://www.facebook.com/pages/Beauty-Inc/1490275731254673",

    --iProm Games Inc.
        PGI = "https://www.facebook.com/pages/IProm-Inc/733903253314095?ref=br_rs",
        IEL = "https://www.facebook.com/pages/IPrincess-Entertainment-Limited/870279779663906?fref=ts",

    --Beauty Girls Inc
        BGI = "https://www.facebook.com/pages/Beauty-Girls-Inc/101754906838836?fref=ts",
        PAI = "https://www.facebook.com/pages/Princess-Apps-Inc/658877154225734?ref=br_rs",
        PFG = "https://www.facebook.com/pages/Party-for-Girls-Ltd/363403397156094?ref=br_rs",
 
    --Fashion Doll Inc.
        FDI = "https://www.facebook.com/pages/Fashion-Doll-Inc/541320739345559?ref=br_rs",
        FMI = "",
    }

    local _url = _tblURL[studio]
    if _url=="" then
        cclog("**************[%s]:FaceBook URL is NULL!*****************", studio)
    end
    
    return _url
end

function GameConfig:musicVolume()
	return 0.5
end

function GameConfig:effectsVolume()
	return 1.0
end

local s_cfgCSV = nil
function GameConfig:configCSV( ... )
    if not s_cfgCSV then
        require "lib/ConfigCSV" -- 广告配置信息
        s_cfgCSV = ConfigCSV.create("config/app.csv")
    end

    return s_cfgCSV
end

-- 全局单例
local config_game_instance = nil
function GameConfig:getInstance( ... )
	if not config_game_instance then
        config_game_instance = GameConfig.new()
    end

    GameConfig.new = function ( ... )
    	error("GameConfig.new()--->access error!")
    end

    return config_game_instance
end

_G["config_game"] = GameConfig:getInstance()
