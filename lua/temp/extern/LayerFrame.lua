module (...,package.seeall)

require "lib/extern"
require "base/SpriteLayer"

local LayerFrame = LayerFrame or class("LayerFrame",
	function ( width, height, imgStencil, bShowStencil )

		local _spriteStencil = nil
		if imgStencil then
			_spriteStencil = CCSprite:create(imgStencil)
			if _spriteStencil then
				if not width and not height then 
					local _size = _spriteStencil:getContentSize()
					width = _size.width
					height = _size.height
				end
			end
		end

		local obj = SpriteLayer.create(width, height)	
		obj.autosize = false
		
		local function updateNode( node )
			node:ignoreAnchorPointForPosition(false)
		    node:setAnchorPoint(ccp(0.5, 0.5)) 
			node:setPosition(ccp(width/2, height/2))
		end

		local _stencil = nil
		if imgStencil then
			_stencil = SpriteLayer.create(imgStencil)
		else
			_stencil = CCLayerColor:create(ccc4(255,255,255,255), width, height)
		end

		local _node = CCClippingNode:create()
		_node:setContentSize(CCSizeMake(width, height))
		_node:setStencil(_stencil)
		_node:setAlphaThreshold(1)
		_node:setInverted(false)

		if bShowStencil and _spriteStencil then
			_node:addChild(_spriteStencil, -1)
			updateNode(_spriteStencil)
		end

		local _container = SpriteLayer.create(width, height)
		_node:addChild(_container, 1)

		obj:addChild(_node, 1)
		obj.m_container = _container
		obj.m_clippingNode = _node

		updateNode(obj)
		updateNode(_node)
		updateNode(_container)
		updateNode(_stencil)

		return obj

	end
)

function LayerFrame:ctor( ... )
	self:addBackground()
	self:showLayerColor(false)

end

function LayerFrame:setInverted( ... )
	return self.m_clippingNode:setInverted( ... )
end

function LayerFrame:setAlphaThreshold( ... )
	return self.m_clippingNode:setAlphaThreshold( ... )
end

function LayerFrame:addBackground( ... )
	if true and __G__isMacLuaPlayer then
		print("================LayerFrame:addBackground()=================")
		local _size = self:getContentSize()	
		local _posAnchor = self:getAnchorPoint()
		
		local _colorLayer = CCLayerColor:create(ccc4(0, 255, 0, 20), _size.width, _size.height)
		_colorLayer:ignoreAnchorPointForPosition(false)
		_colorLayer:setAnchorPoint(_posAnchor)
		_colorLayer:setPosition(ccp(_size.width*_posAnchor.x, _size.height*_posAnchor.y))
		self:addChild(_colorLayer, -999)

		self.m_layerColorBackground = _colorLayer
	end
end

function LayerFrame:showLayerColor( show )
	if self.m_layerColorBackground then
		print("================LayerFrame:showLayerColor()=================",show)
		self.m_layerColorBackground:setVisible(show)
	end
end

_G["LayerFrame"] = LayerFrame