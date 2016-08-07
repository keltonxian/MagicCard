module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local Layer = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== LAYER START =================
Layer = Layer or class("Layer", function(data)
	local layer = cc.Layer:create()
	layer._data = data

	local function layerEventHandler(eventType)
		if "enter" == eventType then
			layer:onEnter()
		elseif "exit" == eventType then
			layer:onExit()
		elseif "enterTransitionFinish" == eventType then
			layer:onEnterTransitionFinish()
		elseif "exitTransitionStart" == eventType then
			layer:onExitTransitionStart()
		elseif "cleanup" == eventType then
			layer:onCleanup()
		end
	end

	-- @see in LuaEngine handleNodeEvent
	--kCCNodeOnEnter: "enter"
	--kCCNodeOnExit:  "exit";
	--kCCNodeOnEnterTransitionDidFinish: "enterTransitionFinish"
	--kCCNodeOnExitTransitionDidStart:   "exitTransitionStart"
	--kCCNodeOnCleanup:                  "cleanup"
	layer:registerScriptHandler(layerEventHandler)

	-- register a onTouch callback handler for a layer
	-- u may use callback=nil if there is no handler
	-- touch
	-- event: "began", "moved", "ended", "cancelled"
	local swallow = false
	if nil ~= data and nil ~= data.isSwallow then
		swallow = data.isSwallow
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(swallow)
	listener:registerScriptHandler(
		function(touch, event)
			local location = touch:getLocation()
			return layer:onTouchBegan(location.x, location.y)
		end, 
		cc.Handler.EVENT_TOUCH_BEGAN
	)
	listener:registerScriptHandler(
		function(touch, event)
			local location = touch:getLocation()
			layer:onTouchMoved(location.x, location.y)
		end, 
		cc.Handler.EVENT_TOUCH_MOVED
	)
	listener:registerScriptHandler(
		function(touch, event)
			local location = touch:getLocation();
			layer:onTouchEnded(location.x, location.y)
		end, 
		cc.Handler.EVENT_TOUCH_ENDED
	)
	local eventDispatcher = layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	-- event: "backClicked", "menuClicked"
	--layer:setKeypadEnabled(true);
	--layer:registerScriptKeypadHandler(handler);

	return layer
end)

function Layer:onEnter()
	print("Layer:onEnter()")
end

function Layer:onExit()
	print("Layer:onExit()")
end

function Layer:onEnterTransitionFinish()
	print("Layer:onEnterTransitionFinish()")
end

function Layer:onExitTransitionStart()
	print("Layer:onExitTransitionStart()")
end

function Layer:onCleanup()
	print("Layer:onCleanup()")
end

function Layer:onTouchBegan(x, y)
	print("Layer:onTouchBegan()")
	return true
end

function Layer:onTouchMoved(x, y)
	print("Layer:onTouchMoved()")
end

function Layer:onTouchEnded(x, y)
	print("Layer:onTouchEnded()")
end
-- ============== LAYER END   =================

_G["Layer"] = Layer

