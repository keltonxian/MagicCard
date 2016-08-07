
--==================================================
--    @Brief:   Spine Layer
--    @Author:  Rios
--    @Date:    2015-09-01
--==================================================

SpineLayer = SpineLayer or class("SpineLayer", function ( ... )
    return Layer.create()
end
)


function SpineLayer:ctor(data_file, atlas_file, scale)
	local spine = Spine:createWithFile(data_file, atlas_file, scale)
	self:addChild(spine, 1)

	self.spine = spine
end

function SpineLayer:touchHit(x, y)
    if not self.isTouchEnabled or not self:isVisible() then
        return false
    end
	local rect = self.spine:boundingBoxOfSpine()
	local localPoint = self:convertToNodeSpace(ccp(x, y))
	local ret = self.spine:boundingBoxOfSpine():containsPoint(self.spine:convertToNodeSpace(ccp(x, y)))
    if ret and not Utils:transparentHitTest(self, localPoint) then
    	if self.touch_call_back then self.touch_call_back(x, y) end

    	return true
    end

    return false
end

function SpineLayer:setSkin(skin_name)
	self.spine:setSkin(skin_name)
end

function SpineLayer:setPosition(point)
	self.spine:setPosition(point)
end

function SpineLayer:getSpine()
	return self.spine
end

function SpineLayer:setTouchCallBack( call_back )
	self.touch_call_back = call_back
end

function SpineLayer:pointInSlot(x, y, slot_name)
	local ret = self.spine:boundingBoxOfSlot(slot_name):containsPoint(self.spine:convertToNodeSpace(ccp(x, y)))
    if ret then
    	return true
    end

    return false
end

function SpineLayer:changeSkinForSlot(skin_name, slot_name)
	self.spine:changeSkinForSlot(skin_name, slot_name)
end

function SpineLayer:switchSlotWithNode(slot_data, index)
	local slot_name = slot_data.slot_name
	local z_order = slot_data.z_order
	local scale = slot_data.scale
	local format = slot_data.format
	local position = slot_data.position
	local rotation = slot_data.rotation
	local spine = self.spine

	spine:setAttachment(slot_name, nil)
	local aSlotNode = spine:getNodeForSlot(slot_name)
	if not aSlotNode then
		spine:setNodeForSlot(slot_name, z_order)
		aSlotNode = spine:getNodeForSlot(slot_name)
	end
	local aSwitchNode = aSlotNode:getChildByTag(1)
	if aSwitchNode then aSlotNode:removeChild(aSwitchNode, true) end
	if index > 0 then
		aSwitchNode = CCSprite:create(string.format(format, index))
		aSwitchNode:setScale(scale)
		aSwitchNode:setPosition(position.x * scale, position.y * scale)
		aSwitchNode:setRotation(-rotation)
		aSlotNode:addChild(aSwitchNode, 1, 1)
	end
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function SpineLayer:test()
end

