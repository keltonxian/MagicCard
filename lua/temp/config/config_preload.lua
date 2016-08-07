--[[ resources to preload, format:
{
	{
		-- images
	},
	{
		-- sound effects
	},
	{
		-- background musics
	},
}
]]

local _global = {
	{

	},
	{
		config_sound_effects.common_arrow,
		config_sound_effects.common_bottom_icon_click,
		config_sound_effects.common_camera,
		config_sound_effects.common_menu_toggle,
		config_sound_effects.common_menu_item_click,
		config_sound_effects.common_right_side_icon_click,
		config_sound_effects.common_share_close,
		config_sound_effects.common_swipe_left,
		config_sound_effects.common_swipe_right,
		config_sound_effects.common_tools_selcet,
		config_sound_effects.common_tool_end,
		config_sound_effects.common_popup_open,
		config_sound_effects.common_popup_close,
	},
	{

	},
}

local _home = {
	{
		
	},
	{

	},
	{
	},
}

local _map = {
	{
	},
	{

	},
	{
	},
}

local _spa = {
	{
	},
	{
		config_sound_effects.spa_p1_bubble_on_face,
		config_sound_effects.spa_p1_p2_p4_shower,
		config_sound_effects.spa_p1_sponge_select,
		config_sound_effects.spa_p2_facial_scrub_on_face,
		config_sound_effects.spa_p2_scrub_select,
		config_sound_effects.spa_p3_forcep_sound_on_eyebrow,
		config_sound_effects.spa_p3_forcept_select,
		config_sound_effects.spa_p3_pimple_tool_select,
		config_sound_effects.spa_p3_steam_face,
		config_sound_effects.spa_p3_steam_machine_select,
		config_sound_effects.spa_p4_cucumber_eye_mask_on_off_eyes,
		config_sound_effects.spa_p4_facial_mask_on_face,
		config_sound_effects.spa_p4_facial_mask_tool_select,
		config_sound_effects.spa_p5_sun_oil_on_face,
		config_sound_effects.spa_p6_powder_on_face_3,
		config_sound_effects.spa_p6_powder_on_face_4,
		config_sound_effects.spa_p6_powder_sponge_select,
		config_sound_effects.spa_p6_powder_tool_select,

	},
	{
	},
}


local _makeup = {
	{
	},
	{

	},
	{
	},
}

local _dress = {
	{
	},
	{
	},
	{

	},
}

local _show = {
	{

	},
	{
	},
	{
	},
}

_G["config_preload"] = {
	global = _global,
	SceneHome = _home,
	SceneMap = _map,
	SceneSpa = _spa,
	SceneMakeup = _makeup,
	SceneDress = _dress,
	SceneShow = _show,
}
