module(..., package.seeall)

-- --------------------------------------------------------------------------------
-- -- author: kelton. 2016-03-26
--
--
--
-- --------------------------------------------------------------------------------

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local Card = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
-- ============== FUNCTION END   =================

-- ============== CARD START =================
Card = Card or class("Card", function(data)
	local obj = ClassTable.new()
	obj._cid = data.cid
	obj._name = 0
	obj._ctype = 0
	obj._desc = 0
	obj._hp = 0
	obj._hp = 0
	obj._hpMax = 0
	obj._power = 0
	obj._powerMax = 0
	obj._cost = 0
	obj._target = nil
	obj._targetCount = nil
	obj._triggerAttack = nil
	return obj
end)

function Card:ctor(...)
	--local card = CardList[self._cid]
	local card = CardList.getCardByCid(self._cid)
	self._name = card.name
	self._ctype = card.ctype
	self._desc = card.desc
	self._hpMax = card.hp
	self._powerMax = card.power
	self._cost = card.cost
	self._hp = self._hpMax
	self._power = self._powerMax
	self._target = clone(card.target)
	self._targetCount = card.targetCount
	self._triggerAttack = card.triggerAttack
	print('card: ', card)
	print('card.name: ', card.name)
end
-- ============== CARD END   =================

_G["Card"] = Card

