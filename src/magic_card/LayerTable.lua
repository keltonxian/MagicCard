module(..., package.seeall)

-- ============== CONSTANT START =================
-- rect info
local R_DOWN_HERO = cc.rect(30, 350, 125, 164)
local R_DOWN_ALLY = cc.rect(30+125+30, 350, 420, 144)
local R_DOWN_SUPPORT = cc.rect(30, 170, 310, 144)
local R_DOWN_GRAVE = cc.rect(30+310+30, 170, 100, 144)
local R_DOWN_DECK = cc.rect(30+310+30+100+30, 170, 100, 144)
local R_DOWN_HAND = cc.rect(80, -100, __G__vSize.width-160, 244)

local R_UP_HERO = cc.rect(30, __G__vSize.height-164-250, 125, 164)
local R_UP_ALLY = cc.rect(30+125+30, __G__vSize.height-144-250, 420, 144)
local R_UP_SUPPORT = cc.rect(30, __G__vSize.height-144-70, 310, 144)
local R_UP_GRAVE = cc.rect(30+310+30, __G__vSize.height-144-70, 100, 144)
local R_UP_DECK = cc.rect(30+310+30+100+30, __G__vSize.height-144-70, 100, 144)
local R_UP_HAND = cc.rect(80, __G__vSize.height-144+100, __G__vSize.width-160, 144)

local CARD_SIZE = cc.size(323, 494)
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local LayerTable = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== LAYER TABLE START =================
LayerTable = class("LayerTable", 
	function(data)
		local obj = Layer.new()
		obj._downHeroRect = nil
		obj._downAllyRect = nil
		obj._downSupportRect = nil
		obj._downGraveRect = nil
		obj._downDeckRect = nil
		obj._downHandRect = nil
		obj._upHeroRect = nil
		obj._upAllyRect = nil
		obj._upSupportRect = nil
		obj._upGraveRect = nil
		obj._upDeckRect = nil
		obj._upHandRect = nil
		return obj
	end
)

function LayerTable:ctor(...)
	self._downHeroRect = clone(R_DOWN_HERO)
	self._downAllyRect = clone(R_DOWN_ALLY)
	self._downSupportRect = clone(R_DOWN_SUPPORT)
	self._downGraveRect = clone(R_DOWN_GRAVE)
	self._downDeckRect = clone(R_DOWN_DECK)
	self._downHandRect = clone(R_DOWN_HAND)
	self._upHeroRect = clone(R_UP_HERO)
	self._upAllyRect = clone(R_UP_ALLY)
	self._upSupportRect = clone(R_UP_SUPPORT)
	self._upGraveRect = clone(R_UP_GRAVE)
	self._upDeckRect = clone(R_UP_DECK)
	self._upHandRect = clone(R_UP_HAND)
	self:initParam()
	self:drawArea()
end

function LayerTable:onEnter(...)
end

function LayerTable:onExit(...)
end

function LayerTable:initParam()
	local list = {
		self._downHeroRect,
		self._downAllyRect, self._downSupportRect,
		self._downDeckRect, self._downGraveRect,
		self._downHandRect,
		self._upHeroRect,
		self._upAllyRect, self._upSupportRect,
		self._upDeckRect, self._upGraveRect,
		self._upHandRect,
	}
	local csize = CARD_SIZE
	for i = 1, #list do
		local r = list[i]
		local scale = GameTool:scaleFixWidthHeight(nil, r.width/csize.width, r.height/csize.height, true)
		r.scale = scale
	end
end

function LayerTable:getCardSize()
	return CARD_SIZE
end

function LayerTable:drawArea()
	local list = {
		self._downHeroRect,
		self._downAllyRect, self._downSupportRect,
		self._downDeckRect, self._downGraveRect,
		self._downHandRect,
		self._upHeroRect,
		self._upAllyRect, self._upSupportRect,
		self._upDeckRect, self._upGraveRect,
		self._upHandRect,
	}
	local drawNode = cc.DrawNode:create();
	local color = cc.c4f(0.9, 0.1, 0.1, 1)
	local lineWidth = 4
	for i = 1, #list do
		local r = list[i]
		local verts = {
			cc.p(r.x, r.y),
			cc.p(r.x + r.width, r.y),
			cc.p(r.x + r.width, r.y + r.height),
			cc.p(r.x, r.y + r.height),
		}
		for j = 1, #verts do
			local from = verts[j]
			local to = verts[j+1]
			if j == #verts then
				to = verts[1]
			end
			drawNode:drawSegment(from, to, lineWidth, color)
		end
	end
	drawNode:setPosition(cc.p(0, 0));
	self:addChild(drawNode, 10);
end

function LayerTable:getDownHeroRect()
	return self._downHeroRect
end

function LayerTable:getDownAllyRect()
	return self._downAllyRect
end

function LayerTable:getDownSupportRect()
	return self._downSupportRect
end

function LayerTable:getDownGraveRect()
	return self._downGraveRect
end

function LayerTable:getDownDeckRect()
	return self._downDeckRect
end

function LayerTable:getDownHandRect()
	return self._downHandRect
end

function LayerTable:getUpHeroRect()
	return self._upHeroRect
end

function LayerTable:getUpAllyRect()
	return self._upAllyRect
end

function LayerTable:getUpSupportRect()
	return self._upSupportRect
end

function LayerTable:getUpGraveRect()
	return self._upGraveRect
end

function LayerTable:getUpDeckRect()
	return self._upDeckRect
end

function LayerTable:getUpHandRect()
	return self._upHandRect
end
-- ============== LAYER TABLE END   =================

_G["LayerTable"] = LayerTable

