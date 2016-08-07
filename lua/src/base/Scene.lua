module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local Scene = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== Scene START =================
Scene = Scene or class("Scene", function(data)
	local scene = cc.Scene:create()
	scene._data = data

	local function sceneEventHandler(eventType)
		if "enter" == eventType then
			scene:onEnter()
		elseif "exit" == eventType then
			scene:onExit()
		elseif "enterTransitionFinish" == eventType then
			scene:onEnterTransitionFinish()
		elseif "exitTransitionStart" == eventType then
			scene:onExitTransitionStart()
		elseif "cleanup" == eventType then
			scene:onCleanup()
		end
	end

	-- @see in LuaEngine handleNodeEvent
	--kCCNodeOnEnter: "enter"
	--kCCNodeOnExit:  "exit";
	--kCCNodeOnEnterTransitionDidFinish: "enterTransitionFinish"
	--kCCNodeOnExitTransitionDidStart:   "exitTransitionStart"
	--kCCNodeOnCleanup:                  "cleanup"
	scene:registerScriptHandler(sceneEventHandler);

	return scene
end)

function Scene:onEnter()
	print("Scene:onEnter()")
end

function Scene:onExit()
	print("Scene:onExit()")
end

function Scene:onEnterTransitionFinish()
	print("Scene:onEnterTransitionFinish()")
end

function Scene:onExitTransitionStart()
	print("Scene:onExitTransitionStart()")
end

function Scene:onCleanup()
	print("Scene:onCleanup()")
end
-- ============== Scene END   =================

_G["Scene"] = Scene

