module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local GameApplication = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== GameApplication START =================
-- class is from
-- cocos/scripting/lua-bindings/script/extern.lua
GameApplication = GameApplication or class("GameApplication")

function GameApplication:ctor()
    self:initCache()
    self:initProperty()
	self:initResolution()
	self:initBaseRequire()
end

function GameApplication:initCache()
end

function GameApplication:initProperty()
	self._currentScene = nil
end

function GameApplication:initResolution()
	local projectName = "ProjectLua"
	local director = cc.Director:getInstance()
	local glview = director:getOpenGLView()
	if nil == glview then
		if platform == cc.PLATFORM_OS_MAC then
			glview = cc.GLView:createWithRect(projectName, cc.rect(0, 0, 400, 600))
		elseif platform == cc.PLATFORM_OS_WINDOWS then
			glview = cc.GLView:createWithRect(projectName, cc.rect(0, 0, 400, 600))
		else
			glview = cc.GLView:createWithRect(projectName, cc.rect(0, 0, 640, 960))
		end
		director:setOpenGLView(glview)
	end

	local frame_size = glview:getFrameSize()

	glview:setDesignResolutionSize(640, 640 * frame_size.height / frame_size.width, cc.ResolutionPolicy.SHOW_ALL)

	director:setDisplayStats(false)
	director:setAnimationInterval(1.0 / 60)
end

function GameApplication:initBaseRequire()
	require "base/CommonVars"
	require "base/GameTool"

	require "base/RequireList"
end

function GameApplication:printSysInfo()
	cclog("=====environment info=====")
	cclog("jit.version[%s]", jit.version)
    local vsize = cc.Director:getInstance():getVisibleSize()	 
	cclog("x[%f], y[%f]", __G__vOrigin.x, __G__vOrigin.y) 
	cclog("width[%f], height[%f]", __G__vSize.width, __G__vSize.height) 
	cclog("centerPosition[(%f, %f)]", __G__vCenter.x, __G__vCenter.y)
	cclog("==========================")
end

function GameApplication:getFirstScene()
	return SceneBattle
	--return SceneLaunch
end

function GameApplication:start()
	self:printSysInfo()
    self:runWithScene(self:getFirstScene())
end

function GameApplication:runWithScene(nextScene, sceneData)
    local scene = nextScene.new(sceneData)
	local director = cc.Director:getInstance()
    self.m_current_scene = scene
	if director:getRunningScene() then
		director:replaceScene(scene);
	else
		director:runWithScene(scene);
	end
end
-- ============== GameApplication END   =================
-------------------------------------------------------------
-- config_scene_effects_func 为 config_scene_effects 中配置的切换特效。(例如淡出效果为：config_scene_effects.kTransitionFade)
-------------------------------------------------------------
function GameApplication:switchWithScene(next_scene, scene_data, config_scene_effects_func, effect_duration)
    -- loading场景过渡
    if not config_scene_effects_func then
        local function realReplaceWithScene()
            local scene = next_scene.new(scene_data)
            CCDirector:sharedDirector():replaceScene(scene)
            self.m_current_scene = scene 
        end

        local adType = scene_data and scene_data.adType

        --[[
            注意:res_flag为类变量，在定义新场景后赋值，如：
            XXXScene = XXXScene or class("XXXScene", Scene)
            XXXScene.res_flag = "xxx_scene_res"
        --]]
        local resource = config_preload[next_scene.res_flag] or {}
        
        local loading = scene_loading.new(resource[1], resource[2], resource[3], realReplaceWithScene, adType)
        CCDirector:sharedDirector():replaceScene( loading )
        self.m_current_scene = loading

    --配置的场景切换特效过渡
    elseif type(config_scene_effects_func)=="function" then
        local duration = effect_duration or 0.75
        local scene = next_scene.new(scene_data)
        local effectScene = config_scene_effects_func(duration, scene)
        effectScene.__cname = effectScene.__cname or config_scene_effects.__cname
        CCDirector:sharedDirector():replaceScene(effectScene)
        self.m_current_scene = scene
    else
        error("ERROR: config_scene_effects_func must be a function!")
    end
end

function GameApplication:createResumeLoading( adType )
    scene_loading.new(nil, nil, nil, nil, adType, true)
end

-------------------------------------------------------------
-- Lua AppDelegate
-------------------------------------------------------------
function GameApplication:applicationDidFinishLaunching()
end

function GameApplication:applicationDidEnterBackground()
    __G__isBackground = true
end

function GameApplication:applicationWillEnterForeground()
    __G__isBackground = false
	--self:createResumeLoading("FULLAD")
end

-------------------------------------------------------------
-- getter and setter
-------------------------------------------------------------
-- 全局单例
local _gameapp_instance = nil
function GameApplication:getInstance()
    if not _gameapp_instance then
        _gameapp_instance = GameApplication.new()
    end

    GameApplication.new = function ( ... )
        error("GameApplication.new()--->access error!")
    end

    return _gameapp_instance
end

_G["GameApplication"] = GameApplication
