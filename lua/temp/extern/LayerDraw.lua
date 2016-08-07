module (...,package.seeall)

require "lib/extern"
require "base/SpriteLayer"

local LayerDraw = LayerDraw or class("LayerDraw",
	function ( width, height, ... )

		local obj = SpriteLayer.create(width, height)

			obj.m_canvas = nil
			obj.m_brush = nil
			obj.m_eraser = nil
			obj.m_layerColorBackground = nil

			obj.m_posBegin = ccp(0,0)
			obj.m_painted = false
			obj.m_beErase = false

		return obj

	end)

function LayerDraw:ctor( width, height, ... )
	self.m_canvas = CCRenderTexture:create(width, height, kCCTexture2DPixelFormat_RGBA8888)

	self.m_canvas:setAnchorPoint(ccp(0.5,0.5))
	self.m_canvas:setPosition(width/2,height/2)
	self:addChild(self.m_canvas)

	self:addBackground()
	self:showLayerColor(false)
end

function LayerDraw:addBackground( ... )	
	if true and __G__isMacLuaPlayer then
		print("================LayerDraw:addBackground()=================")
		local _size = self:getContentSize()	
		local _posAnchor = self:getAnchorPoint()
		
		local _colorLayer = CCLayerColor:create(ccc4(0, 0, 255, 50), _size.width, _size.height)
		_colorLayer:ignoreAnchorPointForPosition(false)
		_colorLayer:setAnchorPoint(_posAnchor)
		_colorLayer:setPosition(ccp(_size.width*_posAnchor.x, _size.height*_posAnchor.y))
		self:addChild(_colorLayer, -999)

		self.m_layerColorBackground = _colorLayer
	end
end

function LayerDraw:showLayerColor( show )
	if self.m_layerColorBackground then
		print("================LayerDraw:showLayerColor()=================",show)
		self.m_layerColorBackground:setVisible(show)
	end
end

function LayerDraw:onTouchBegan( x, y )
	-- print("===============LayerDraw:onTouchBegan( x, y )------>", x,y)

    local _size = self:getContentSize()
    local _posNode = self:convertToNodeSpace(ccp(x, y))

    self.m_posBegin.x = _posNode.x-(self.m_canvas:getPositionX()-_size.width/2)
    self.m_posBegin.y = _posNode.y-(self.m_canvas:getPositionY()-_size.height/2)

    return SpriteLayer.onTouchBegan(self, x, y)
end

function LayerDraw:onTouchMoved( x, y )
	-- print("===============LayerDraw:onTouchMoved( x, y )------>", x,y)

    local _size = self:getContentSize()
    local _posNode = self:convertToNodeSpace(ccp(x, y))

    local _startP = ccp(0, 0)
    _startP.x = _posNode.x-(self.m_canvas:getPositionX()-_size.width/2)
    _startP.y = _posNode.y-(self.m_canvas:getPositionY()-_size.height/2)

	local _diffX = _startP.x - self.m_posBegin.x
    local _diffY = _startP.y - self.m_posBegin.y

    local _distance = ccpDistance(_startP, self.m_posBegin)

    local _brush = self.m_beErase and self.m_eraser or self.m_brush
    self.m_canvas:begin()
    if _distance > 1 then
        local d = _distance
        local i = 0
        for i = 0, d-1 do
            local difx = self.m_posBegin.x - _startP.x
            local dify = self.m_posBegin.y - _startP.y
            local delta = i / _distance
            _brush:setPosition(ccp(_startP.x + (difx * delta), _startP.y + (dify * delta)))
            if self.m_beErase then
            else
	            _brush:setRotation(math.random(0, 359))
            	local r = math.random(0, 5) / 40.0 + 0.50
	            _brush:setScale( r )
	        end
            _brush:visit()
        end
        self.m_painted = true
    end
    self.m_canvas:endToLua()

    self.m_posBegin.x = _startP.x
    self.m_posBegin.y = _startP.y

    return SpriteLayer.onTouchMoved(self, x, y)
end

function LayerDraw:onTouchEnded( x, y )
	-- print("===============LayerDraw:onTouchEnded( x, y )------>", x,y)

    local _size = self:getContentSize()
    local _posNode = self:convertToNodeSpace(ccp(x, y))

    self.m_posBegin.x = _posNode.x-(self.m_canvas:getPositionX()-_size.width/2)
    self.m_posBegin.y = _posNode.y-(self.m_canvas:getPositionY()-_size.height/2)


	return SpriteLayer.onTouchEnded(self, x, y)
end

function LayerDraw:onExit( ... )
	if self.m_brush then
		self.m_brush:release()
		self.m_brush = nil
	end
	if self.m_eraser then
		self.m_eraser:release()
		self.m_eraser = nil
	end

	return Layer.onExit(self, ...)
end

function LayerDraw:setBrush( sprite )
	if self.m_brush then
		self.m_brush:release()
		self.m_brush = nil
	end

	if type(sprite) == "string" then
		sprite = CCSprite:create(sprite)
	end

	sprite:retain()
	self.m_brush = sprite

	self.m_beErase = false
end

function LayerDraw:setBrushColor( color )
	self.m_brush:setColor(color)
	self.m_beErase = false
end

function LayerDraw:getBrush( ... )
	return self.m_brush
end

function LayerDraw:setEraser( sprite )
	if self.m_eraser then
		self.m_eraser:release()
		self.m_eraser = nil
	end

	if type(sprite) == "string" then
		sprite = CCSprite:create(sprite)
	end

	local bf = ccBlendFunc()
    bf.src = GL_ZERO
    bf.dst = GL_ONE_MINUS_SRC_ALPHA
    sprite:setBlendFunc(bf)

	sprite:retain()
	self.m_eraser = sprite

	self.m_beErase = true
end

function LayerDraw:getEraser( ... )
	return self.m_eraser
end

function LayerDraw:clearCanvas( ... )
	self.m_canvas:clear(0, 0, 0, 0)
	self.m_painted = true
end

function LayerDraw:isPainted( ... )
	return self.m_painted
end

function LayerDraw:configBenchTool( tool, isEarse, color )
	local _layerDraw = self
	tool:addTouchBeganAction(
        function(sender, x, y)
        	if isEarse then
        		-- _layerDraw:setEraser()
        		_layerDraw.m_beErase = true
        	else
        		if color then
        			_layerDraw:setBrushColor(color)
        		else
        			_layerDraw.m_beErase = false
        		end
        	end
            _layerDraw:onTouchBegan(x, y)
        end
    )

    tool:addTouchMovedAction(
        function(sender, x, y)
            _layerDraw:onTouchMoved(sender.toolPoint.x, sender.toolPoint.y)
        end
    )

    tool:addTouchEndedAction(
        function(sender, x, y)
            _layerDraw:onTouchEnded(x, y)
            _layerDraw.m_beErase = false
        end
    )
end

-- 合成图片
function LayerDraw:saveToImage( fileName )
    local _fullPath = CCFileUtils:sharedFileUtils():getWritablePath()..fileName
    cclog("===========LayerDraw:saveToImage()---->:%s",_fullPath)
    local image = self.m_canvas:newCCImage()
    if image:saveToFile(_fullPath,false) then
        cclog("==========save %s Succeed!==========",fileName)
    else
        cclog("==========save %s Fail!==========",fileName)
    end
end

_G["LayerDraw"] = LayerDraw