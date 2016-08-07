module (...,package.seeall)

local _g_scale_adaptor_origin = 1
-----------------------------------------------------------------------------------
local function scaleAdaptor( ipadScale, iphoneScale )
    local _ipadScale = ipadScale
    local _iphoneScale = iphoneScale or ipadScale*0.83     --(640/768)

    return __G__iOSValue2(_iphoneScale, _ipadScale)*_g_scale_adaptor_origin
end

local function xAdaptor( ipad, iphone )
    local _valueIpad = ipad
    local _valueIphone = iphone or ipad*0.83     --(640/768)

    return __G__iOSValue2( _valueIphone, _valueIpad)
end

local function yAdaptor( ipad, iphone )
    local _valueIpad = ipad
    local _valueIphone = iphone or ipad + 10         -- ipad + 10

    return __G__iOSValue2( _valueIphone, _valueIpad)
end
-----------------------------------------------------------------------------------

-- sicne the shower section repeats several times so I put it here
local _showerConfig = function(offsetX)
    local _offsetX = offsetX or 0
    return {
        image = "spa/tools/1_1b.png",
        pickupStateImage = "spa/tools/1_1a.png",
        x = xAdaptor(550) + _offsetX,
        --y = yAdaptor(-650-278)*scaleAdaptor(1),
        y = yAdaptor(-650-278)*scaleAdaptor(1),
        toolOptions = {
            scaleOrigin = scaleAdaptor(1),
            defaultTouchSound = "",
            toolPointLocal = { x = 50, y = 970+278 },
            -- moveOnTouchAutoCenter = true,
            -- moveOnTouchPointAdaptor = function ( sender, x, y )
            --     local nodePoint = sender:convertToNodeSpace(ccp(x,y))
            --     local size = sender:getContentSize()
            --     local offsetX = math.abs((size.width-30)/2-nodePoint.x)
            --     local offsetY = nodePoint.y-size.height/2

            --     return offsetX, offsetY
            -- end,

            scaleOnPickUp = 1.0,
            moveBounds = CCRectMake(-100, __G__iOSValue(-854, -854, -870)+280-278, __G__iOSValue(840, 840, 900), (__G__iOSValue(850, 900, 850)-120+278) * 2),
        },
    }
end

local _CleanserConfig = function(offsetX)
    local _offsetX = offsetX or 0
    return {
        image = "makeup/tools/2_1a.png",
        shadow = "makeup/tools/2_1b.png",
        x = xAdaptor(50) + _offsetX,
        y = yAdaptor(100),
        toolOptions = {scaleOrigin = scaleAdaptor(1.15), canPickUp = false, },
        
    }
end

local _ConttonConfig = function(offsetX)
    local _offsetX = offsetX or 0
    return {
        image = "makeup/tools/2_1c.png",
        shadow = "makeup/tools/2_1d.png",
        x = xAdaptor(120) + _offsetX,
        y = yAdaptor(100),
        toolOptions = {
            scaleOrigin = scaleAdaptor(1),
            defaultTouchSound = "",
            touchThroughTransparentStrict = true,
            -- toolPointLocal = { x = __G__iOSValue(50,50,50), y = __G__iOSValue(1000,800,1000) },
            -- scaleOnPickUp = 1.1,
            -- moveBounds = CCRectMake(0, __G__iOSValue(-854,-854,-2033), __G__iOSValue(740,740,768), __G__iOSValue(854,854,1450) * 2),
        },
       
    }
end

local function getSpaBenchDatas( ... )
    _spaBenchDatas = _spaBenchDatas or 
    {
        [1]=
        {
            {
                image = "spa/tools/1_2a.png",
                shadow = "spa/tools/1_2b.png",
                x = xAdaptor(100),
                y = yAdaptor(110),
                --shadowX = __G__iOSValue2(123+250,213+250),
                --shadowY = -50,
                toolOptions = { scaleOrigin=scaleAdaptor(1.2), canPickUp = false, },
            },
            {
                image = "spa/tools/1_2c.png",
                shadow = "spa/tools/1_2d.png",
                x = xAdaptor(160),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1.2), touchSound = config_sound_effects.spa_p1_sponge_select, scaleOnPickUp = 1.1, toolPointLocal = { x = 70, y = 90 } },
            },
            _showerConfig(),
        },

        [2]=
        {
            {
                -- 磨砂膏瓶子
                image = "spa/tools/2_1a.png",
                shadow = "spa/tools/2_1c.png",
                pickupStateImage = "spa/tools/2_1b.png",
                x = xAdaptor(90),
                y = yAdaptor(110),
                
                z = 1,
                toolOptions = {scaleOrigin=scaleAdaptor(1), canPickUp = false, changeNormalSprite=true },
            },
            {
                -- 磨砂膏刷子
                image = "spa/tools/2_2a.png",
                shadow = "spa/tools/2_2b.png",
                pickupStateImage = "spa/tools/2_2c.png",
                x = xAdaptor(165),
                y = yAdaptor(110),
                
                z = 2,
                touchPriority = 1,
                toolOptions = {scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, touchSound = config_sound_effects.spa_p4_facial_mask_tool_select, rotateOnPickUp = 0, toolPointLocal = { x = 30+18, y = 200 }, }
            },
            _showerConfig(),
        },

        [3]=
        {
            {
				-- 蒸面机
                image = "spa/tools/3_3a.png",
                shadow = "spa/tools/3_3b.png",
                -- pickupStateImage = "spa/tools/301c.png",
                x = xAdaptor(50),
                y = yAdaptor(100),
                toolOptions = {scaleOrigin=scaleAdaptor(1.2), touchSound = config_sound_effects.spa_p3_steam_machine_select, toolPointLocal = { x = 75, y = 200}, }
            },
            {
				-- 暗疮
                image = "spa/tools/3_1a.png",
                shadow = "spa/tools/3_1b.png",
                x = xAdaptor(330-60),
                y = yAdaptor(130-80),
                
                toolOptions = { scaleOrigin=scaleAdaptor(1), touchSound = config_sound_effects.spa_p3_pimple_tool_select, toolPointLocal = { x = 10, y = 150 }, scaleOnPickUp = 1.1, rotateOnPickUp = 45,rotateOrigin = -45 }
            },
            {
				-- 眉毛
                image = "spa/tools/3_2a.png",
                shadow = "spa/tools/3_2b.png",
                --pickupStateImage = "spa/tools/3-3c.png",
                x = xAdaptor(550-20),
                y = yAdaptor(130-70),
                toolOptions = {scaleOrigin=scaleAdaptor(1), touchSound = config_sound_effects.spa_p3_forcept_select, toolPointLocal = { x = 13, y = 120 }, scaleOnPickUp = 1.1, rotateOnPickUp = 45, rotateOrigin = -45 },
            },
        },

        [4]=
        {
            {
                -- 面膜瓶子
                image = "spa/tools/4_1a.png",
                shadow = "spa/tools/4_1c.png",
                pickupStateImage = "spa/tools/4_1b.png",
                x = xAdaptor(35),
                y = yAdaptor(100),
                z = 1,
                toolOptions = {scaleOrigin=scaleAdaptor(1), canPickUp = false, changeNormalSprite=true },
            },
            {
                -- 面膜刷子
                image = "spa/tools/4_1d.png",
                shadow = "spa/tools/4_1e.png",
                --pickupStateImage = "spa/tools/4_1b.png",    
                x = xAdaptor(160),
                y = yAdaptor(100),
                z = 2,
                toolOptions = {scaleOrigin=scaleAdaptor(1), touchSound = config_sound_effects.spa_p2_scrub_select, toolPointLocal = { x = 25, y = 160 }, scaleOnPickUp = 1.1, rotateOnPickUp = 0, touchHitScaleX = 1.5,},
                
            },
            {
				-- 青瓜盘子 后面
                image = "spa/tools/4_2b.png",
                shadow = "spa/tools/4_2e.png",
                x = xAdaptor(260),
                y = yAdaptor(110),
                z = 3,
                toolOptions = {scaleOrigin=scaleAdaptor(1), canPickUp = false },
            },
            {
				-- 青瓜盘子 前面
                image = "spa/tools/4_2a.png",
                x = xAdaptor(260),
                y = yAdaptor(110),
                z = 7,
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false },
            },
            {
				-- 青瓜片
                image = "spa/tools/4_2c.png",
                x = xAdaptor(310),
                y = yAdaptor(135),
                z = 6,
                toolOptions = {scaleOrigin=scaleAdaptor(1.0), touchSound = config_sound_effects.common_menu_item_click, scaleOnPickUp = 1.25, touchEndSound = "" }
            },
            {
				-- 青瓜片
                image = "spa/tools/4_2d.png",
                x = xAdaptor(370),
                y = yAdaptor(135),
                z = 6,
                toolOptions = {scaleOrigin=scaleAdaptor(1.0), touchSound = config_sound_effects.common_menu_item_click, scaleOnPickUp = 1.25, touchEndSound = "" }
            },

            _showerConfig(35),
        },

        [5]=
        {
            {
				-- bbcream
                image = "spa/tools/5_1a.png",
                shadow = "spa/tools/5_1b.png",
                --pickupStateImage = "spa/tools/5-2b.png",
                x = xAdaptor(80),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1.2), canPickUp = false },
            },
			-- powder
            {
                image = "spa/tools/5_2a.png",
                shadow = "spa/tools/5_2aaa.png",
                pickupStateImage = "spa/tools/5_2aa.png",    
                x = xAdaptor(270),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1.3), canPickUp = false, changeNormalSprite=true, touchThroughTransparentStrict=true },
            },
            {
                image = "spa/tools/5_2b.png",
                shadow = "spa/tools/5_2c.png",
                z = 2,
                x = xAdaptor(450),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1), touchSound = "sfx/spa/sounds/p6_powder tool select.mp3", scaleOnPickUp = 1.1, }
            },
            
            {
                image = "Button/right.png",
                x = xAdaptor(625),
                y = yAdaptor(130),
                toolOptions = { canPickUp = false, minClickInterval = 2, touchSound = config_sound_effects.common_arrow, },
            },
        },
    }

    return _spaBenchDatas
end


local function getMakeupBenchDatas( ... )
    _makeupBenchDatas = _makeupBenchDatas or 
    {
        [1]=
        {
            {
				-- 梳子
                image = "makeup/tools/1_1.png",
                -- shadow = "makeup/tools/101b.png",
                x = xAdaptor(100),
                y = yAdaptor(100),
                toolOptions = {scaleOrigin=scaleAdaptor(1.1), canPickUp = false, },
            },
            {
				-- 隐形眼镜
                image = "makeup/tools/1_2a.png",
                shadow = "makeup/tools/1_2c.png",
                pickupStateImage = "makeup/tools/1_2b.png",
                x = xAdaptor(430),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false, },
            },
        },

        [2]=
        {
            _CleanserConfig(),
            _ConttonConfig(),
            {
				-- 眉款
                image = "makeup/tools/2_2a.png",
                shadow = "makeup/tools/2_2c.png",
                pickupStateImage = "makeup/tools/2_2b.png",
                x = xAdaptor(345),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1), canPickUp = false,}
            },
            {
				-- 眉色
                image = "makeup/tools/2_2d.png",
                shadow = "makeup/tools/2_2e.png",
                x = xAdaptor(480-40),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, rotateOrigin=0, rotateOnPickUp = 0, toolPointLocal = { x = 5, y = 110 },
				--touchSound= "sfx/makeup/10 - The eyebrows frame the face.mp3",
				}
            },
        },

        [3]=
        {
            _CleanserConfig(),
            _ConttonConfig(),
            
            {
				-- 眼影色
                image = "makeup/tools/3_1a.png",
                shadow = "makeup/tools/3_1c.png",
                pickupStateImage = "makeup/tools/3_1b.png",
                x = xAdaptor(320),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1), canPickUp = false,}
            },
            {
				-- 眼影笔
                image = "makeup/tools/3_1d.png",
                shadow = "makeup/tools/3_1e.png",
                z = 2,
                x = xAdaptor(460),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, 
				    rotateOrigin=0, rotateOnPickUp = 0,
           			toolPointLocal = { x = 15, y = 110 },
		--touchSound = "sfx/makeup/8- The eyeshadow sets the tone of your makeup.mp3",
					 }
            },
            {
				-- 高光眼影笔
                image = "makeup/tools/3_1f.png",
                shadow = "makeup/tools/3_1g.png",
                z = 2,
                x = xAdaptor(575),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, rotateOrigin=0, rotateOnPickUp = 0, 
                    toolPointLocal = { x = 20, y = 115 },touchSound="",}
            },
        },

        [4]=
        {
            _CleanserConfig(),
            _ConttonConfig(),
			-- 眼线
            {
                image = "makeup/tools/4_1a.png",
                shadow = "makeup/tools/4_1b.png",
                x = xAdaptor(390),
                y = yAdaptor(110),
                
                -- shadow = "makeup/eyeline/tool/8b.png",
                toolOptions = {scaleOrigin=scaleAdaptor(1),  canPickUp = false, }
            },
            
            {
                image = "makeup/tools/4_1c.png",
                shadow = "makeup/tools/4_1d.png",
                x = xAdaptor(480),
                y = yAdaptor(110),
                
                toolOptions = { scaleOrigin=scaleAdaptor(1), toolPointLocal = { x = 30, y = 210 }, scaleOnPickUp = 1.1, rotateOnPickUp = -30,
			--touchSound = "sfx/makeup/11 - Love the shining liner.mp3",
				}
            },
        },    

        [5]=
        {
            _CleanserConfig(),
            _ConttonConfig(),
			-- 睫毛
            {
                image = "makeup/tools/5_1a.png",
                shadow = "makeup/tools/5_1b.png",
                x = xAdaptor(390),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false, }
            },
            {
                image = "makeup/tools/5_1c.png",
                shadow = "makeup/tools/5_1d.png",
                x = xAdaptor(460),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), toolPointLocal = { x = 25, y = 175 }, scaleOnPickUp = 1.1, rotateOnPickUp = -30,
  --touchSound = "sfx/makeup/12 - A coat of mascara can make a huge difference.mp3",
				}
            },
        },    

        [6]=
        {
            _CleanserConfig(),
            _ConttonConfig(),  
			-- 腮红
            {
                image = "makeup/tools/6_1a.png",
                shadow = "makeup/tools/6_1c.png",
                pickupStateImage = "makeup/tools/6_1b.png",
                touch = -1,
                x = xAdaptor(320),
                y = yAdaptor(110),
                z = 1,
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false, }
            },
            {
                image = "makeup/tools/6_2a.png",
                shadow = "makeup/tools/6_2b.png",
                x = xAdaptor(440),
                y = yAdaptor(110),
                z = 3,
                toolOptions = { scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, rotateOnPickUp = 0, toolPointLocal = { x = 20, y = 130 }, 
				--touchSound ="sfx/makeup/13 - Makeup can brighten your face.mp3",
				}
            },
            {
                image = "makeup/tools/6_3a.png",
                shadow = "makeup/tools/6_3b.png",
                x = xAdaptor(610),
                y = yAdaptor(110),
                z = 2,
                toolOptions = { scaleOrigin=scaleAdaptor(1), scaleOnPickUp = 1.1, rotateOnPickUp = -20, toolPointLocal = { x = 20, y = 140 },touchSound="",}
            },
        },   

        [7]=
        {
            _CleanserConfig(),
            _ConttonConfig(),  
			-- lipstick
            {
                image = "makeup/tools/7_1a.png",
                shadow = "makeup/tools/7_1b.png",
                x = xAdaptor(320),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), toolPointLocal = { x = 25, y = 180 }, scaleOnPickUp = 1.1, rotateOnPickUp = -30 }
            },
            {
                image = "makeup/tools/7_2a.png",
                shadow = "makeup/tools/7_2b.png",
                x = xAdaptor(435),
                y = yAdaptor(110),
                -- -- shadowX = __G__iOSValue2(123+250,213+250),
                -- -- shadowY = __G__iOSValue2(100,90),
                toolOptions = { scaleOrigin=scaleAdaptor(1), toolPointLocal = { x = 25, y = 180 }, scaleOnPickUp = 1.1, rotateOnPickUp = -30, 
    --touchSound = "sfx/makeup/7- Different lip color conveys different personality.mp3",
				}
            },
			--[[
            {
                image = "makeup/tools/7_3a.png",
                shadow = "makeup/tools/7_3b.png",
                x = xAdaptor(540),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1),  canPickUp = false, }
            },
			]]--
            {
                image = "makeup/tools/7_3c.png",
                shadow = "makeup/tools/7_3d.png",
                -- pickupStateImage = "makeup/tools/lipstick/703c.png",
                x = xAdaptor(600-30),
                y = yAdaptor(110),
                toolOptions = {scaleOrigin=scaleAdaptor(1),  toolPointLocal = { x = 25, y = 180 }, scaleOnPickUp = 1.1, rotateOnPickUp = -30, touchSound="",}
            },
        },

        [8]=
        {
            {
                image = "makeup/tools/8_1.png",
                x = xAdaptor(40),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false, },
            },
            {
                image = "makeup/tools/8_2.png",
                x = xAdaptor(350),
                y = yAdaptor(110),
                toolOptions = { scaleOrigin=scaleAdaptor(1), canPickUp = false, },
            },
            {
                image = "Button/right.png",
                x = xAdaptor(635),
                y = yAdaptor(120),
                toolOptions = { canPickUp = false, minClickInterval = 2 , touchSound = config_sound_effects.common_arrow,},
            },
        },
    }

    return _makeupBenchDatas
end

---------------------------------------------------------------------------------------------

local _benchSize = { width = __G__canvasSize.width, height = __G__iOSValue(235,235,235) }

---------------------------------------------------------------------------------------------
local config_bench = config_bench or class("config_bench")

function config_bench:createBenchFunc( datas, size, touchSound )
    ButtonLayer.defaultTouchSound = touchSound or config_sound_effects.common_bottom_icon_click
    
    local pages = #datas 
    local size = size or _benchSize
    
    local bench = BenchLayer.create(size.width, size.height, pages)
    bench.m_sizeContainer = CCSizeMake(size.width, size.height)
   
    for k,v in pairs(datas) do
        local _page = k
        local _data = v

        local _count = 0
        local _benchOffsetX = 0
    
        local _forLog = false
        for _, d in pairs(_data) do
            if _forLog then
                print("===========image------->",d.image)
                print("===========shadow------->",d.shadow)
            end
            _count = _count + 1
            local tool = ToolLayer.create(d.image, d.toolOptions)
            local z = d.z and d.z or 1
            local tag = d.tag and d.tag or (100*_page+_count)

            -------------------------------------------------------------------
            local toolSize = tool:boundingBox().size
            --需要附加当前item的宽度（用于格式化的布局）
            if d.attachItemWidth then
                d.x = d.x+_benchOffsetX
                _benchOffsetX = _benchOffsetX + toolSize.width
            end
            local _containerWidth = d.x+toolSize.width
            if _containerWidth>bench.m_sizeContainer.width then
                bench.m_sizeContainer.width = _containerWidth
            end
            -------------------------------------------------------------------

            bench:addTool(tool, tag, _page, d.x, d.y, z, d.shadow, d.shadowX, d.shadowY)

            tool.originImage = tool.originImage or d.image

            if d.pickupStateImage then
                tool:setStateSprite(d.pickupStateImage, "pickup")
                tool.spriteStateOnPickUp = "pickup"
                tool.pickupStateImage = d.pickupStateImage
            end
        end
    end

    if pages == 1 then
        bench.paginated = false
        if bench.m_sizeContainer.width >= size.width then
            bench.container:setContentSize(bench.m_sizeContainer)
        end
    end

    --点击菜单栏“还原”按钮后调用此函数，bench重新偏移回初始位置
    function bench:reInitOffset ( ... )
        if self.paginated then
            if pages>1 then
                if self.currentPage ~= 1 then
                    local _layer = self:getParent()
                    performWithDelay(
                        self,
                        function()
                            self.scrollView:setContentOffsetInDuration(ccp(0, 0), 0.2*self.currentPage)
                            self.currentPage = 1
                        end,
                        0.5)
                    _layer.onTouch = function() end  -- disable touch temporarily
                    performWithDelay(_layer, function() _layer.onTouch = Layer.onTouch end, 0.2*self.currentPage+0.25)           
                end
                self.onPagingDone(nil,1,0)
            end
        else
            performWithDelay(self,function()
                    self.scrollView:setContentOffsetInDuration(ccp(0, 0), 0.5)
                end,
                0.5)
        end
    end
    function bench:scanThroughAnimate(delay, duration)
        self.scrollView:setContentOffset(ccp(self:getContentSize().width - self.container:getContentSize().width, 0), false)
        performWithDelay(self,
            function() self.scrollView:setContentOffsetInDuration(ccp(0, 0), duration) end,
            delay
        )
    end

    ButtonLayer.defaultTouchSound = nil

    return bench
end

function config_bench:createToolBench( size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep, startOffsetX, startOffsetY, xPadding )
    
    local offsetXOrigin = startOffsetX or 5
    local offsetX = offsetXOrigin
    local offsetY = startOffsetY or __G__iOSValue2(120, 117)
    local pickUp = false
    local xPadding = xPadding or 0
   
    local singlePageItemCount = singlePageItemCount or itemTotalCount
    local curPage = 0
    local itemCount = 0

    local datas = {}
    local items = nil

    for index=startNum,(startNum+itemTotalCount-1) do
        itemCount = itemCount+1
        if itemCount>singlePageItemCount*curPage then
            items = {}
            curPage = curPage+1
            offsetX = offsetXOrigin
            table.insert(datas, items)
        end
        item = {}
        item.image = string.format(imageFormat, index)
        item.x = offsetX
        item.y = offsetY
        item.toolOptions = { canPickUp = pickUp, }
        item.attachItemWidth = true

        table.insert(items, item)
        offsetX = offsetX+xPadding
    end
    if imageNextStep then
        item = {}
        item.image = imageNextStep
        item.x = offsetX+5
        item.y = offsetY+10
        item.toolOptions = { canPickUp = pickUp, touchSound = config_sound_effects.common_arrow}
        item.attachItemWidth = true

        table.insert(items, item)
        offsetX = offsetX+xPadding
    end

    local ret = self:createBenchFunc(datas, size)
    
    ret.m_singlePageItemCount = singlePageItemCount
    
    return ret
end

----------------------------------------------------------------------------------------------------------
function config_bench:createSpaBench()
    local ret = self:createBenchFunc(getSpaBenchDatas())
     
    return ret
end

function config_bench:createMakeupBench( ... )
    _g_scale_adaptor_origin=1.2
    local ret = self:createBenchFunc(getMakeupBenchDatas())
    _g_scale_adaptor_origin=1 
    return ret
end

function config_bench:createDressBench( width, height, startNum, itemTotalCount )
    local size = CCSizeMake(width, height)
    local imageFormat = "dressup/icon/%d.png"
    local imageNextStep = "Button/right.png"
    local singlePageItemCount = nil

    local ret = self:createToolBench(size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep)
    
    return ret
end

function config_bench:createPartnerBench( width, height, startNum, itemTotalCount )
    local size = CCSizeMake(width, height)
    local imageFormat = "partner/icon/%d.png"
    local imageNextStep = "Button/right.png"
    local singlePageItemCount = nil

    local ret = self:createToolBench(size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep)
     
    return ret
end

function config_bench:createDesignBench( width, height, startNum, itemTotalCount, singlePageItemCount )
    local size = CCSizeMake(width, height)
    local imageFormat = "design/tools/%d.png"
    local imageNextStep = "Button/right.png"
    local singlePageItemCount = singlePageItemCount or nil

    local offsetX = nil
    local offsetY = __G__iOSValue2(90, 90)
    local xPadding = __G__iOSValue2(10, 33)

    local ret = self:createToolBench(size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep, offsetX, offsetY, xPadding)

    return ret
end

function config_bench:createSignBench( width, height, startNum, itemTotalCount, singlePageItemCount )
    local size = CCSizeMake(width, height)
    --local imageFormat = "design/sign/button/%d.png"
    local imageFormat = "design/tools/%d.png"
    local imageNextStep = nil
    local singlePageItemCount = singlePageItemCount or nil

    local offsetX = nil
    local offsetY = __G__iOSValue2(5, 5)
    local xPadding = __G__iOSValue2(25, 25)

    local ret = self:createToolBench(size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep, offsetX, offsetY, xPadding)

    return ret
end

function config_bench:createCustomBench( width, height, startNum, itemTotalCount, imageFormat, imageNextStep, singlePageItemCount, offsetY, xPadding, offsetX )
    local size = CCSizeMake(width, height)
    local singlePageItemCount = singlePageItemCount or nil

    offsetY = offsetY or __G__iOSValue2(90, 90)
    xPadding = xPadding or __G__iOSValue2(10, 33)

    local ret = self:createToolBench(size, imageFormat, startNum, itemTotalCount, singlePageItemCount, imageNextStep, offsetX, offsetY, xPadding)

    return ret
end


_G["config_bench"] = config_bench
