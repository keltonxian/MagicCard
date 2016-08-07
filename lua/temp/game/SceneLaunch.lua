module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== SCENE START =================
SceneLaunch = SceneLaunch or class("SceneLaunch", Scene)

function SceneLaunch:ctor(...)
	local pLayerMain = LayerMain.new()
	s_layerMain = pLayerMain
	self:addChild(pLayerMain)
end

function SceneLaunch:initData()
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
end

function LayerMain:onEnter(...)
end

function LayerMain:onExit(...)
	--CCTextureCache:sharedTextureCache():removeAllTextures()
end
-- ============== LAYER MAIN END   =================

_G["SceneLaunch"] = SceneLaunch

