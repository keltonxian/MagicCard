module(..., package.seeall)

-- --------------------------------------------------------------------------------
-- -- author: kelton. 2016-03-26
--
--
--
-- --------------------------------------------------------------------------------

-- ============== CONSTANT START =================
local PATH_FRAME_HERO     = "frame/frame_hand.png"
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local CardSprite = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== CARD SPRITE START =================
CardSprite = CardSprite or class("CardSprite", function(data)
	local path = nil
	path = PATH_FRAME_HERO
	local obj = cc.Sprite:create(path)
	if nil ~= data.cid then
		obj._card = Card.new({cid = data.cid})
	elseif nil ~= data.card then
		obj._card = data.card
	end
	obj._uniIndex = 0
	obj._labelHp = nil
	obj._labelPower = nil
	obj._labelCost = nil
	return obj
end)

function CardSprite:ctor(...)
	self:initHero()
end

function CardSprite:initHero()
	local size = self:getContentSize()
	local fontSize = 60
	local label, num, pos
	num = self._card._hp .. ''
	pos = cc.p(size.width-30, 30)
	label = GameTool:addLabelOutline(self, num, TTF_DEFAULT, fontSize, pos, C4B_WHITE, C4B_BLACK, 4, ANCHOR_CENTER_CENTER, 20)
	self._labelHp = label

	num = self._card._power .. ''
	pos = cc.p(30, 30)
	label = GameTool:addLabelOutline(self, num, TTF_DEFAULT, fontSize, pos, C4B_WHITE, C4B_BLACK, 4, ANCHOR_CENTER_CENTER, 20)
	self._labelPower = label

	num = self._card._cost .. ''
	pos = cc.p(30, size.height-50)
	label = GameTool:addLabelOutline(self, num, TTF_DEFAULT, fontSize, pos, C4B_WHITE, C4B_BLACK, 4, ANCHOR_CENTER_CENTER, 20)
	self._labelCost = label

	local desc = self._card._desc
	pos = cc.p(40, 60)
	label = GameTool:addLabelConfig(self, desc, TTF_DEFAULT, 18, pos, C4B_WHITE, ANCHOR_LEFT_DOWN, 10, cc.size(size.width-pos.x*2, 82), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

	local name = self._card._name
	pos = cc.p(size.width/2, size.height/2-52)
	--label = GameTool:addLabelConfig(self, name, TTF_DEFAULT, 23, pos, C4B_WHITE, ANCHOR_CENTER_CENTER, 50)
	label = GameTool:addLabelOutline(self, name, TTF_DEFAULT, 23, pos, cc.c4b(100, 230, 100,255), C4B_BLACK, 2, ANCHOR_CENTER_CENTER, 50)
	--, cc.size(size.width-pos.x*2, 85), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

	local path = string.format("card/%d.png", self._card._cid)
	pos = cc.p(size.width/2, size.height/2+78)
	local pic = GameTool:addSprite(self, GameTool:getPath(path), pos, ANCHOR_CENTER_CENTER, -1);
end

function CardSprite:setUniIndex(uniIndex)
	self._uniIndex = uniIndex
end

function CardSprite:getUniIndex()
	return self._uniIndex
end

function CardSprite:changeHp(offset)
	self._card._hp = self._card._hp + offset
	if self._card._hp < 0 then
		self._card._hp = 0
	end
	self._labelHp:setString(self._card._hp)
end

function CardSprite:getHpLabel()
	return self._labelHp
end

function CardSprite:clone()
	local card = self._card
	local newCardSprite = CardSprite.new({ card = clone(card) })
	return newCardSprite
end
-- ============== CARD SPRITE END   =================

_G["CardSprite"] = CardSprite

