module (...,package.seeall)

-- require("lib/extern")

local s_disX = __G__iOSValue2(30, 30)
-- local s_posX = __G__iOSValue2(0, 0)
-- local s_posY = __G__iOSValue2(100, 90) + 10
-- local s_width = __G__canvasSize.width
-- local s_height = __G__canvasSize.height

LayerIndicator = class("LayerIndicator", 
	function (...)
		local obj = Layer.create()
		return obj
	end)

LayerIndicator.__index = LayerIndicator

function LayerIndicator:ctor(page)
	self:setContentSize(CCSize(self.width, self.height))

	self.page = page

	self:init()
end

function LayerIndicator:init()

	local comm_indicator = {}
	local curr_indicator = {}

	local width = self:getContentSize().width

	for i = 1, self.page do
		local sp1 = CCSprite:create("indicator/p1.png")
		local sp2 = CCSprite:create("indicator/p2.png")
		local s_w = sp1:getContentSize().width
		local w = s_w * self.page + s_disX * (self.page - 1)
		-- print("========= width, w --------> ", width, w, (width - w)/2 + s_w/2 * i + s_disX * (i - 1))
		self:addChild(sp1)
		self:addChild(sp2)
		sp1:setPosition(ccp((width - w)/2 + s_w/2 * (2*i-1) + s_disX * (i - 1) + self.posX, self.posY))
		sp2:setPosition(ccp((width - w)/2 + s_w/2 * (2*i-1) + s_disX * (i - 1) + self.posX, self.posY))
		table.insert(comm_indicator, sp1)
		table.insert(curr_indicator, sp2)
	end

	self.comm_indicator = comm_indicator
	self.curr_indicator = curr_indicator

	self:showCurrIndicator(1)
end


------------------------
-- bench翻页是调用，默认第一页
------------------------
function LayerIndicator:showCurrIndicator(page)
	page = page or 1
	page = page >= self.page and self.page or page
	for k, v in pairs(self.curr_indicator) do
		v:setVisible(false)
		if page == k then
			v:setVisible(true)
		end
	end
end


------------------------
-- 提供外部调整相应的坐标值
------------------------
function LayerIndicator:setPosition(x, y)
	if self.comm_indicator and self.curr_indicator then
		self:setPositionX(x)
		self:setPositionY(y)
	end
end

function LayerIndicator:setPositionX(posX)
	if self.comm_indicator and self.curr_indicator then
		for i = 1, #(self.comm_indicator) do
			self.comm_indicator[i]:setPositionX(posX + (i - 1) * s_disX)
			self.curr_indicator[i]:setPositionX(posX + (i - 1) * s_disX)
		end
	end	
end

function LayerIndicator:setPositionY(posY)
	if self.comm_indicator and self.curr_indicator then
		for i = 1, #(self.comm_indicator) do
			self.comm_indicator[i]:setPositionY(posY)
			self.curr_indicator[i]:setPositionY(posY)
		end
	end	
end

function LayerIndicator:getPosition()
	if self.comm_indicator and self.comm_indicator[1] then
		return { x = self:getPositionX(), y = self:getPositionY() }
	end
end

function LayerIndicator:getPositionX()
	if self.comm_indicator and self.comm_indicator[1] then
		return self.comm_indicator[1]:getPositionX()
	end
end

function LayerIndicator:getPositionY()
	if self.comm_indicator and self.comm_indicator[1] then
		return self.comm_indicator[1]:getPositionY()
	end
end


------------------------
-- @param page:分页数
-- @param x, y, w, h
-- @param disX:两个圆点指示器的间距
------------------------
function LayerIndicator:create(page, x, y, w, h, disX)
	self.posX = x and x or __G__iOSValue2(0, 0)
	self.posY = y and y or __G__iOSValue2(100, 90) + 10
	self.width = w and w or __G__canvasSize.width
	self.height = h and h or __G__canvasSize.height

	s_disX = disX and disX or s_disX

	local indicator = LayerIndicator.new(page)

	return indicator
end

_G["LayerIndicator"] = LayerIndicator