module(..., package.seeall)

-- ============== CONSTANT START =================
local AI_PLAY            = false
local PHASE_WAIT         = "1"
local PHASE_SACRIFICE    = "2"
local PHASE_PLAY         = "3"
local SIDE_NONE  = "0"
local SIDE_DOWN  = "1"
local SIDE_UP    = "2"
local HERO       = "1"
local ALLY       = "2"
local SUPPORT    = "3"
local GRAVE      = "4"
local DECK       = "5"
local HAND       = "6"

local ZORDER_TABLE     = 50
local ZORDER_CARD      = 100
local ZORDER_EFFECT    = 400
local ZORDER_SHOW      = 500

local TAG_MARK_VALID   = 201
local TAG_MARK_TARGET  = 202
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local SceneBattle = nil
local LayerMain = nil
local LayerAnim = nil
local LayerShow = nil
local v_layerMain = nil
-- ============== VAR END   =================

-- ============== FUNCTION START =================
local function addTargetMark(sprite, isRemove)
	local tag = TAG_MARK_TARGET
	local layer = sprite:getChildByTag(tag)
	if true == isRemove then
		if nil ~= layer then
			layer:removeFromParent(true)
		end
		return
	end
	if nil ~= layer then
		return
	end
	local size = sprite:getContentSize()
	local color = cc.c4b(255, 0, 0, 100)
	layer = cc.LayerColor:create(color, size.width, size.height)
	sprite:addChild(layer, 500, tag)
end

local function addValidMark(sprite, isRemove)
	local tag = TAG_MARK_VALID
	local size = sprite:getContentSize()
	local color = cc.c4b(0, 255, 0, 100)
	local layer = sprite:getChildByTag(tag)
	if true == isRemove then
		if nil ~= layer then
			layer:removeFromParent(true)
		end
		return
	end
	if nil ~= layer then
		return
	end
	layer = cc.LayerColor:create(color, size.width, size.height)
	sprite:addChild(layer, 500, tag)
end

local function getOppoSide(side)
	if side == SIDE_DOWN then
		return SIDE_UP
	end
	return SIDE_DOWN
end

local function cleanSprite(...)
	local arg = {...}
	local sprite = arg[1]
	if nil == sprite then
		alog('BUG nil == sprite')
		return nil
	end
	sprite:stopAllActions()
	sprite:setVisible(false)
	sprite:removeFromParent(true)
end
-- ============== FUNCTION END   =================

-- ============== SCENE START =================
SceneBattle = SceneBattle or class("SceneBattle", Scene)
SceneBattle.res_flag = "SceneBattle"

function SceneBattle:ctor(...)
	self:initData()
	local pLayerMain = LayerMain.new()
	v_layerMain = pLayerMain
	self:addChild(pLayerMain)
end

function SceneBattle:initData()
end
-- ============== SCENE END   =================

-- ============== LAYER MAIN START =================
LayerMain = class("LayerMain", 
	function(data)
		local obj = Layer.new()
		obj._listCard = {}
		obj._layerTable = nil
		obj._layerCard = nil
		obj._labelRes = {}
		obj._phase = PHASE_WAIT
		obj._side = SIDE_NONE
		obj._btnSacrifice = nil
		obj._btnDone = nil
		obj._cardSize = nil
		obj._bcListCmd = {}
		obj._listCmd = {}
		obj._listAnim = {}
		obj._isAnimating = 0
		obj._labelSide = nil
		obj._listTarget = nil
		obj._srcCard = nil
		return obj
	end
)

function LayerMain:ctor(...)
	local path = GameTool:getPath("bg/bg1.png")
	local bg = GameTool:addSprite(self, path, cc.p(__G__vSize.width/2, __G__vSize.height/2), ANCHOR_CENTER_CENTER, 0);
	local bgSize = bg:getContentSize()
	GameTool:scaleFixWidthHeight(bg, __G__vSize.width/bgSize.width, __G__vSize.height/bgSize.height)
	GameTool:addLayerColor(self, cc.c4b(0, 0, 0, 100), 0, 10)

	self:initLabelSide()
	self:initLabelRes()
	self:initBtn()

	local layer = LayerTable.new()
	self:addChild(layer, ZORDER_TABLE)
	self._layerTable = layer
	self._cardSize = layer:getCardSize()

	layer = LayerCard.new()
	self:addChild(layer, ZORDER_CARD)
	self._layerCard = layer

	self:initListCard()
	self:initTableData()
	self:initCardData()
	-- pve = function.....
	-- pve_do_scene = function(self, side)
	performWithDelay(self, function()
		self:nextStep()
	end, 0.1)

	self:scheduleUpdateWithPriorityLua(function(...)
		self:update(...)
	end, 1);
end

function LayerMain:onEnter(...)
end

function LayerMain:onExit(...)
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function LayerMain:initLabelSide()
	local label = GameTool:addLabelConfig(self, "", TTF_DEFAULT, 30, cc.p(__G__vSize.width/2, __G__vSize.height/2+50), C4B_WHITE, ANCHOR_CENTER_CENTER, 100)
	self._labelSide = label
end

function LayerMain:updateLabelSide(side)
	local t = side == SIDE_DOWN and "SIDE DOWN" or "SIDE UP"
	self._labelSide:setString(t)
end

function LayerMain:initLabelRes()
	local label = nil
	self._labelRes = {}

	self._labelRes[SIDE_DOWN] = {}
	label = GameTool:addLabelConfig(self, "0\n/\n0", TTF_DEFAULT, 30, cc.p(__G__vSize.width, 0), C4B_WHITE, ANCHOR_RIGHT_DOWN, 100, cc.size(60, 100), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self._labelRes[SIDE_DOWN] = { label = label, res = 0, resMax = 0 }

	self._labelRes[SIDE_UP] = {}
	label = GameTool:addLabelConfig(self, "0\n/\n0", TTF_DEFAULT, 30, cc.p(__G__vSize.width, __G__vSize.height), C4B_WHITE, ANCHOR_RIGHT_UP, 100, cc.size(60, 100), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	self._labelRes[SIDE_UP] = { label = label, res = 0, resMax = 0 }
end

function LayerMain:initBtn()
	local items = {}
	local item
	local label = GameTool:createLabelConfig("skip", TTF_DEFAULT, 50)
	--label:setTextColor(C4B_WHITE)
	local pos = cc.p(__G__vSize.width-100, __G__vSize.height/2+50)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, function()
		self:addCmd("skip")
		return
	end)
	item:setVisible(false)
	self._btnSacrifice = item

	label = GameTool:createLabelConfig("done", TTF_DEFAULT, 50)
	pos = cc.p(__G__vSize.width-100, __G__vSize.height/2+50)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, function()
		self:addCmd("done")
		return
	end)
	item:setVisible(false)
	self._btnDone = item

	GameTool:addMenu(self, items, 500)
end

function LayerMain:initListCard()
	local lSide = { SIDE_DOWN, SIDE_UP }
	local lTable = { HERO, ALLY, SUPPORT, GRAVE, DECK, HAND }
	for i = 1, #lSide do
		local s = lSide[i]
		self._listCard[s] = {}
		for j = 1, #lTable do
			local t = lTable[j]
			self._listCard[s][t] = {}
		end
	end
end

function LayerMain:getTestCards()
	local list = {}
	list[SIDE_DOWN] = {}
	list[SIDE_UP] = {}

	list[SIDE_DOWN][HERO] = { 10001 }
	list[SIDE_DOWN][ALLY] = {}
	list[SIDE_DOWN][SUPPORT] = {}
	list[SIDE_DOWN][GRAVE] = {}
	list[SIDE_DOWN][DECK] = { 20001, 20001, 20001, 20001, 20001 }
	list[SIDE_DOWN][HAND] = {}

	list[SIDE_UP][HERO] = { 10002 }
	list[SIDE_UP][ALLY] = {}
	list[SIDE_UP][SUPPORT] = {}
	list[SIDE_UP][GRAVE] = {}
	list[SIDE_UP][DECK] = { 20002, 20002, 20002 }
	list[SIDE_UP][HAND] = {}
	
	return list
end

function LayerMain:initTableData()
	if nil == self._layerTable then return end

	local layer = self._layerTable

	self._listCard[SIDE_DOWN][HERO].rect    = layer:getDownHeroRect()
	self._listCard[SIDE_DOWN][ALLY].rect    = layer:getDownAllyRect()
	self._listCard[SIDE_DOWN][SUPPORT].rect = layer:getDownSupportRect()
	self._listCard[SIDE_DOWN][GRAVE].rect   = layer:getDownGraveRect()
	self._listCard[SIDE_DOWN][DECK].rect    = layer:getDownDeckRect()
	self._listCard[SIDE_DOWN][HAND].rect    = layer:getDownHandRect()

	self._listCard[SIDE_UP][HERO].rect      = layer:getUpHeroRect()
	self._listCard[SIDE_UP][ALLY].rect      = layer:getUpAllyRect()
	self._listCard[SIDE_UP][SUPPORT].rect   = layer:getUpSupportRect()
	self._listCard[SIDE_UP][GRAVE].rect     = layer:getUpGraveRect()
	self._listCard[SIDE_UP][DECK].rect      = layer:getUpDeckRect()
	self._listCard[SIDE_UP][HAND].rect      = layer:getUpHandRect()
end

function LayerMain:initCardData()
	if nil == self._layerCard then return end

	local layer = self._layerCard
	local list = self._listCard
	local data = self:getTestCards()

	local function getFunc(s, t)
		if s == SIDE_DOWN then
			if t == HERO then
				return "setDownHero"
			elseif t == ALLY then
				return "setDownAlly"
			elseif t == SUPPORT then
				return "setDownSupport"
			elseif t == GRAVE then
				return "setDownGrave"
			elseif t == DECK then
				return "setDownDeck"
			elseif t == HAND then
				return "setDownHand"
			end
		elseif s == SIDE_UP then
			if t == HERO then
				return "setUpHero"
			elseif t == ALLY then
				return "setUpAlly"
			elseif t == SUPPORT then
				return "setUpSupport"
			elseif t == GRAVE then
				return "setUpGrave"
			elseif t == DECK then
				return "setUpDeck"
			elseif t == HAND then
				return "setUpHand"
			end
		end
	end
	local lside = { SIDE_DOWN, SIDE_UP }
	local ltable = { HERO, ALLY, SUPPORT, GRAVE, DECK, HAND }
	for i = 1, #lside do
		local s = lside[i]
		for j = 1, #ltable do
			local t = ltable[j]
			local lcid = data[s][t]
			local info = list[s][t]
			local func = getFunc(s, t)
			info.lcard = layer[func](layer, info.rect, lcid)
		end
	end
end

function LayerMain:dealCard()
	local side = self._side
	local lcard = self._listCard[side][DECK].lcard
	if 0 == #lcard then
		cclog("dealCard side[%s] no card in deck", 
			side==SIDE_DOWN and "down" or "up"
		)
		return
	end
	local cmd = string.format("deal %d", side)
	self:addCmd(cmd)
	--[[
	performWithDelay(self, function()
		self:nextStep()
	end, 0.1)
	]]--
end

function LayerMain:showSacrifice(isVisible)
	self._btnSacrifice:setVisible(isVisible)
end

function LayerMain:showDone(isVisible)
	self._btnDone:setVisible(isVisible)
end

function LayerMain:nextStep()
	if self._phase == PHASE_WAIT then
		if self._side == SIDE_NONE then
			self._side = SIDE_DOWN
		end
		self:updateLabelSide(self._side)
		self:showSacrifice(false)
		self:showDone(false)
		self._phase = PHASE_SACRIFICE
		self:dealCard()
		self:dealCard()
		--[[
		self:dealCard()
		self:dealCard()
		self:dealCard()
		]]--
		self:addCmd("next sacrifice")
		return
	end
	if self._phase == PHASE_SACRIFICE then
		if false == AI_PLAY or self._side == SIDE_DOWN then
			self:showSacrifice(true)
			self:showValidCard()
			return
		end
		return
	end
	if self._phase == PHASE_PLAY then
		if false == AI_PLAY or self._side == SIDE_DOWN then
			self:showSacrifice(false)
			self:showDone(true)
			self:showValidCard()
		end
		return
	end
end

function LayerMain:onTouchBegan(x, y)
	print("LayerMain:onTouchBegan()")
	return true
end

function LayerMain:onTouchMoved(x, y)
	print("LayerMain:onTouchMoved()")
end

function LayerMain:onTouchEnded(x, y)
	print("LayerMain:onTouchEnded()")
	local tbSide = { SIDE_DOWN, SIDE_UP }
	local tbTable = { 
		HERO, ALLY, SUPPORT, GRAVE, DECK, HAND
	}
	local isHit = false
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t= tbTable[j]
			local lcard = self._listCard[s][t].lcard
			for k = #lcard, 1, -1 do
				local card = lcard[k]
				local rect = card:getBoundingBox()
				--[[
				-- get rect manually
				local cx, cy = card:getPosition()
				local size = card:getContentSize()
				local scale = card:getScale()
				local width = size.width * scale
				local height = size.height * scale
				local rect = cc.rect(cx-width/2, cy-height/2, width, height)
				]]--
				if true == cc.rectContainsPoint(rect, cc.p(x, y)) then
					--print(string.format("x[%f],y[%f]", x, y))
					--print(string.format("rect [%f][%f],[%f][%f]: ", rect.x, rect.y, rect.width, rect.height))
					--print("name: ", card._card._name, s, t)
					local layer = LayerShow.new({ 
						layerMain = self,
						cardSprite = card,
						phase = self._phase,
						side = s,
						callback = function(...)
							self:callbackFromShow(...)
						end,
					})
					self:addChild(layer, ZORDER_SHOW)
					isHit = true
					break
				end
			end
			if true == isHit then
				break
			end
		end
		if true == isHit then
			break
		end
	end
end

function LayerMain:removeCardInfoByIndex(uniIndex)
	local tbSide = { SIDE_DOWN, SIDE_UP }
	local tbTable = { HERO, ALLY, SUPPORT, DECK, GRAVE, HAND }
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t = tbTable[j]
			local lcard = self._listCard[s][t].lcard
			for k = 1, #lcard do
				local card = lcard[k]
				local index = card:getUniIndex()
				if index == uniIndex then
					table.remove(lcard, k)
					card:removeFromParent(true)
					return
				end
			end
		end
	end
end

function LayerMain:getCardInfoByIndex(uniIndex)
	local tbSide = { SIDE_DOWN, SIDE_UP }
	local tbTable = { HERO, ALLY, SUPPORT, DECK, GRAVE, HAND }
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t = tbTable[j]
			local lcard = self._listCard[s][t].lcard
			for k = 1, #lcard do
				local card = lcard[k]
				local index = card:getUniIndex()
				if index == uniIndex then
					return {
						side = s,
						table = t,
						index = k,
						card = card,
					}
				end
			end
		end
	end
	return {}
end

function LayerMain:getCardSideTableByIndex(uniIndex)
	local tbSide = { SIDE_DOWN, SIDE_UP }
	local tbTable = { HERO, ALLY, SUPPORT, DECK, GRAVE, HAND }
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t = tbTable[j]
			local lcard = self._listCard[s][t].lcard
			for k = 1, #lcard do
				local card = lcard[k]
				local index = card:getUniIndex()
				if index == uniIndex then
					return s, t
				end
			end
		end
	end
	return nil, nil
end

function LayerMain:addCmd(cmd)
	table.insert(self._bcListCmd, cmd)
	table.insert(self._listCmd, cmd)
end

function LayerMain:cmdToAnim(cmd)
	self:addAnim()
	local list = GameTool:csplit(cmd, " ")
	local action = list[1]
	if "deal" == action then
		local fromSide = list[2]
		local fromTable = DECK
		local fromLcard = self._listCard[fromSide][fromTable].lcard
		if 0 == #fromLcard then
			cclog("cmdToAnim side[%s] no card in deck", 
				side==SIDE_DOWN and "down" or "up"
			)
			self:removeAnim()
			return
		end
		local fromIndex = #fromLcard
		local card = fromLcard[fromIndex]
		local toSide = fromSide
		local toTable = HAND
		local toIndex = #(self._listCard[toSide][toTable].lcard) + 1
		local fromInfo = {
			side = fromSide, table = fromTable, index = fromIndex
		}
		local toInfo = {
			side = toSide, table = toTable, index = toIndex
		}
		local action = self:moveCard(fromInfo, toInfo, function()
			self:removeAnim()
		end)
		card:runAction(action)
		return
	elseif "sacrifice" == action then
		local srcCardIndex = tonumber(list[2])
		local side = list[3]
		local fromInfo = self:getCardInfoByIndex(srcCardIndex)
		local card = fromInfo.card
		local label = self._labelRes[side].label
		local x, y = label:getPosition()
		local list = {}
		table.insert(list, cc.MoveTo:create(1, cc.p(x, y)))
		table.insert(list, cc.CallFunc:create(function()
			self:removeCardInfoByIndex(srcCardIndex)
			self:sortCardSprite(side, HAND)
			self:updateRes(side, 0, 1)
			self:removeAnim()
		end))
		card:runAction(cc.Sequence:create(list))
		return
	elseif "move" == action then
		local srcCardIndex = tonumber(list[2])
		local toSide = list[3]
		local toTable = list[4]
		local toIndex = #(self._listCard[toSide][toTable].lcard) + 1
		local fromInfo = self:getCardInfoByIndex(srcCardIndex)
		local card = fromInfo.card
		local toInfo = {
			side = toSide, table = toTable, index = toIndex
		}
		local action = self:moveCard(fromInfo, toInfo, function()
			self:removeAnim()
		end)
		card:runAction(action)
		return
	elseif "next" == action then
		local phase = list[2]
		self:removeAnim()
		if "sacrifice" == phase then
			self._phase = PHASE_SACRIFICE
		elseif "play" == phase then
			self._phase = PHASE_PLAY
		else -- "WAIT"
		end
		self:nextStep()
		return
	elseif "skip" == action then
		self:removeAnim()
		self._phase = PHASE_PLAY
		self:nextStep()
		return
	elseif "done" == action then
		self:removeAnim()
		if self._side == SIDE_DOWN then
			self._side = SIDE_UP
		else
			self._side = SIDE_DOWN
		end
		self._phase = PHASE_WAIT
		self:nextStep()
		return
	elseif "attack" == action then
		local attacker = self:getCardInfoByIndex(tonumber(list[2]))
		local defender = self:getCardInfoByIndex(tonumber(list[3]))
		--print('list: ', list[2], list[3])
		self:attackHit(attacker, defender, function()
			self:removeAnim()
		end)
	end
	self:removeAnim()
end

function LayerMain:callbackFromShow(event, side, phase, cardSprite)
	if "sacrifice" == event then
		local srcIndex = cardSprite:getUniIndex()
		local cmd = string.format("sacrifice %d %d", srcIndex, side)
		self:addCmd(cmd)
		self:addCmd("next play")
		return
	end
	if "use" == event then
		local srcIndex = cardSprite:getUniIndex()
		local srcCtype = cardSprite._card._ctype
		local srcSide, srcTable = self:getCardSideTableByIndex(srcIndex)
		if srcCtype == CARD_TYPE_ALLY then
			local cmd = string.format("move %d %d %d", srcIndex, srcSide, ALLY)
			self:addCmd(cmd)
		end
		return
	end
	if "attack" == event then
		local target = cardSprite._card._target or {}
		local list = {}
		for i = 1, #target do
			local tside = target[i][1]
			local ctype = target[i][2]
			local sside = side
			if tside == TARGET_OPPOSITE then
				sside = getOppoSide(sside)
			end
			local ttable
			if ctype == CARD_TYPE_HERO then
				ttable = HERO
			elseif ctype == CARD_TYPE_ALLY then
				ttable = ALLY
			end
			if nil ~= ttable then
				local l = self._listCard[sside][ttable].lcard or {}
				for j = 1, #l do
					local card = l[j]
					table.insert(list, card)
				end
			end
		end
		for i = 1, #list do
			local card = list[i]
			addTargetMark(card)
		end
		print('target count: ', #target)
		self._srcCard = cardSprite
		self:resetTargetList()
		--local srcIndex = cardSprite:getUniIndex()
		--addTargetMark(cardSprite)
		return
	end
	if "target" == event then
		addTargetMark(cardSprite, true)
		local count = self:addToTargetList(cardSprite)
		local targetCount = self._srcCard._card._targetCount
		local hasMore = self:hasMoreMarkCard(TAG_MARK_TARGET)
		--print('hasMore: ', hasMore, self._srcCard._card._targetCount)
		if count == targetCount or (count > 1 and false == hasMore) then
			self:triggerCardAttack()
		end
		return
	end
end

function LayerMain:triggerCardAttack()
	local src = self._srcCard
	local listTarget = self._listTarget
	if nil == src._card._triggerAttack then
		return
	end
	local cmd = src._card._triggerAttack(src, listTarget)
	print("cmd: ", cmd)
	--local list = GameTool:csplit(cmd, " ")
	self:addCmd(cmd)
end

function LayerMain:hasMoreMarkCard(tagMark)
	local tbSide = { SIDE_DOWN, SIDE_UP }
	local tbTable = { HERO, ALLY, SUPPORT, DECK, GRAVE, HAND }
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t = tbTable[j]
			local lcard = self._listCard[s][t].lcard
			for k = 1, #lcard do
				local card = lcard[k]
				if nil ~= card:getChildByTag(tagMark) then
					return true
				end
			end
		end
	end
	return false
end

function LayerMain:resetTargetList()
	self._listTarget = {}
end

function LayerMain:addToTargetList(cardSprite)
	table.insert(self._listTarget, cardSprite)
	return #self._listTarget
end

function LayerMain:addAnim()
	self._isAnimating = self._isAnimating + 1
end

function LayerMain:removeAnim()
	self._isAnimating = self._isAnimating - 1
	if 0 == self._isAnimating then
		self:showValidCard()
	end
end

function LayerMain:showValidCard()
	local side = self._side
	local phase = self._phase
	local tbSide = {
		SIDE_DOWN, SIDE_UP
	}
	local tbTable = { 
		HERO, ALLY, SUPPORT, GRAVE, DECK, HAND
	}
	for i = 1, #tbSide do
		local s = tbSide[i]
		for j = 1, #tbTable do
			local t = tbTable[j]
			local l = self._listCard[s][t].lcard
			for k = 1, #l do
				local card = l[k]
				local ctype = card._card._ctype
				local isValid = false
				if side ~= s then
				elseif phase == PHASE_SACRIFICE then
					if t == HAND then
						isValid = true
					end
				elseif phase == PHASE_PLAY then
					if t == HAND then
						local cost = card._card._cost
						local res = self._labelRes[s].res
						if res >= cost and ctype == CARD_TYPE_ALLY then
							isValid = true
						end
					elseif t == ALLY then
						isValid = true
					end
				end
				addValidMark(card, not isValid)
			end
		end
	end
end

function LayerMain:update(delta)
	if 0 < self._isAnimating then
		return
	end
	if 0 == #self._listCmd then
		return
	end
	local cmd = self._listCmd[1]
	table.remove(self._listCmd, 1)
	self:cmdToAnim(cmd)
	--self:unscheduleUpdate()
end

function LayerMain:updateRes(side, offset, maxOffset)
	local info = self._labelRes[side]
	info.res = info.res + offset
	info.resMax = info.resMax + maxOffset
	info.label:setString(string.format("%d\n/\n%d", info.res, info.resMax))
end

function LayerMain:moveCard(fromInfo, toInfo, callback)
	local fromSide = fromInfo.side
	local fromTable = fromInfo.table
	local fromIndex = fromInfo.index
	local toSide = toInfo.side
	local toTable = toInfo.table
	local toIndex = toInfo.index

	local fromData = self._listCard[fromSide][fromTable]
	local fromLcard = fromData.lcard
	local fromRect = fromData.rect
	local toData = self._listCard[toSide][toTable]
	local toLcard = toData.lcard
	local toRect = toData.rect

	local csize = self._cardSize

	local card = fromLcard[fromIndex]
	local x, y = card:getPosition()
	local fromPos = cc.p(x, y)
	local toScale = toRect.scale
	local toWidth = csize.width * toScale
	local toGap = self._layerCard:getGap(#toLcard + 1, toWidth, toData.rect.width)
	x = toRect.x + (toIndex - 1) * toGap + 0.5 * toWidth
	y = toRect.y + toRect.height/2
	local toPos = cc.p(x, y)

	local time = 1
	local list = {}
	local subList = {}
	local action = nil
	action = cc.CallFunc:create(function()
		card:setLocalZOrder(ZORDER_CARD+100);
	end)
	table.insert(list, action)
	if fromSide == toSide and fromTable == DECK and toTable == HAND then
		local end_point, control_point_1, control_point_2
		local end_point = epos;
		x = fromPos.x
		if toPos.y <= fromPos.y then
			y = toPos.y - 10
		else
			y = toPos.y + 10
		end
		local control_point_1 = cc.p(x, y)
		x = toPos.x
		if toPos.y <= fromPos.y then
			y = toPos.y - 10
		else
			y = toPos.y + 10
		end
		local control_point_2 = cc.p(x, y)
		local bezier = { control_point_1, control_point_2, toPos };
		action = cc.BezierTo:create(time, bezier);
	else
		action = cc.MoveTo:create(time, toPos);
	end
	--[[
	if 'ease_in' == efftype then
		action = cc.EaseIn:create(action, time);
	elseif 'ease_out' == efftype then
		action = cc.EaseOut:create(action, time);
	end
	]]--
	table.insert(subList, action)

	action = cc.ScaleTo:create(time, toScale)
	table.insert(subList, action)
	action = cc.Spawn:create(subList)
	table.insert(list, action)
	--[[
	action = cc.CallFunc:create(function()
	end)
	]]--
	action = cc.CallFunc:create(function()
		local card = fromLcard[fromIndex]
		table.remove(fromLcard, fromIndex)
		table.insert(toLcard, toIndex, card)
		local t1 = self:sortCardSprite(fromSide, fromTable)
		local t2 = self:sortCardSprite(toSide, toTable)
		if nil ~= callback then
			performWithDelay(self, function()
				callback()
			end, t1 > t2 and t1 or t2)
		end
	end)
	table.insert(list, action)
	action = cc.Sequence:create(list)
	return action
end

function LayerMain:attackHit(fromInfo, toInfo)
	local attacker = fromInfo.card
	local defender = toInfo.card

	local zorder = defender:getLocalZOrder()
	defender:setLocalZOrder(zorder)
	attacker:setLocalZOrder(zorder+1)
	local ax, ay = attacker:getPosition()
	local ascale = attacker:getScale()
	local dx, dy = defender:getPosition()
	local dscale = defender:getScale()
	local gh = 1
	local gv = 1
	if ay > dy then
		gh = -1
	end
	if ax > dx then
		gv = -1
	end
	local action, array, sarray
	array = {}
	sarray = {}
	action = cc.ScaleTo:create(0.2, ascale + 0.05)
	table.insert(sarray, action)
	action = cc.MoveTo:create(0.2, cc.p(ax-gv, ay-gh*15))
	table.insert(sarray, action)
	action = cc.Spawn:create(sarray)
	table.insert(array, action)
	action = cc.ScaleTo:create(0.1, ascale + 0.03)
	table.insert(array, action)

	sarray = {}
	action = cc.ScaleTo:create(0.2, ascale + 0.01)
	table.insert(sarray, action)
	action = cc.MoveTo:create(0.3, cc.p(dx+gv, dy + gh*15))
	table.insert(sarray, action)
	action = cc.Spawn:create(sarray)
	action = cc.EaseOut:create(action, 0.3)
	table.insert(array, action)
	action = cc.CallFunc:create(function()
		local power = attacker._card._power
		self:numChangeEff(defender, defender:getHpLabel(), -power)
	end)
	table.insert(array, action)

	sarray = {}
	action = cc.ScaleTo:create(0.1, ascale)
	table.insert(sarray, action)
	action = cc.MoveTo:create(0.2, cc.p(ax, ay))
	table.insert(sarray, action)
	action = cc.Spawn:create(sarray)
	action = cc.EaseIn:create(action, 0.2)
	table.insert(array, action)
	action = cc.Sequence:create(array)
	attacker:runAction(action)

	array = {}
	sarray = {}
	action = cc.ScaleTo:create(0.2, dscale + 0.05)
	table.insert(array, action)
	action = cc.ScaleTo:create(0.1, dscale + 0.03)
	table.insert(array, action)
	action = cc.DelayTime:create(0.2)
	table.insert(array, action)

	sarray = {}
	action = cc.ScaleTo:create(0.1, dscale + 0.01)
	table.insert(sarray, action)
	action = cc.MoveTo:create(0.2, cc.p(dx+gv*15*2, dy + gh*15*2))
	table.insert(sarray, action)
	action = cc.Spawn:create(sarray)
	action = cc.EaseOut:create(action, 0.2)
	table.insert(array, action)
	action = cc.CallFunc:create(function()
		local power = defender._card._power
		self:numChangeEff(attacker, attacker:getHpLabel(), -power)
	end)
	table.insert(array, action)

	sarray = {}
	action = cc.ScaleTo:create(0.1, dscale)
	table.insert(sarray, action)
	action = cc.MoveTo:create(0.1, cc.p(dx, dy))
	table.insert(sarray, action)
	action = cc.Spawn:create(sarray)
	action = cc.EaseIn:create(action, 0.1)
	table.insert(array, action)
	action = cc.Sequence:create(array)
	defender:runAction(action)
end

function LayerMain:numChangeEff(card, desc, offset)
	if 0 == offset then return end
	local pos = cc.p(card:getPositionX(), card:getPositionY())
	local size = card:getContentSize()
	local scale = card:getScaleX()
	pos.x = pos.x - size.width*scale/2
	pos.y = pos.y - size.height*scale/2
	local sx = desc:getPositionX()
	local sy = desc:getPositionY()
	pos.x = pos.x + sx * scale
	pos.y = pos.y + sy * scale
	local label = GameTool:addLabelOutline(self, offset, TTF_DEFAULT, 30, pos, C4B_WHITE, C4B_BLACK, 4, ANCHOR_CENTER_CENTER, ZORDER_EFFECT)

	pos.y = pos.y + 40
	local actions = {}
	table.insert(actions, cc.EaseOut:create(cc.MoveTo:create(0.5, pos), 0.5))
	table.insert(actions, cc.CallFunc:create(function()
		card:changeHp(offset)
	end));
	table.insert(actions, cc.CallFunc:create(cleanSprite))
	label:runAction(cc.Sequence:create(actions))
end

function LayerMain:sortCardSprite(side_, table_)
	local time = 0.2
	local csize = self._cardSize
	local data = self._listCard[side_][table_]
	local lcard = data.lcard
	local rect = data.rect
	local scale = rect.scale
	local cwidth = csize.width * scale
	local gap = self._layerCard:getGap(#lcard, cwidth, rect.width)
	for i = 1, #lcard do
		local card = lcard[i]
		local x = card:getPositionX()
		x = rect.x + (i - 1) * gap + 0.5 * cwidth
		local y = card:getPositionY()
		local list = {}
		local action = cc.MoveTo:create(time, cc.p(x, y))
		table.insert(list, action)
		action = cc.CallFunc:create(function()
			self._layerCard:setCardZOrder(card, i)
		end)
		table.insert(list, action)
		card:runAction(cc.Sequence:create(list))
	end
	return time
end
-- ============== LAYER MAIN END   =================

-- ============== LAYER ANIM START =================
LayerAnim = class("LayerAnim", 
	function(data)
		local obj = Layer.new({ isSwallow = false })
		return obj
	end
)

function LayerAnim:ctor(...)
	GameTool:addLayerColor(self, cc.c4b(0, 0, 0, 100), 0, 10)
end

function LayerAnim:onTouchBegan(x, y)
	print("LayerAnim:onTouchBegan()")
	return true
end

function LayerAnim:onTouchMoved(x, y)
	print("LayerAnim:onTouchMoved()")
end

function LayerAnim:onTouchEnded(x, y)
	print("LayerAnim:onTouchEnded()")
end
-- ============== LAYER ANIM END   =================

-- ============== LAYER SHOW START =================
LayerShow = class("LayerShow", 
	function(data)
		local obj = Layer.new({ isSwallow = true })
		obj._layerMain = data.layerMain
		obj._cardSprite = data.cardSprite
		obj._phase = data.phase
		obj._side = data.side
		obj._callback = data.callback
		obj._isTarget = nil
		return obj
	end
)

function LayerShow:ctor(...)
	GameTool:addLayerColor(self, cc.c4b(0, 0, 0, 100), 0, 10)

	if nil ~= self._cardSprite then
		if nil ~= self._cardSprite:getChildByTag(TAG_MARK_TARGET) then
			self._isTarget = true
		end
		local sprite = self._cardSprite:clone()
		sprite:setUniIndex(0)
		sprite:setAnchorPoint(ANCHOR_CENTER_CENTER)
		sprite:setPosition(cc.p(__G__vSize.width/2, __G__vSize.height/2))
		self:addChild(sprite, 10)

		self:showBtn()
	end
end

function LayerShow:onTouchBegan(x, y)
	print("LayerShow:onTouchBegan()")
	return true
end

function LayerShow:onTouchMoved(x, y)
	print("LayerShow:onTouchMoved()")
end

function LayerShow:onTouchEnded(x, y)
	print("LayerShow:onTouchEnded()")
	self:close()
end

function LayerShow:close()
	self:removeFromParent(true)
end

function LayerShow:showBtn()
	local ctype = self._cardSprite._card._ctype
	local cIndex = self._cardSprite:getUniIndex()
	local cSide, cTable = self._layerMain:getCardSideTableByIndex(cIndex)
	if self._phase == PHASE_SACRIFICE then
		if cTable ~= HAND then return end
		self:showSacrificeBtn()
		return
	end
	if self._phase ~= PHASE_PLAY then return end
	if true == self._isTarget then
		self:showTargetBtn()
		return
	elseif cTable == HAND then
		if ctype == CARD_TYPE_ALLY then
			self:showUseBtn()
			return
		end
		return
	end
	if cTable == ALLY then
		self:showAttackBtn()
		return
	end
end

function LayerShow:showSacrificeBtn()
	local function callback()
		if nil == self._callback then 
			self:close()
			return
		end
		self._callback("sacrifice", self._side, self._phase, self._cardSprite)
		self:close()
		return
	end
	local items = {}
	local item
	local label = GameTool:createLabelConfig("sacrifice", TTF_DEFAULT, 50)
	--label:setTextColor(C4B_WHITE)
	local pos = cc.p(__G__vSize.width/2, 80)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, callback)
	GameTool:addMenu(self, items, 500)
end

function LayerShow:showUseBtn()
	local function callback()
		if nil == self._callback then 
			self:close()
			return
		end
		self._callback("use", self._side, self._phase, self._cardSprite)
		self:close()
		return
	end
	local items = {}
	local item
	local label = GameTool:createLabelConfig("use", TTF_DEFAULT, 50)
	--label:setTextColor(C4B_WHITE)
	local pos = cc.p(__G__vSize.width/2, 80)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, callback)
	GameTool:addMenu(self, items, 500)
end

function LayerShow:showAttackBtn()
	local function callback()
		if nil == self._callback then 
			self:close()
			return
		end
		self._callback("attack", self._side, self._phase, self._cardSprite)
		self:close()
		return
	end
	local items = {}
	local item
	local label = GameTool:createLabelConfig("attack", TTF_DEFAULT, 50)
	--label:setTextColor(C4B_WHITE)
	local pos = cc.p(__G__vSize.width/2, 80)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, callback)
	GameTool:addMenu(self, items, 500)
end

function LayerShow:showTargetBtn()
	local function callback()
		if nil == self._callback then 
			self:close()
			return
		end
		self._callback("target", self._side, self._phase, self._cardSprite)
		self:close()
		return
	end
	local items = {}
	local item
	local label = GameTool:createLabelConfig("target", TTF_DEFAULT, 50)
	--label:setTextColor(C4B_WHITE)
	local pos = cc.p(__G__vSize.width/2, 80)
	item = GameTool:addItemLabel(items, label, pos, ANCHOR_CENTER_CENTER, callback)
	GameTool:addMenu(self, items, 500)
end
-- ============== LAYER SHOW END   =================

_G["SceneBattle"] = SceneBattle

