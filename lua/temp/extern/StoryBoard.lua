
--==================================================
--    @Brief:    故事板弹窗 
--    @Author:   Rios
--    @Date:     2015-07-17
--==================================================

StoryBoard = StoryBoard or class("StoryBoard", Layer)


function StoryBoard:ctor()
    local aDarkLayer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 255 * 0.6), __G__canvasSize.width, __G__canvasSize.height)
    aDarkLayer:ignoreAnchorPointForPosition(false)
    aDarkLayer:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)
    self:addChild(aDarkLayer, 1)

    local aContentLayer = Layer.create()
    aContentLayer:setPosition(0, 0)
    self:addChild(aContentLayer, 2)
    self:addToTouchResponders(aContentLayer)

    self.bgLayer = aDarkLayer
    self.contentLayer = aContentLayer
    self:setVisible(false)
end

----------------------------------
--  public methods
----------------------------------
function StoryBoard:addContentLayer( aLayer )
    self.contentLayer:addChild(aLayer, 2)
    self.contentLayer:addToTouchResponders(aLayer)
end

function StoryBoard:show()
    if self.showCallBack and type(self.showCallBack == "function") then self.showCallBack() end

    self:setVisible(true)
    self.contentLayer:setPosition(__G__canvasSize.width + self.contentLayer:getContentSize().width, self.contentLayer:getPositionY())
    -- animate to show storyboard
    local move = CCMoveBy:create(1.5, CCPointMake(__G__canvasSize.width + self.contentLayer:getContentSize().width, 0))
    local move_ease_inout = CCEaseElasticInOut:create(move, 0.5)
    local array = CCArray:create()
    array:addObject(move_ease_inout:reverse())
    self.contentLayer:runAction(CCSequence:create(array))
end

function StoryBoard:hide()
    if self.hadHide then return end
    self.hadHide = true
    -- animate to show storyboard
    local move = CCMoveBy:create(1.5, CCPointMake(__G__canvasSize.width + self.contentLayer:getContentSize().width, 0))
    local move_ease_inout = CCEaseElasticInOut:create(move, 0.5)
    local array = CCArray:create()
    array:addObject(move_ease_inout)
    array:addObject(CCCallFunc:create(function() 
        self:setVisible(false)
        if self.hideCallBack and type(self.hideCallBack == "function") then self.hideCallBack() end
     end))
    self.contentLayer:runAction(CCSequence:create(array))
end

----------------------------------------------------
-- getter and setter
----------------------------------------------------
function StoryBoard:setShowCallBack(aFun)
    self.showCallBack = aFun
end

function StoryBoard:setHideCallBack(aFun)
    self.hideCallBack = aFun
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function StoryBoard:test()
    local aStoryBoard = StoryBoard.new()

    -- test color layer
    -- local aSize = __G__canvasSize
    -- local aContentLayer = CCLayerColor:create(ccc4(255, 0x00, 0x00, 255), aSize.width, aSize.height)
    -- aContentLayer:setPosition(0, 0)
    -- aStoryBoard:addContentLayer(aContentLayer)

    -- add image and button
    local aContentLayer = Layer.create()
    aContentLayer:layout({
        {
            x = 0,
            y = 0,
            z = 0,
            tag = 1,
            touch = -1,
            class = SpriteLayer,
            image = string.format("image/samples/bg/%s.jpg",__G__iOSValue("i4","i5","ipad")),
            scale = 0.5,
        },
        {
            x = 200,
            y = __G__visibleSize.height - 400,
            z = 10,
            tag = 2,
            touch = 1,
            class = ButtonLayer,
            image = "image/samples/close.png",
            attributes = {
                minClickInterval = 1,
                touchSound = "sfx/common/menu.mp3",
                clickHandler = function(s)
                    aStoryBoard:hide()
                end,
            },
        },
    })
    aContentLayer:setPosition(0, 0)
    aStoryBoard:addContentLayer(aContentLayer)

    -- 设置回调
    aStoryBoard:setShowCallBack(function()
        -- 播放音效，隐藏广告等
        cclog("show")
    end)
    aStoryBoard:setHideCallBack(function()
        -- 播放音效，显示广告等
        cclog("hide")
    end)

    -- 显示
    aStoryBoard:show()

    -- 自动隐藏
    performWithDelay(aStoryBoard,function() 
        aStoryBoard:hide() end, 5)

    return aStoryBoard
end

