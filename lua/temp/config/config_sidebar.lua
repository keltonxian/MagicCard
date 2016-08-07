require("base/ScrollLayer")

local _tagLock = 10087

--[[
return a ScrollLayer instance which has the following new methods:

- clear()  -- remove all items

- addItem(image, tag, onClick, attrs)  -- create a Layer instance then insert into the next position of the scrolling sidebar
										  onClick is a callback function with 1 argument (the sender, Layer instance);
                                          attrs is an optional table to set extra attributes of the item button.
										  NOTE: the first call inserts at the lowest position, the last call for the top most position

- addSubLayer(subLayer, tag, onClick, attrs)   -- same as above except the first argument: it should be a Layer instance

- scanThroughAnimate(delay, duration)  -- animate to scan through the sidebar
]]
local function createSidebar(width, height, centerXOffset, buttonYPadding, noScaleOnClick, noSoundOnClick)
	local layer = ScrollLayer.create()

	layer:setContentSize(width, height)
	layer.paginated = false
	layer.direction = SCROLL_DIRECTION_VERTICAL
	layer:setupScroll()

	layer.adapterItemSize = false

	layer.imageLock = nil

	function layer:clear()
		self.container:removeAllTouchResponders()
		self.container:removeAllChildrenWithCleanup(true)
		self.totalItems = 0
		self.totalItemHeight = 0
		self.lastItemSelected = nil
		self.container:setContentSize(self:getContentSize())
	end

	function layer:addItem(image, tag, onClick, attrs, locked)
		print('image: ', image)
		local item = SpriteLayer.create(image)
		self:addSubLayer(item, tag, onClick, attrs, locked)
	end

	function layer:addSubLayer(subLayer, tag, onClick, attrs, locked)
		local item = subLayer

		if locked then
			local l = CCSprite:create(self.imageLock or "tools/lock.png")
			local s = l:getContentSize()
			l:setPosition(item:getContentSize().width - s.width / 2 - 10, s.height / 2)
			item:addChild(l, 100, _tagLock)
		end

		if not self.totalItems then
			self.totalItems = 0
		end

		if not self.totalItemHeight then
			self.totalItemHeight = 0
		end

		local containerSize = self.container:getContentSize()
		local itemSize = item:getContentSize()
		item.scaleOrigin = 1.0
		
		if self.adapterItemSize then
			--图标大小适配
			local _maxItemWidth = self.maxItemWidth or 100
			local _minItemHeight = self.minItemHeight or 75
			local _scale = 1.0
			if itemSize.width > _maxItemWidth then
				_scale = _maxItemWidth/itemSize.width
				local _spLock = item:getChildByTag(_tagLock)
				if _spLock then
					--锁的大小保持不变
					_spLock:setScale(1/_scale)
				end
			end
			item.scaleOrigin = _scale
			item:setScale(_scale)
			itemSize = item:boundingBox().size
			if itemSize.height < _minItemHeight then
				itemSize.height = _minItemHeight
			end
		end	

		self.totalItemHeight = self.totalItemHeight + itemSize.height + buttonYPadding
		self.totalItems = self.totalItems + 1

		self.container:setContentSize(containerSize.width, self.totalItemHeight)
		containerSize.height = self.totalItemHeight

		item:setPosition(self:getContentSize().width / 2 + centerXOffset, self.totalItemHeight - buttonYPadding - itemSize.height / 2)

		item.touchBeganHandler = function(s, x, y)
			s._totalMoveY = 0  -- assuming the sidebar is vertical always
			s._lastTouch = ccp(x, y)
		end

		item.touchMovedHandler = function(s, x, y)
			s._totalMoveY = s._totalMoveY + math.abs(y - s._lastTouch.y)
			s._lastTouch = ccp(x, y)
		end

		item.touchEndedHandler = function(s, x, y)
			local touchMoveThreshold = __G__iOSValue2(20, 40)

			if s._totalMoveY > touchMoveThreshold then
				return
			end

			if self.lastItemSelected and not noScaleOnClick then
				self.lastItemSelected:setScale(self.lastItemSelected.scaleOrigin)
			end

			if not noScaleOnClick then
				s:setScale(s.scaleOrigin*1.2)
			end
			self.lastItemSelected = s

			-- adjust the scroll position if needed
			local itemOffsetLow = s:getPositionY() - s:getContentSize().height / 2 - buttonYPadding
			local itemOffsetHigh = s:getPositionY() + s:getContentSize().height / 2 + buttonYPadding

			local viewSize = self:getContentSize()
			local scrollOffset = -self.scrollView:getContentOffset().y 

			local newOffset = nil

			if itemOffsetLow < scrollOffset then
				newOffset = -itemOffsetLow
			elseif itemOffsetHigh > scrollOffset + viewSize.height then
				newOffset = -scrollOffset - (itemOffsetHigh - scrollOffset - viewSize.height)
			end

			if newOffset then
				self.scrollView:setContentOffsetInDuration(ccp(0, newOffset), 0.1)
			end

			if not noSoundOnClick then
				local _spLock = item:getChildByTag(_tagLock)
				if _spLock then
				    AudioEngine.playEffect(config_sound_effects.common_popup_open, false)
				else
				    AudioEngine.playEffect(config_sound_effects.common_right_side_icon_click, false)
	        	end
		    end

			onClick(s, x, y)
		end

		if attrs then
			for k, v in pairs(attrs) do item[k] = v end
		end

		self.container:addChild(item, 1, tag)
		self.container:addToTouchResponders(item)

		self.scrollView:setContentOffset(ccp(0, self:getContentSize().height - containerSize.height), false)
	end

	function layer:scanThroughAnimate(delay, duration)
		-- self.scrollView:setContentOffset(ccp(0, 0), false)
		if self.action then
			self:stopAction(self.action)
			self.action = nil
		end
		self.action = performWithDelay(self,
			function() 
				self.scrollView:setContentOffset(ccp(0, 0), false)
				self.scrollView:setContentOffsetInDuration(ccp(0, self:getContentSize().height - self.container:getContentSize().height), duration) 
			end,
			delay
		)
	end

	return layer
end


_G["config_sidebar"] = {
	createSidebar = createSidebar,
}
