module(..., package.seeall)

-- ============== CONSTANT START =================
local function normalAttack(srcCard, listTarget)
	local cmd = string.format("%s %d ", CMD_ATTACK, srcCard:getUniIndex())
	for i = 1, #listTarget do
		local target = listTarget[i]
		cmd = string.format("%s %d", cmd, target:getUniIndex())
	end
	return cmd
end
-- ============== CONSTANT END   =================

-- ============== CARD LIST START =================
local CardList = {}

-- ============== HERO START =================
table.insert(CardList, {
	cid = 10001,
	ctype = CARD_TYPE_HERO,
	name = "Boris Skullcrusher",
	hp = 30,
	power = 0,
	cost = 0,
	desc = "ENERGY:4 Target opposing ally with cost 4 or less is killed.",
})

table.insert(CardList, {
	cid = 10002,
	ctype = CARD_TYPE_HERO,
	name = "Amber Rain",
	hp = 30,
	power = 0,
	cost = 0,
	desc = 'ENERGY:3 Target weapon you control gains +2 base attack, but may not gain any other bonus.',
})
-- ============== HERO END   =================

-- ============== ALLY START =================
table.insert(CardList, {
	cid = 20001,
	ctype = CARD_TYPE_ALLY,
	name = "Jasmine Rosecult",
	hp = 4,
	power = 3,
	cost = 3,
	desc = "RES:2 Target oppoing ally cannot attack until the end of its controllers next turn.",
	target = { 
		{ TARGET_OPPOSITE, CARD_TYPE_ALLY }, 
		{ TARGET_OPPOSITE, CARD_TYPE_HERO },
	},
	targetCount = 1,
	triggerAttack = function(srcCard, listTarget)
		return normalAttack(srcCard, listTarget)
	end,
})

table.insert(CardList, {
	cid = 20002,
	ctype = CARD_TYPE_ALLY,
	name = "Dirk Saber",
	hp = 2,
	power = 2,
	cost = 2,
	desc = 'Ambush (attacks by this ally cannot be defended).',
	target = { 
		{ TARGET_OPPOSITE, CARD_TYPE_ALLY }, 
		{ TARGET_OPPOSITE, CARD_TYPE_HERO },
	},
	targetCount = 1,
	triggerAttack = function(srcCard, listTarget)
		return normalAttack(srcCard, listTarget)
	end,
})

table.insert(CardList, {
	cid = 20003,
	ctype = CARD_TYPE_ALLY,
	name = "Sandra Trueblade",
	hp = 3,
	power = 2,
	cost = 4,
	desc = 'When Sandra is summoned,target player removes one of their resources from play if their resources are greater than or equal to yours.',
	target = { 
		{ TARGET_OPPOSITE, CARD_TYPE_ALLY }, 
		{ TARGET_OPPOSITE, CARD_TYPE_HERO },
	},
	targetCount = 1,
	triggerAttack = function(srcCard, listTarget)
		return normalAttack(srcCard, listTarget)
	end,
})
-- ============== ALLY END   =================

-- ============== SUPPORT START =================
table.insert(CardList, {
	cid = 30001,
	ctype = CARD_TYPE_SUPPORT,
	name = "Valiant Defender",
	hp = 0,
	power = 0,
	cost = 2,
	desc = "Friendly allies cannot be attacked for the next 2 turns.",
})
-- ============== SUPPORT END   =================

-- ============== MAGIC START =================
table.insert(CardList, {
	cid = 40001,
	ctype = CARD_TYPE_MAGIC,
	name = "Fireball",
	hp = 0,
	power = 4,
	cost = 3,
	desc = 'Target opposing hero or ally takes 4 fire damage.',
})
-- ============== MAGIC END   =================

CardList.getCardByCid = function(cid)
	for i = 1, #CardList do
		local card = CardList[i]
		if cid == card.cid then
			return card
		end
	end
	print("CardList.getCardByCid cannot get card by cid: ", cid)
	return nil
end
-- ============== CARD LIST END   =================

_G["CardList"] = CardList

