module (...,package.seeall)

require "lib/extern"
require "base/SpriteLayer"

local Helper = Helper or class("Helper")

local old_func_SpriteLayer_setSprite = old_func_SpriteLayer_setSprite or SpriteLayer.setSprite
--设置SpriteLayer显示半透明背景
function Helper:set_debug_func_SpriteLayer_setSprite( )
	if true and __G__isMacLuaPlayer then
		function SpriteLayer:setSprite( _sprite )
			old_func_SpriteLayer_setSprite(self, _sprite)

			local sprite = self:getSprite()
			local contentSize = self:getContentSize()
			local tagColorLayer = 1024
			local colorLayer = self:getChildByTag(tagColorLayer)
			if not colorLayer then
				colorLayer = CCLayerColor:create(ccc4(255, 255, 255, 128), contentSize.width, contentSize.height)
				self:addChild(colorLayer, -99999, tagColorLayer)
				colorLayer:ignoreAnchorPointForPosition(false)
			end
			colorLayer:setAnchorPoint(sprite:getAnchorPoint())
			colorLayer:setPosition(sprite:getPosition())
		end
	end
end

function Helper:reset_debug_func_SpriteLayer_setSprite( ... )
	if true and __G__isMacLuaPlayer then
		function SpriteLayer:setSprite( _sprite )
			old_func_SpriteLayer_setSprite(self, _sprite)
		end
	end
end


--position说明：ccp(0,0)为左下角，ccp(0,0.5)为左中，ccp(0,1)为左上角，ccp(0.5,0.5)为居中，等等
function Helper:getAutoPosition( parent, node, position, offsetX, offsetY )
	local _posX,_posY
	local _position = position or ccp(0.5,0.5)
	local _offsetX = offsetX or 0
	local _offsetY = offsetY or 0
	local function getNodeAutoPosition( node )
		local x,y
		local posAnchor = ccp(0,0)
		if not node then
			local size = CCSizeMake(__G__canvasSize.width, __G__canvasSize.height)
			x = __G__canvasOrigin.x + size.width/2 
			y = __G__canvasOrigin.y + size.height/2
		else
			local size = node:boundingBox().size

			posAnchor = node:getAnchorPoint()
			if node:isIgnoreAnchorPointForPosition() then
				posAnchor=ccp(0,0)
			end
			x = size.width*(posAnchor.x-_position.x)
			y = size.height*(posAnchor.y-_position.y)
		end
		-- print("=2=======================================================")
		-- cclog("==========posAnchor:%.2f,%.2f-------->",posAnchor.x,posAnchor.y)
		-- cclog("getNodeAutoPosition()--->%.2f,%.2f,",x,y)
		-- print("=2=======================================================\n")
		return x,y
	end

	local posAnchor = ccp(0,0)
	if not node then
		_posX,_posY = getNodeAutoPosition(parent)
	else
		local size = CCSizeMake(__G__canvasSize.width, __G__canvasSize.height)
		if parent then
			size = parent:boundingBox().size
		end
		local _xNode, _yNode = getNodeAutoPosition(node)
		local sizeNode = node:boundingBox().size
		_posX = size.width*_position.x + _xNode
		_posY = size.height*_position.y + _yNode

	end
	local pos = ccp(_posX+_offsetX, _posY+_offsetY)
	-- print("=1=======================================================")
	-- cclog("==========posAnchor:%.2f,%.2f-------->",posAnchor.x,posAnchor.y)
	-- cclog("Helper:getAutoPosition()--->%.2f,%.2f,\nparent=%s,node=%s,position=ccp(%.2f,%.2f),offsetX=%.2f,offsetY=%.2f",pos.x, pos.y,tostring(parent), tostring(node), _position.x, _position.y, _offsetX, _offsetY)
	-- print("=1=======================================================\n")
	return pos
end

function Helper:getCenterPos( node )
	
	return self:getAutoPosition(node)
end

function Helper:setNodeToCenter( node, _offsetX, _offsetY, parent )
	local pos = self:getAutoPosition(parent,node,nil,_offsetX,_offsetY)
	
	node:setPosition(pos)
end

function Helper:setNodeToCenterX( node, _offsetX, parent )
	
	local pos = self:getAutoPosition(parent,node,nil,_offsetX)

	node:setPositionX(pos.x)
end

function Helper:setNodeToCenterY( node, _offsetY, parent)
	
	local pos = self:getAutoPosition(parent,node,nil,nil,_offsetY)

	node:setPositionY(pos.y)
end

-- 得到1到n的随机数
function Helper:randI(n)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	return math.random(n)
end

function Helper:winkEyes(closedEyesLayer, enabled)	
	closedEyesLayer:setVisible(not enabled)
	--预先停止动作
	if closedEyesLayer.winkingAction then
		closedEyesLayer:stopAction(closedEyesLayer.winkingAction)
	end

	if enabled then
		local array = CCArray:create()
		array:addObject(CCCallFunc:create(function()
			closedEyesLayer:setVisible(true)
		end))
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCCallFunc:create(function() 
			closedEyesLayer:setVisible(false)
	    end))
	    array:addObject(CCDelayTime:create(4.0))
		array:addObject(CCCallFunc:create(function() 
		    closedEyesLayer:setVisible(false) 
		end))
		array:addObject(CCDelayTime:create(0.1))
		closedEyesLayer.winkingAction = closedEyesLayer:runAction(CCRepeatForever:create(CCSequence:create(array)))
	end

end

function Helper:dropWater( nodeWater )
	local water = nodeWater
	water:setVisible(true)
	local array = CCArray:create()
	array:addObject(CCMoveBy:create(0.5, ccp(0,-10)))
	array:addObject(CCDelayTime:create(1.0))
	array:addObject(CCCallFunc:create(function() 
		water:getSprite():runAction(CCFadeOut:create(1.0))
		
	end))
	array:addObject(CCDelayTime:create(1.5))
	array:addObject(CCMoveBy:create(0.1, ccp(0,10)))
	array:addObject(CCCallFunc:create(function() 
		water:setVisible(false)
		water:getSprite():runAction(CCFadeIn:create(0.0))
		
	end))
	water:runAction(CCSequence:create(array))
end

function Helper:setScratchImage(layer, isScratchOut, scratchImage, needReset)
	layer.scratchOut = isScratchOut
	if layer.scratchSprite then
		layer.scratchSprite:release()
	end
	layer.scratchSprite = CCSprite:create(scratchImage)
	layer.scratchSprite:retain()  -- be released in onExit
	layer:setupScratch()

	if needReset then
		layer:reset()
	end
end

function Helper:setScratchImageByColorRender(layer, isScratchOut, needReset, path, color)
	layer.scratchOut = isScratchOut
	if layer.scratchSprite then
		layer.scratchSprite:release()
	end

	local function renderLayer()
		local s = CCSprite:create(path)
		s:setColor(color)
		local size = s:getContentSize()
		local w, h = size.width, size.height
		local x,  y = s:getPosition()
		s:setPosition(ccp(w/2, h/2))
		local rt = CCRenderTexture:create(w, h, kCCTexture2DPixelFormat_RGBA8888)
		rt:begin()
		s:visit()
		rt:endToLua()
		s:setPosition(ccp(x, y))

		local img = rt:newCCImage()
		local path  = CCFileUtils:sharedFileUtils():getWritablePath().."tmpp.png"
		img:saveToFile(path, false)
		CCTextureCache:sharedTextureCache():removeTextureForKey("tmppp.png")
		local tx = CCTextureCache:sharedTextureCache():addUIImage(img, "tmppp.png")
		img:release()
		local ret = CCSprite:createWithTexture(tx)
		return ret
	end
	layer.scratchSprite = renderLayer()
	layer.scratchSprite:retain()
	layer:setupScratch()

	if needReset then
		layer:reset()
	end
end

function Helper:createParticle()
	local particleLayer = CCLayer:create()

	local starLight = CCParticleSystemQuad:create("particles/starlight.plist")
	starLight:setPosition(__G__visibleCenter.x,__G__iOSValue(836,1050,900))
	particleLayer:addChild(starLight)

	local littlestar = CCParticleSystemQuad:create("particles/littlestar.plist")
	littlestar:setPosition(__G__visibleCenter.x,__G__iOSValue(836,1050,900))
	particleLayer:addChild(littlestar)

	return particleLayer
end

-- tap
function Helper:createTapParticle()
	local particleLayer = CCLayer:create()

	-- local blueEmitter = CCParticleSystemQuad:create("particles/blue-bubble.plist")
	-- blueEmitter:setPosition(0, -30)
	-- particleLayer:addChild(blueEmitter,13,1)

	local pinkEmitter = CCParticleSystemQuad:create("particles/pink-bubble.plist")
	pinkEmitter:setPosition(0, -30)
	particleLayer:addChild(pinkEmitter,13,2)

	
	-- local greenEmitter = CCParticleSystemQuad:create("particles/green-bubble.plist")
	-- greenEmitter:setPosition(0, -30)
	-- particleLayer:addChild(greenEmitter,13,3)

	-- local purpleEmitter = CCParticleSystemQuad:create("particles/purple-bubble.plist")
	-- purpleEmitter:setPosition(0, -30)
	-- particleLayer:addChild(purpleEmitter,13,4)

	function particleLayer:stopAllSystem( ... )
		-- self:getChildByTag(1):stopSystem()
		self:getChildByTag(2):stopSystem()
		-- self:getChildByTag(3):stopSystem()
		-- self:getChildByTag(4):stopSystem()
	end

	function particleLayer:resetAllSystem( ... )
		-- self:getChildByTag(1):resetSystem()
		self:getChildByTag(2):resetSystem()
		-- self:getChildByTag(3):resetSystem()
		-- self:getChildByTag(4):resetSystem()
	end

	return particleLayer
end

function Helper:addScratchLayer(scratchImage, isScratchOut, brushSprite, parentLayer, x, y, z, tag)
	local scratch = ScratchLayer.create()
	scratch.scratchOut = isScratchOut
	scratch.scratchSprite = CCSprite:create(scratchImage)
	scratch.scratchSprite:retain()
	scratch.brushSprite = brushSprite
	scratch:setupScratch(false)
	scratch:reset()
	scratch.isTouchEnabled = true  -- let the touchHit method work

	-- scratch.renderTexture:getSprite():getTexture():setAntiAliasTexParameters()

	local s = scratch:getContentSize()
	scratch:setPosition(x + s.width / 2, y + s.height / 2)

	function scratch:onEnter()
		-- need recreate the scratch image when return from next scene
		if self.scratchSprite == nil and self.scratchImageBackup then
			scratch.scratchSprite = CCSprite:create(scratchImage)
			scratch.scratchSprite:retain()
		end

		ScratchLayer.onEnter(self)
	end

	function scratch:onExit()
		cclog("cleanup the scratch layer (tag %d) on exit", self:getTag())

		self.scratchImageBackup = scratchImage  -- save it in order to recreate it when return from next scene
		self.scratchSprite:release()
		self.scratchSprite = nil

		ScratchLayer.onExit(self)
	end

	parentLayer:addChild(scratch, z, tag)
end

function Helper:addColorLayer( layerParent, rect, zorder, tag, ccc4_color )
	local size = rect.size
	local z = zorder or 999
	local tagColorLayer = tag or 1024
	local _color = ccc4_color or ccc4(255, 255, 255, 255)
	local colorLayer = CCLayerColor:create(_color, size.width, size.height)
	colorLayer:ignoreAnchorPointForPosition(false)
	local posAnchor = layerParent:getAnchorPoint()
	colorLayer:setAnchorPoint(posAnchor)
	colorLayer:setPosition(ccp(rect:getMinX()+size.width*posAnchor.x,rect:getMinY()+size.height*posAnchor.y))
	layerParent:addChild(colorLayer, z, tagColorLayer)
end

function Helper:addDebugColorLayer( layerParent, rect, zorder, tag, ccc4_color )
	if true and __G__isMacLuaPlayer then
		return self:addColorLayer( layerParent, rect, zorder, tag, ccc4_color )
	end
end

function Helper:addNodeColorLayer( node, zorder, tag, ccc4_color, _expandWidth, _expandHeight )
	zorder = zorder or -999
	local rect = self:getRectBySprite( node, _expandWidth, _expandHeight)
	self:addColorLayer(node, rect, zorder, tag, ccc4_color)
end

function Helper:addNodeDebugColorLayer( node, zorder, _expandWidth, _expandHeight )
	if true and __G__isMacLuaPlayer then
		print("***********Helper:addNodeDebugColorLayer**********")
		zorder = zorder or -999
		local rect = self:getRectBySprite( node, _expandWidth, _expandHeight)
		self:addDebugColorLayer(node, rect, zorder, nil, ccc4(0, 255, 255, 128))
	end
end


function Helper:printRect( rect )
	cclog("===================================Rect: ==================================")
	cclog("minX=%d,maxX=%d; minY=%d,maxY=%d; width=%d,height=%d",rect:getMinX(),rect:getMaxX(),rect:getMinY(),rect:getMaxY(),rect.size.width,rect.size.height)
	cclog("===========================================================================")
end

function Helper:getWorldRectBySprite( sprite, _expandWidth, _expandHeight )

	local expandWidth = _expandWidth or 0
	local expandHeight = _expandHeight or 0

	local x,y = sprite:getPosition()
	local worldPos = sprite:getParent():convertToWorldSpace(ccp(x,y))
	local size = sprite:getContentSize()
	local posAnchor = sprite:getAnchorPoint()

	local minX = worldPos.x - size.width*posAnchor.x - expandWidth/2
	local minY = worldPos.y - size.height*posAnchor.y - expandHeight/2
	local rect = CCRectMake( minX, minY, size.width + expandWidth, size.height + expandHeight)

	self:printRect(rect)

	return rect
end

function Helper:getRectBySprite( sprite, _expandWidth, _expandHeight )
	local expandWidth = _expandWidth or 0
	local expandHeight = _expandHeight or 0

	local size = sprite:getContentSize()
	
	local minX = 0 - expandWidth/2
	local minY = 0 - expandHeight/2
	local rect = CCRectMake( minX, minY, size.width + expandWidth, size.height + expandHeight)

	self:printRect(rect)

	return rect
end

function Helper:showDebugSingleToolPointSprite(layerParent, tool)
	if true and __G__isMacLuaPlayer then
		if layerParent then
			if not layerParent.m_attached_brush_spite then
				local _brushSolid = CCSprite:create("dot-large.png")
				local _brushSolidMedium = CCSprite:create("dot-medium.png")
				local _brushSolidSmall = CCSprite:create("dot-small.png")
				local _brushSolidMini = CCSprite:create("dot-mini.png")
				if not _brushSolidMini then
					_brushSolidMini = CCSprite:create("dot-small.png")
					_brushSolidMini:setScale(0.5)
				end

				_brushSolid:setOpacity(30)
				_brushSolidMedium:setOpacity(20)
				_brushSolidSmall:setOpacity(30)
				_brushSolidMini:setOpacity(20)
				
				local _size = _brushSolid:getContentSize()
				local _sprite = SpriteLayer.create(_size.width, _size.height)
		
				local pos = ccp(_size.width/2,_size.height/2)
				_brushSolid:setPosition(pos)
				_brushSolidMedium:setPosition(pos)
				_brushSolidSmall:setPosition(pos)
				_brushSolidMini:setPosition(pos)

				_sprite:addChild(_brushSolid)
				_sprite:addChild(_brushSolidMedium)
				_sprite:addChild(_brushSolidSmall)
				_sprite:addChild(_brushSolidMini)

				layerParent:addChild(_sprite)
				layerParent.m_attached_brush_spite = _sprite
			end
		
			layerParent.m_attached_brush_spite:setPosition(ccp(__G__canvasSize.width/2,__G__canvasSize.height/2))
			layerParent.m_attached_brush_spite:setVisible(false)

			tool:addTouchBeganAction(function ( ... )
			end)

			tool:addTouchMovedAction(function ( ... )
				layerParent.m_attached_brush_spite:setVisible(true)				
				layerParent.m_attached_brush_spite:setPosition(tool.toolPoint)
			end)

			tool:addTouchEndedAction(function ( ... )
				layerParent.m_attached_brush_spite:setVisible(false)
			end)
		end
		
		
	end
end

function Helper:showDebugToolPointSprite( layerParent, layerBench )
	if true and __G__isMacLuaPlayer then	
		print("***********Helper:showDebugToolPointSprite**********")						
		for i=1,#layerBench._toolPages do
			n = 0
			repeat
				n = n+1
				local tool = layerBench:getTool(i,n)
				if tool and tool.canPickUp then
					self:showDebugSingleToolPointSprite(layerParent, tool)
				end
			until tool == nil
		end
	end
end

function Helper:createFullScreenDarkLayer()
    local ret = SpriteLayer.create(__G__canvasSize.width, __G__canvasSize.height)

    local darkLayer = CCLayerColor:create(ccc4( 0, 0, 0, 255 * 0.6), __G__canvasSize.width, __G__canvasSize.height)
    darkLayer:ignoreAnchorPointForPosition(false)
    darkLayer:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)

    ret:addChild(darkLayer, -100)
    return ret
end

function Helper:createAnimateSprite( imageFormat, imageStartNum, imageEndNum, interval, animateCallBackFunc )
	local _sprite = SpriteLayer.create(string.format(imageFormat, imageStartNum))
	local _interval = interval or 0.2
	if _sprite then
		print("=============createAnimateSprite------------->",string.format(imageFormat, imageStartNum))
		local _array = CCArray:create()

		for i=imageStartNum,imageEndNum do
			_array:addObject(CCCallFunc:create(function() 
				_sprite:setSprite(string.format(imageFormat, i))
		    end))
			_array:addObject(CCDelayTime:create(_interval))
		end

		if animateCallBackFunc then
			_array:addObject(CCCallFunc:create(function() 
				animateCallBackFunc()
		    end))
		end
		
		_sprite.displayAction = _sprite:runAction(CCRepeatForever:create(CCSequence:create(_array)))
	end
	return _sprite
end


function Helper:getTableByJsonFile( data_file )
	-- 读取JSON
	local fileData = Utils:getFileData(data_file)
	local aJsonString = fileData:getData()
	local json = require("lib/json")
    local _luaTable = json.decode(aJsonString)
	-- local inspect = require("lib/inspect")
	-- cclog("============getTableByJsonFile-----%s-------->", inspect(_luaTable))
	
	return _luaTable
end

function Helper:createNodeByJsonFile( data_file, imagePrefix, nodeParent )
	local _imagePrefix = imagePrefix or ""
	local _itemDatas = getTableByJsonFile(data_file)
	local _parent = nodeParent or SpriteLayer.create()
	local _items = {}

	for k,v in pairs(_itemDatas) do
		local _item = {}
		_item.x = v.x - v.width/2
		_item.y = v.y - v.height/2
		_item.z = v.z
		_item.tag = v.tag or 0
		_item.touch = -1
		_item.image = _imagePrefix..tostring(k)..".png"
		_item.class = SpriteLayer

		table.insert(_items, _item)
	end

	_parent:layout(_items)

	return _parent
end

function Helper:scaleToCenter( scaleLayer, node, func_callback )
	if not scaleLayer.actionScaleToCenter then
		if not node then
			return
		end

		local _x,_y = node:getPosition()
		local _posWorld = node:getParent():convertToWorldSpace(ccp(_x,_y))
		local _posCenter = self:getCenterPos()
		local _posDist = ccpSub(_posCenter, _posWorld)
			
		local symbolX = 1
		local symbolY = 1

		local offsetX = _posDist.x
		local offsetY = _posDist.y
		
		if offsetX~=0 then
			symbolX = offsetX/math.abs(offsetX)
		end
		if offsetY~=0 then
			symbolY = offsetY/math.abs(offsetY)
		end

		local size = scaleLayer:getContentSize()
		local scale = 2.5	
		--scale 适配
		for i = 1, 20 do
			scale = scale+0.25

			offsetX = _posDist.x*scale
			offsetY = _posDist.y*scale

			local maxOffsetX = size.width/2 * (scale-1)
			local maxOffsetY = size.height/2 * (scale-1)
			
			local _offsetX = symbolX*math.min(math.abs(offsetX), maxOffsetX)
			local _offsetY = symbolY*math.min(math.abs(offsetY), maxOffsetY)
			
			if _offsetX==offsetX and _offsetY==offsetY then
				break
			end
		end

		cclog("======Helper:scaleToCenter()----->scale:%.2f",scale)

		local scaleX, scaleY = scaleLayer:getScaleX(), scaleLayer:getScaleY()
		
		local array = CCArray:create()
		array:addObject(CCScaleTo:create(0.5, scaleX*scale, scaleY*scale))
		array:addObject(CCMoveBy:create(0.5, ccp(offsetX,offsetY)))

		
		local callback = func_callback or function() end
		-- local callback = function() end
		local seq = CCArray:create()
		seq:addObject(CCSpawn:create(array))
		seq:addObject(CCCallFunc:create(callback))

		scaleLayer.actionScaleToCenter = scaleLayer:runAction(CCSequence:create(seq))

		scaleLayer.originScaleX = scaleX
		scaleLayer.originScaleY = scaleY

		scaleLayer.scaleOffsetX = offsetX
		scaleLayer.scaleOffsetY = offsetY

	else
		cclog("======Already scale to center:scaleX=%.2f,scaleY=%.2f======",scaleLayer:getScaleX(), scaleLayer:getScaleY())

		scaleLayer:stopAction(scaleLayer.actionScaleToCenter)
		scaleLayer.actionScaleToCenter = nil

		local array = CCArray:create()
		array:addObject(CCScaleTo:create(0.5, scaleLayer.originScaleX, scaleLayer.originScaleY))
		array:addObject(CCMoveBy:create(0.5, ccp(-scaleLayer.scaleOffsetX,-scaleLayer.scaleOffsetY)))
		scaleLayer:runAction(CCSpawn:create(array))
	end
	
end
----------------------------------------------------------------------------

--全局Helper唯一实例
local s_instHelper = s_instHelper or nil
function getHelperInstance( ... )
	if not s_instHelper then
		s_instHelper = Helper.new()
		Helper.new = function ( ... )
			error("\"Helper\" 为全局单例类，外部无法使用\"new()\"创建新对象")
		end
	end
	return s_instHelper
end
_G["Helper"] = getHelperInstance()
