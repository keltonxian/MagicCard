module(..., package.seeall)

-- ============== CONSTANT START =================
-- ============== CONSTANT END   =================

-- ============== VAR START =================
local GameTool = nil
-- ============== VAR END   =================

-- ============== GameTool START =================
GameTool = GameTool or class("GameTool") 
-- ============== GameTool END   =================

-- ============== SYS FUNCTION START =================
function GameTool:checkFile(filename)
	local fileUtils = cc.FileUtils:getInstance()
	local isExist = fileUtils:isFileExist(filename)
	if true == isExist then
		return true
	end
	cclog("check_file : file not exist:[%s]", filename)
	return false
end

function GameTool:getPath(filename, default)
	-- 1. check the download folder
	local fileUtils = cc.FileUtils:getInstance()
	if true == self:checkFile(filename) then
		return filename, true
	end
	-- 2. check local folder
	--local unknown = 'image/unknown.png'
	local unknown = default or 'unknown.png'
	if nil ~= default then
		unknown = default
	end
	local isExist = fileUtils:isFileExist(unknown)
	--print('fullpath: ', fullpath);
	if false == isExist then
		cclog("get_path : file not exist: [%s]", filename)
	end
	return unknown, isExist
end

function GameTool:addLayerColor(layer, color, zorder, tag)
	zorder = zorder or 0;
	local layerColor = cc.LayerColor:create(color);
	layer:addChild(layerColor, zorder or 0, tag or 0);
end

function GameTool:scaleFixWidthHeight(sprite, xScale, yScale, isGetSmaller)
	local scale 
	if true == isGetSmaller then
		scale = xScale<yScale and xScale or yScale
	else
		scale = xScale>yScale and xScale or yScale
	end
	if nil ~= sprite then
		sprite:setScale(scale)
	end
	return scale
end

-- delim e.g " " or "[ ]" or "[%.]" or "[%. ]"
function GameTool:csplit(str, delim, count)
	--print('DEBUG csplit str, delim: ', str, delim);
	local result = {}
	if nil == str then
		return result
	end
	count = count or 500 -- max 500 token
	local token

	repeat 
		local s_pos, e_pos = string.find(str, delim)
		if s_pos==nil or e_pos == nil then
			break
		end
		-- print('s_pos = ', s_pos, ' e_pos = ', e_pos)
		token = string.sub(str, 1, s_pos-1)
		if string.len(token) > 0 then
			result[ #result + 1] = token
		end
		str = string.sub(str, e_pos+1) -- missing len means up to full len
		-- print('Result i : ', result[#result], '  str=', str)
		count = count - 1
	until count <= 0

	if string.len(str) > 0 then
		result[ #result + 1] = str
	end
	
	return result
end

function GameTool:space_(str)
	local flag = false
	repeat 
		local spos, epos = string.find(str, ' ')
		if nil == spos or nil == epos then
			flag = true
			break
		end
		local str1 = string.sub(str, 1, spos-1)
		local str2 = string.sub(str, epos+1)
		str = str1 .. '_' .. str2
	until true == flag
	return str
end

function GameToolreplace_str(str, rstr, istr)
	if nil == str or nil == rstr or 0 == string.len(rstr) then
		return str
	end
	istr = istr or ''
	local spos, epos = string.find(str, rstr)
	if nil == spos or nil == epos then
		return str
	end
	if 1 == spos and string.len(str) == epos then
		return istr
	end
	local s1 = string.sub(str, 1, spos-1)
	local s2 = string.sub(str, epos+1, string.len(str))
	local nstr = s1 .. istr .. s2
	return nstr
end
-- ============== SYS FUNCTION END   =================

-- ============== LABEL START =================
function GameTool:createLabelConfig(text, font, size, pos, color, anchorpoint, dimensions, halignment, valignment)
	font = font or TTF_DEFAULT

	-- distanceFieldEnabled should be true if to use glow
	-- if outlineSize > 0 then distanceFieldEnabled will be false
	local ttfConfig = { 
		fontFilePath = font, 
		fontSize = size,
		glyphs = cc.GLYPHCOLLECTION_DYNAMIC,
		customGlyphs = nil,
		distanceFieldEnabled = false,
		outlineSize = 0,
	};
	local label = cc.Label:create()
	label:setTTFConfig(ttfConfig)
	label:setString(text)
	if nil ~= anchorpoint then
		label:setAnchorPoint(anchorpoint)
	end
	if nil ~= pos then
		label:setPosition(pos)
	end
	if nil ~= color then
		label:setTextColor(color)
	end
	if nil ~= dimensions then
		label:setDimensions(dimensions.width, dimensions.height)
	end
	if nil ~= halignment and nil ~= valignment then
		label:setAlignment(halignment, valignment)
	end
	-- e.g --> outline
	-- local outline_color = cc.c4b(0, 0, 255, 255)
	-- local outline_size = 1;
	-- label:enableOutline(outline_color, outline_size);
	-- e.g --> glow
	-- label:enableGlow(cc.c4b(255, 255, 0, 255));

	return label
end

function GameTool:addLabelConfig(layer, text, font, size, pos, color, anchorpoint, zorder, dimensions, halignment, valignment)
	local label = GameTool:createLabelConfig(text, font, size, pos, color, anchorpoint, dimensions, halignment, valignment)
	if nil ~= zorder then
		layer:addChild(label, zorder)
	else
		layer:addChild(label)
	end
	return label
end

function GameTool:addLabelOutline(layer, text, font, size, pos, color, outlineColor, outlineSize, anchorpoint, zorder, dimensions, halignment, valignment)
	local label = GameTool:addLabelConfig(layer, text, font, size, pos, color, anchorpoint, zorder, dimensions, halignment, valignment);
	label:enableOutline(outlineColor, outlineSize);
	return label;
end
-- ============== LABEL END   =================

-- ============== SPRITE START =================
function GameTool:createSprite(filename)
	local cache = cc.Director:getInstance():getTextureCache();
	local texture = cache:addImage(filename);
	local sprite = cc.Sprite:createWithTexture(texture);
	return sprite;
end

function GameTool:addSprite(layer, filename, pos, anchorpoint, zorder)
	anchorpoint = anchorpoint or ANCHOR_CENTER_CENTER;
	local sprite = self:createSprite(filename);
	sprite:setAnchorPoint(anchorpoint);
	if nil ~= pos then
		sprite:setPosition(pos);
	end
	if nil ~= zorder then
		layer:addChild(sprite, zorder);
	else
		layer:addChild(sprite);
	end
	return sprite;
end
-- ============== SPRITE END   =================

-- ============== BUTTON START =================
function GameTool:createItemLabel(label, pos, anchorpoint, callback) 
	anchorpoint = anchorpoint or ANCHOR_LEFT_DOWN
	local item = cc.MenuItemLabel:create(label)
	item:setAnchorPoint(anchorpoint)
	item:setPosition(pos)
	if nil ~= callback then
		item:registerScriptTapHandler(callback)
	end
	return item
end

function GameTool:addItemLabel(items, label, pos, anchorpoint, callback) 
	local item = GameTool:createItemLabel(label, pos, anchorpoint, callback)
	table.insert(items, item)
	return item
end

function GameTool:createItemSprite(spriteNormal, spriteSelect, pos, anchorpoint, callback) 
	anchorpoint = anchorpoint or ANCHOR_LEFT_DOWN;
	local item = cc.MenuItemSprite:create(spriteNormal, spriteSelect);
	item:setAnchorPoint(anchorpoint);
	item:setPosition(pos);
	if nil ~= callback then
		--[[
		local mm = 0;
		local function cb()
			print('cb');
			mm = mm + 1;
		print('mm: ', mm);
			if mm < 10 then return; end
			item:unscheduleUpdate();
			--callback(item:getTag(), item);
		local t = 0;
		for i = 1, 10000000000 do
			t = t + i;
			--print('t: ', t);
		end
		end
		local function delay_it()
			print('delay_it');
			item:scheduleUpdateWithPriorityLua(cb, 1);
		end
		item:registerScriptTapHandler(delay_it);
		]]--
		item:registerScriptTapHandler(callback);
	end
	return item;
end

function GameTool:addCustomItem(items, spriteNormal, spriteSelect, pos, anchorpoint, callback, title, font, fsize)
	local item = GameTool:createItemSprite(spriteNormal, spriteSelect, pos, anchorpoint, callback);
	table.insert(items, item);
	if nil == title then
		return item;
	end
	font = font or TTF_DEFAULT
	fsize = fsize or 25
	local size = item:getContentSize();
	local label = util.add_labelttf(item, title, font, fsize, cc.p(size.width/2, size.height/2), cc.c4b(255, 255, 255, 255), ANCHOR_CENTER_CENTER, 10, size, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	--label:setTag(TAG_SPRITE_LABEL);
	return item;
end

function add_item_1(items, title, font, fsize, callback, anchorpoint, pos, size)
	local fname1 = 'btn_140.png';
	local fname2 = 'btn_140_s.png';
	local frect = cc.rect(0, 0, 106, 53); -- fullrect
	local irect = cc.rect(50, 25, 6, 3); -- insetrect
	size = size or cc.size(150, 53); -- realsize
	local path1 = util.get_path(fname1);
	local path2 = util.get_path(fname2);
	local unsprite = util.create_scale9sprite(path1,frect,irect,size);
	local sprite = util.create_scale9sprite(path2,frect,irect,size);
	return add_custom_item(items, unsprite, sprite, pos, anchorpoint, callback, title, font, fsize)
end

function GameTool:addMenu(layer, tbItem, zorder)
	tbItem = tbItem or {}
	if 0 == #tbItem then
		return
	end
	zorder = zorder or 0

	local menu = cc.Menu:create()
	for i = 1, #tbItem do
		local item = tbItem[i]
		menu:addChild(item)
	end
	menu:setAnchorPoint(ANCHOR_LEFT_DOWN)
	menu:setPosition(0, 0)

	layer:addChild(menu, zorder)

	return menu -- return btn is for reference only, do not use
end
-- ============== BUTTON END   =================

-- ============== SCROLL VIEW START =================
--[[
	tableview_handler = function(...)  -- { start
		local self = layer_xxx;
		local args = {...};
		local event = args[1];
		local view = args[2];
		--kdebug("%s", event);
		if "numberOfCellsInTableView" == event then
			return #(self.list or {});
		elseif "scrollViewDidScroll" == event then
			return;
		elseif "scrollViewDidZoom" == event then
			return;
		elseif "tableCellTouched" == event then
			local cell = args[3];
			local idx = cell:getIdx();
			return;
		elseif "cellSizeForTable" == event then
			local idx = args[3];
			return self.cheight, self.cwidth;
		elseif "tableCellAtIndex" == event then
			local idx = args[3];
			local cell = view:dequeueCell()
			if nil ~= cell then
				cell:removeFromParentAndCleanup(true);
			end
			cell = cc.TableViewCell:new()
			return cell;
		elseif "tableCellHighlight" == event then
			local cell = args[3];
			return;
		elseif "tableCellUnhighlight" == event then
			local cell = args[3];
			return;
		end
	end, -- tableview_handler end }
]]--
-- direction
-- cc.SCROLLVIEW_DIRECTION_NONE
-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL
-- cc.SCROLLVIEW_DIRECTION_VERTICAL
-- cc.SCROLLVIEW_DIRECTION_BOTH
-- fillorder
-- cc.TABLEVIEW_FILL_TOPDOWN
-- cc.TABLEVIEW_FILL_BOTTOMUP
function GameTool:addTableview(layer, size, direction, handler, pos, fillorder, zorder)
	local tableview = cc.TableView:create(size)
	tableview:setDirection(direction)
	tableview:setPosition(pos)
	tableview:setVerticalFillOrder(fillorder)
	tableview:setDelegate()
	tableview:registerScriptHandler(
		function(view)
			if nil == handler then return 0 end
			return handler("numberOfCellsInTableView", view);
			--TableViewTestLayer.numberOfCellsInTableView
			-- return num;
		end,
		cc.NUMBER_OF_CELLS_IN_TABLEVIEW
	)  
	tableview:registerScriptHandler(
		function(view)
			if nil == handler then return end
			return handler("scrollViewDidScroll", view)
			--TableViewTestLayer.scrollViewDidScroll
		end,
		cc.SCROLLVIEW_SCRIPT_SCROLL
	)
	tableview:registerScriptHandler(
		function(view)
			if nil == handler then return end
			return handler("scrollViewDidZoom", view)
			--TableViewTestLayer.scrollViewDidZoom
		end,
		cc.SCROLLVIEW_SCRIPT_ZOOM
	)
	tableview:registerScriptHandler(
		function(view, cell)
			if nil == handler then return end
			return handler("tableCellTouched", view, cell)
			--TableViewTestLayer.tableCellTouched
		end,
		cc.TABLECELL_TOUCHED
	)
	tableview:registerScriptHandler(
		function(view, idx)
			if nil == handler then return cc.size(0, 0) end
			return handler("cellSizeForTable", view, idx);
			--TableViewTestLayer.cellSizeForTable
			-- return len
		end,
		cc.TABLECELL_SIZE_FOR_INDEX
	)
	tableview:registerScriptHandler(
		function(view, idx)
			if nil == handler then 
				local cell = view:dequeueCell()
				if nil ~= cell then
					cell:removeFromParentAndCleanup(true);
				end
				cell = cc.TableViewCell:new()
				return 
			end
			return handler("tableCellAtIndex", view, idx);
			--TableViewTestLayer.tableCellAtIndex
		end,
		cc.TABLECELL_SIZE_AT_INDEX
	)
	tableview:registerScriptHandler(
		function(view, cell)
			if nil == handler then return end
			return handler("tableCellHighlight", view, cell);
		end,
		cc.TABLECELL_HIGH_LIGHT
	)
	tableview:registerScriptHandler(
		function(view, cell)
			if nil == handler then return end
			return handler("tableCellUnhighlight", view, cell);
		end,
		cc.TABLECELL_UNHIGH_LIGHT
	)
	if nil == zorder then
		layer:addChild(tableview)
	else
		layer:addChild(tableview, zorder)
	end
	tableview:reloadData()
	return tableview
end
-- ============== SCROLL VIEW END   =================

_G["GameTool"] = GameTool

