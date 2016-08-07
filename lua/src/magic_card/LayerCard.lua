module(..., package.seeall)

-- ============== CONSTANT START =================
local ZORDER_CARD       = 100
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local LayerCard = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
local function setHero(layer, rect, listCardId, toList)
	if #listCardId > 1 then
		cclog("LayerCard:setDown #listCardId[%d] > 0", #listCardId)
		return
	end
	local x = rect.x + rect.width/2
	local y = rect.y + rect.height/2
	local scale = 1
	local rotation = 0
	local cid = listCardId[1]
	local sprite = layer:addCard(cid, x, y)
	local scale = rect.scale
	sprite:setScale(scale)
	table.insert(toList, sprite)
end

local function setAllySupport(layer, rect, listCardId, toList)
	if #listCardId == 0 then return end
	local gapx = 0
	local x = rect.x
	local y = rect.y + rect.height/2
	local scale = rect.scale
	for i = 1, #listCardId do
		local cid = listCardId[i]
		local sprite = layer:addCard(cid, x, y)
		local size = sprite:getContentSize()
		sprite:setScale(scale)
		if 1 == i then
			local cardWidth = size.width * sprite:getScale()
			gapx = self:getGap(#listCardId, cardWidth, rect.width)
			x = rect.x + cardWidth/2
			sprite:setPositionX(x)
		end
		table.insert(toList, sprite)
		x = x + gapx
	end
end

local function setGrave(layer, rect, listCardId, toList)
	if #listCardId == 0 then return end
	local x = rect.x + rect.width/2
	local y = rect.y + rect.height/2
	local scale = rect.scale
	for i = 1, #listCardId do
		local cid = listCardId[i]
		local sprite = layer:addCard(cid, x, y)
		sprite:setScale(scale)
		table.insert(toList, sprite)
	end
end

local function setDeck(layer, rect, listCardId, toList)
	if #listCardId == 0 then return end
	local x = rect.x + rect.width/2
	local y = rect.y + rect.height/2
	local scale = rect.scale
	for i = 1, #listCardId do
		local cid = listCardId[i]
		local sprite = layer:addCard(cid, x, y)
		sprite:setScale(scale)
		table.insert(toList, sprite)
	end
end

local function setHand(layer, rect, listCardId, toList)
	if #listCardId == 0 then return end
	local gapx = 0
	local x = rect.x
	local y = rect.y + rect.height/2
	local scale = rect.scale
	for i = 1, #listCardId do
		local cid = listCardId[i]
		local sprite = layer:addCard(cid, x, y)
		sprite:setScale(scale)
		local size = sprite:getContentSize()
		if 1 == i then
			local cardWidth = size.width * sprite:getScale()
			gapx = self:getGap(#listCardId, cardWidth, rect.width)
			x = rect.x + cardWidth/2
			sprite:setPositionX(x)
		end
		table.insert(toList, sprite)
		x = x + gapx
	end
end
-- ============== FUNCTION END   =================

-- ============== LAYER CARD START =================
LayerCard = class("LayerCard", 
	function(data)
		local obj = Layer.new()
		obj._cardUniIndex = nil
		obj._downHero = nil
		obj._downAlly = nil
		obj._downSupport = nil
		obj._downGrave = nil
		obj._downDeck = nil
		obj._downHand = nil
		obj._upHero = nil
		obj._upAlly = nil
		obj._upSupport = nil
		obj._upGrave = nil
		obj._upDeck = nil
		obj._upHand = nil
		return obj
	end
)

function LayerCard:ctor(...)
	self._cardUniIndex = 1
end

function LayerCard:onEnter(...)
end

function LayerCard:onExit(...)
end

function LayerCard:addCard(cid, x, y)
-- sprite list in battle
-- set unique id generate in create function
	local sprite = CardSprite.new({ cid = cid })
	sprite:setUniIndex(self._cardUniIndex)
	sprite:setAnchorPoint(ANCHOR_CENTER_CENTER)
	sprite:setPosition(cc.p(x, y))
	self:addChild(sprite, ZORDER_CARD)
	self._cardUniIndex = self._cardUniIndex + 1
	return sprite
end

function LayerCard:setDownHero(rect, listCardId)
	self._downHero = {}
	setHero(self, rect, listCardId, self._downHero)
	return self._downHero
end

function LayerCard:setDownAlly(rect, listCardId)
	self._downAlly = {}
	setAllySupport(self, rect, listCardId, self._downAlly)
	return self._downAlly
end

function LayerCard:setDownSupport(rect, listCardId)
	self._downSupport = {}
	setAllySupport(self, rect, listCardId, self._downSupport)
	return self._downSupport
end

function LayerCard:setDownGrave(rect, listCardId)
	self._downGrave = {}
	setGrave(self, rect, listCardId, self._downGrave)
	return self._downGrave
end

function LayerCard:setDownDeck(rect, listCardId)
	self._downDeck = {}
	setDeck(self, rect, listCardId, self._downDeck)
	return self._downDeck
end

function LayerCard:setDownHand(rect, listCardId)
	self._downHand = {}
	setHand(self, rect, listCardId, self._downHand)
	return self._downHand
end

function LayerCard:setUpHero(rect, listCardId)
	self._upHero = {}
	setHero(self, rect, listCardId, self._upHero)
	return self._upHero
end

function LayerCard:setUpAlly(rect, listCardId)
	self._upAlly = {}
	setAllySupport(self, rect, listCardId, self._upAlly)
	return self._upAlly
end

function LayerCard:setUpSupport(rect, listCardId)
	self._upSupport = {}
	setAllySupport(self, rect, listCardId, self._upSupport)
	return self._upSupport
end

function LayerCard:setUpGrave(rect, listCardId)
	self._upGrave = {}
	setGrave(self, rect, listCardId, self._upGrave)
	return self._upGrave
end

function LayerCard:setUpDeck(rect, listCardId)
	self._upDeck = {}
	setDeck(self, rect, listCardId, self._upDeck)
	return self._upDeck
end

function LayerCard:setUpHand(rect, listCardId)
	self._upHand = {}
	setHand(self, rect, listCardId, self._upHand)
	return self._upHand
end

function LayerCard:getGap(totalCard, cardWidth, tableWidth)
	--[[
	if g_euser.side == SIDE_DOWN and ltype == DOWN_HAND then
		table_width = table_width+HAND_GAP*2
	end
	]]--
	if totalCard <= 1 then
		return 0
	end
	local gap
	local base = totalCard - 1

	gap = (tableWidth - cardWidth) / base
	if gap > cardWidth then
		gap = cardWidth
	end
	return math.abs(gap)
end

function LayerCard:setCardZOrder(card, zorder)
	card:setLocalZOrder(ZORDER_CARD + zorder);
end
-- ============== LAYER CARD END   =================

_G["LayerCard"] = LayerCard

