require("extern/MenuLayer")

local _metaButtonsAll = {
	{
		type_ = MenuLayer.typeMenu,
		normalSprite = "Button/1.png",
		selectedSprite = "Button/2.png",
		clickSound = config_sound_effects.common_menu_toggle,
	},
	{
		type_ = MenuLayer.typeForward,
		normalSprite = "Button/5.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_arrow,
	},
	-- {
	-- 	type_ = MenuLayer.typeBackward,
	-- 	normalSprite = "menu/30a.png",
	-- 	selectedSprite = nil,
	-- 	clickSound = config_sound_effects.common_arrow,
	-- },
}

local _metaButtonsNoForward = {
	_metaButtonsAll[1],
	{
		type_ = MenuLayer.typeForward,
		normalSprite = "Button/5.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_arrow,
	},
}

local _metaButtonsNoBackward = {
	_metaButtonsAll[1],
	{
		type_ = MenuLayer.typeForward,
		normalSprite = "Button/right.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_arrow,
	},
}

local _metaButtonsDesignMenu = {
	_metaButtonsAll[1],
	{
		type_ = MenuLayer.typeForward,
		normalSprite = "Button/5.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_arrow,
	},
}

local _regularButtonsAll = {
	{
		type_ = MenuLayer.typeSound,
		vOrH = "v",
		normalSprite = "Button/7.png",
		selectedSprite = "Button/6.png",
		clickSound = nil,
		closeMenuAfterClick = false,
		isFixed = false,
	},
	{
		type_ = MenuLayer.typeReset,
		vOrH = "v",
		normalSprite = "Button/10.png",
		selectedSprite = nil,
		clickSound = nil,
		closeMenuAfterClick = true,
		isFixed = false,
	},	
	{
		type_ = MenuLayer.typeCamera,
		vOrH = "v",
		normalSprite = "Button/9.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_camera,
		closeMenuAfterClick = true,
		isFixed = false,
	},	
	{
		type_ = MenuLayer.typeRateUs,
		vOrH = "v",
		normalSprite = "Button/8.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_popup_open,
		closeMenuAfterClick = true,
		isFixed = false,
	},
	-- we use new More Games button instead, but will keep the following section as the placeholder
	-- for detail, check the MenuLayer.addMetaButton
	{
		type_ = MenuLayer.typeMorePage,
		vOrH = "v",
		normalSprite = "Button/14.png",
		selectedSprite = nil,
		clickSound = nil,
		closeMenuAfterClick = false,
		isFixed = true,
	},
	{
		type_ = MenuLayer.typeHome,
		vOrH = "h",
		normalSprite = "Button/4.png",
		selectedSprite = nil,
		clickSound = nil,
		closeMenuAfterClick = true,
		isFixed = false,
	},	
	{
		type_ = MenuLayer.typeShop,
		vOrH = "h",
		normalSprite = "Button/3.png",
		selectedSprite = nil,
		clickSound = config_sound_effects.common_popup_open,
		closeMenuAfterClick = true,
		isFixed = false,
	},	
	
}

local _regularButtonsNoReset = {
	_regularButtonsAll[1],
	_regularButtonsAll[3],
	_regularButtonsAll[4],
	_regularButtonsAll[5],
	_regularButtonsAll[6],
	_regularButtonsAll[7],
}

local _regularButtonsNoResetNoMoreGames = {
	_regularButtonsAll[1],
	_regularButtonsAll[3],
	_regularButtonsAll[4],
	_regularButtonsAll[6],
	_regularButtonsAll[7],
}

local _regularButtonsAllNoShop = {
	_regularButtonsAll[1],
	_regularButtonsAll[2],
	_regularButtonsAll[3],
	_regularButtonsAll[4],
	_regularButtonsAll[5],
	
	_regularButtonsAll[6],
}

local _regularButtonsNoResetNoShop = {
	_regularButtonsAll[1],
	_regularButtonsAll[3],
	_regularButtonsAll[4],
	_regularButtonsAll[5],
	
	_regularButtonsAll[6],
}

local _regularButtonsNoResetNoMoreGamesNoShop = {
	_regularButtonsAll[1],
	_regularButtonsAll[3],
	_regularButtonsAll[4],
	
	_regularButtonsAll[6],
}

MenuLayer.topLeftOffset = { x = 10, y = 11, }
MenuLayer.topRightOffset = { x = 10, y = 14, }
MenuLayer.defaultClickSound = config_sound_effects.common_menu_item_click

local function createMenu(metaButtons, regularButtons, extras)
	local menu = MenuLayer.create()

	for _, d in pairs(metaButtons) do
		menu:addMetaButton(d.type_, d.normalSprite, d.selectedSprite, d.clickSound, false)
	end

	for _, d in pairs(regularButtons) do
		local func = (d.vOrH == "v") and menu.addVButton or menu.addHButton
		func(menu, d.type_, d.normalSprite, d.selectedSprite, d.clickSound, d.closeMenuAfterClick, d.isFixed)
	end

	if type(extras) == "table" then
		for k, v in pairs(extras) do
			menu[k]	= v
		end
	end

	local moreBtn = menu:getChildByTag(MenuLayer.typeMorePage)
	local forwardBtn = menu:getChildByTag(MenuLayer.typeForward)
	local backwardBtn = menu:getChildByTag(MenuLayer.typeBackward)

	if moreBtn then
		moreBtn.minClickInterval = 1
	end
	
	if forwardBtn then
		forwardBtn.minClickInterval = 3
	end

	if backwardBtn then
		backwardBtn.minClickInterval = 3
	end

	return menu
end

local function createSpaMenu(extras)
	local m
	if __G__isAndroid then
		m = createMenu(_metaButtonsAll, _regularButtonsAllNoShop, extras)
	else
		m = createMenu(_metaButtonsAll, _regularButtonsAll, extras)
	end

	m.onBackward = m.onHome
	return m
end

local function createMakeupMenu(extras)

	if __G__isAndroid then
		return createMenu(_metaButtonsAll, _regularButtonsAllNoShop, extras)
	else
		return createMenu(_metaButtonsAll, _regularButtonsAll, extras)
	end
	
end

local function createDressMenu(extras)
	local m
	if __G__isAndroid then
		m = createMenu(_metaButtonsAll, _regularButtonsAllNoShop, extras)
	else
		m = createMenu(_metaButtonsAll, _regularButtonsAll, extras)
	end
	
	return m
end

local function createShowMenu(extras)
	local m
	if __G__isAndroid then
		m = createMenu(_metaButtonsAll, _regularButtonsNoResetNoShop, extras)
	else
		m = createMenu(_metaButtonsAll, _regularButtonsNoReset, extras)
	end
	
	m.needHideBannerAdOnPopup = true
	return m
end


local function createDesignMenu(extras)
	local m
	if __G__isAndroid then
		m = createMenu(_metaButtonsDesignMenu, _regularButtonsAllNoShop, extras)
	else
		m = createMenu(_metaButtonsDesignMenu, _regularButtonsAll, extras)
	end
	
	m.needHideBannerAdOnPopup = true
	return m
end

local function createNoBannerMenu(extras)
	local m
	if __G__isAndroid then
		m = createMenu(_metaButtonsAll, _regularButtonsNoResetNoMoreGamesNoShop, extras)
	else
		m = createMenu(_metaButtonsAll, _regularButtonsNoResetNoMoreGames, extras)
	end

	m.needHideBannerAdOnPopup = false
	return m
end

_G["config_menu"] = {
	createSpaMenu = createSpaMenu,
	createMakeupMenu = createMakeupMenu,
	createDressMenu = createDressMenu,
	createShowMenu = createShowMenu,
	createDesignMenu = createDesignMenu,
	createNoBannerMenu = createNoBannerMenu,
}
