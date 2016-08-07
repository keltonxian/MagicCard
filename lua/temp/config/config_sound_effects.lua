--==================================================
--    @Brief:   sound effects
--    @Author:  Rios
--    @Date:    2015-10-26
--==================================================

module (...,package.seeall)

require "config/config_game"

local tblSoundEffects = 
{
--common
    -- common_arrow =                          "sfx/common/arrow.mp3",
    -- common_bottom_icon_click =              "sfx/common/bottom icon click.mp3",
    -- common_camera =                         "sfx/common/camera.mp3",
    -- common_menu_toggle =                    "sfx/common/menu toggle.mp3",
    -- common_menu_item_click =                "sfx/common/menu-item-click.mp3",
    -- common_right_side_icon_click =          "sfx/common/right side icon click.mp3",
    -- common_share_close =                    "sfx/common/share close.mp3",
    -- common_swipe_left =                     "sfx/common/swipe left.mp3",
    -- common_swipe_right =                    "sfx/common/swipe right.mp3",

    common_menu_item_click =                "sfx/common/1 - button click.mp3",              --(UI 按键音)
    common_menu_toggle =                    "sfx/common/2 - menu open.mp3",                 --(菜单栏展开)
    common_swipe_right =                    "sfx/common/3 - swipe right.mp3",               --(底栏向右滑动)
    common_swipe_left =                     "sfx/common/4 - swipe left.mp3",                --(底栏向左滑动)
    common_arrow =                          "sfx/common/5 - arrow.mp3",                     --(箭头向后)
    common_bottom_icon_click =              "sfx/common/6 - bottom icon click.mp3",         --(底栏UI选择)
    common_right_side_icon_click =          "sfx/common/7 - right icon click.mp3",          --(侧边栏UI选择)
    common_camera =                         "sfx/common/8 - camera.mp3",                    --(照相机)
    common_share_close =                    "sfx/common/9 - close.mp3",                     --(关闭键)
    
    common_tools_selcet =                   "sfx/common/10 - tools selcet.mp3",             --(工具选中音)
    common_tool_end =                       "sfx/common/11 - tool end.mp3",                 --(工具飞回工具栏)
    common_popup_open =                     "sfx/common/12 - popup open.mp3",               --(弹窗打开)
    common_popup_close =                    "sfx/common/13 - popup close.mp3",              --(弹窗关闭)

--spa
    spa_p1_bubble_on_face =                 "sfx/spa/sounds/p1_bubble on face.mp3",
    spa_p1_p2_p4_shower =                   "sfx/spa/sounds/p1_p2_p4_shower.mp3",
    spa_p1_sponge_select =                  "sfx/spa/sounds/p1_sponge select.mp3",
    spa_p2_facial_scrub_on_face =           "sfx/spa/sounds/p2_facial scrub on face.mp3",
    spa_p2_scrub_select =                   "sfx/spa/sounds/p2_scrub select.mp3",
    spa_p3_forcep_sound_on_eyebrow =        "sfx/spa/sounds/p3_forcep sound on eyebrow.mp3",
    spa_p3_forcept_select =                 "sfx/spa/sounds/p3_forcept select.mp3",
    spa_p3_pimple_tool_select =             "sfx/spa/sounds/p3_pimple tool select.mp3",
    spa_p3_steam_face =                     "sfx/spa/sounds/p3_steam face.mp3",
    spa_p3_steam_machine_select =           "sfx/spa/sounds/p3_steam machine select.mp3",
    spa_p4_cucumber_eye_mask_on_off_eyes =  "sfx/spa/sounds/p4_cucumber eye mask on & off eyes.mp3",
    spa_p4_facial_mask_on_face =            "sfx/spa/sounds/p4_facial mask on face.mp3",
    spa_p4_facial_mask_tool_select =        "sfx/spa/sounds/p4_facial mask tool select.mp3",
    spa_p5_sun_oil_on_face =                "sfx/spa/sounds/p5_sun oil on face.mp3",
    spa_p6_powder_on_face_3 =               "sfx/spa/sounds/p6_powder on face 3.mp3",
    spa_p6_powder_on_face_4 =               "sfx/spa/sounds/p6_powder on face 4.mp3",
    spa_p6_powder_sponge_select =           "sfx/spa/sounds/p6_powder sponge select.mp3",
    spa_p6_powder_tool_select =             "sfx/spa/sounds/p6_powder tool select.mp3",
}

local SoundEffects = class("SoundEffects")

function SoundEffects:ctor( ... )
    for k,v in pairs(tblSoundEffects) do
        self[k] = v
    end
end


local s_sound_effects_instance = nil
function SoundEffects:getInstance( ... )
    if not s_sound_effects_instance then
        s_sound_effects_instance = SoundEffects.new()
        SoundEffects.new = function ( ... )
            error("SoundEffects.new()--->access error!")
        end
    end

    return s_sound_effects_instance
end


_G["config_sound_effects"] = SoundEffects:getInstance()

