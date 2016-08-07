module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local SceneLaunch = nil
local v_layerMain = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== SCENE START =================
SceneLaunch = SceneLaunch or class("SceneLaunch", Scene)
SceneLaunch.res_flag = "SceneLaunch"

function SceneLaunch:ctor(...)
	self:initData()
	local pLayerMain = LayerMain.new()
	v_layerMain = pLayerMain
	self:addChild(pLayerMain)
end

function SceneLaunch:initData()
end
-- ============== SCENE END   =================

-- ============== LAYER MAIN START =================
LayerMain = class("LayerMain", 
	function(data)
		local obj = Layer.new()
		obj._listCase = nil
		return obj
	end
)

function LayerMain:ctor(...)
	self:initVersion()

	local bg = GameTool:addSprite(self, GameTool:getPath("bg/bg1.png"), cc.p(__G__vSize.width/2, __G__vSize.height/2), ANCHOR_CENTER_CENTER, 0);
	local bgSize = bg:getContentSize()
	GameTool:scaleFixWidthHeight(bg, __G__vSize.width/bgSize.width, __G__vSize.height/bgSize.height)
	GameTool:addLayerColor(self, cc.c4b(0, 0, 0, 100), 0, 10)

	local size = cc.size(__G__vSize.width/3*2, __G__vSize.height)
	self._listCase = {
		{ title = "Label", },
	}
	for i = 1, #self._listCase do
		self._listCase[i].cellSize = cc.size(size.width, 200)
	end
	local direction = cc.SCROLLVIEW_DIRECTION_VERTICAL
	local function handler(...)
		return self:TableViewHandler(...)
	end
	local pos = cc.p((__G__vSize.width-size.width)/2, 0)
	local fillorder = cc.TABLEVIEW_FILL_TOPDOWN
	local zorder = 5
	local tableView = GameTool:addTableview(self, size, direction, handler, pos, fillorder, zorder)
	--[[
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
	]]--
end

function LayerMain:onEnter(...)
end

function LayerMain:onExit(...)
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function LayerMain:initVersion()
	local text = "kelton_lua 1.0.0"
	GameTool:addLabelConfig(self, text, TTF_DEFAULT, 30, cc.p(__G__vSize.width, 0), C4B_WHITE, ANCHOR_RIGHT_DOWN, 100, cc.size(400, 200), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
end

function LayerMain:TableViewHandler(...)
	local args = {...}
	local event = args[1]
	local view = args[2]
	--cclog("%s", event)
	if "numberOfCellsInTableView" == event then
		return #(self._listCase or {})
	elseif "scrollViewDidScroll" == event then
		return
	elseif "scrollViewDidZoom" == event then
		return
	elseif "tableCellTouched" == event then
		local cell = args[3]
		local idx = cell:getIdx()
		--[[
		if nil ~= self.callback then
			self.callback(idx + 1)
		end
		self:close()
		]]--
		return 0
	elseif "cellSizeForTable" == event then
		local idx = args[3]
		local csize = self._listCase[idx+1].cellSize
		return csize.height, csize.width
	elseif "tableCellAtIndex" == event then
		local idx = args[3];
		local cell = view:dequeueCell()
		if nil ~= cell then
			cell:removeFromParentAndCleanup(true);
		end
		cell = cc.TableViewCell:new()
		local info = self._listCase[idx + 1];
		local csize = info.cellSize
		local width = csize.width;
		local height = csize.height;
		local title = info.title;
		GameTool:addLabelConfig(cell, title, TTF_DEFAULT, 30, cc.p(0, 0), C4B_WHITE, ANCHOR_LEFT_DOWN, 1, cc.size(width, height), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		return cell;
	elseif "tableCellHighlight" == event then
		local cell = args[3];
		return;
	elseif "tableCellUnhighlight" == event then
		local cell = args[3];
		return;
	end
end
-- ============== LAYER MAIN END   =================

_G["SceneLaunch"] = SceneLaunch

