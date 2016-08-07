-- MoreGamesUI module: providing the functions to create the More Games UI elements

local function createButton(moreGamesData, hideBannerAdOnPopup, checkInterval, revolveInterval)
    checkInterval = checkInterval and checkInterval or 3
    revolveInterval = revolveInterval and revolveInterval or 5

    local button = ButtonLayer.create("lib/moregames/14.png")
    local buttonSize = button:getContentSize()
    button.touchSound = config_sound_effects.common_popup_open
    button.minClickInterval = 1
    button.doClickHandlerOnTouchEnded = true  -- cause it may show the system popup which will intercept the touch ended event so we better do click on touch ended

    function button:checkMoreGamesData()
        if moreGamesData:isReady() then
            return true
        end

        if moreGamesData:hasError() then
            moreGamesData:refresh()
        end

        return false
    end

    function button:revolveMoreGamesIcons()
        local tagShadow = 95536

        if not self:getChildByTag(tagShadow) then
            local f = CCSprite:create("lib/moregames/6.png")
			f:setAnchorPoint(ccp(0, 0))
			f:setPosition(ccp(-5, -3))
			local size = f:getContentSize()
			f:setScaleX(buttonSize.width / size.width * 1.08)
			f:setScaleY(buttonSize.height / size.height * 1.08)
            f:setVisible(false)
            self:addChild(f, 1000, tagShadow)
        end

        local function nextIcon()
            local apps = moreGamesData:getData().apps

            if #apps < 1 then
                local s = self:getChildByTag(tagShadow)
                if s then
                    s:setVisible(false)  -- make sure the shadow is hidden
                end
                return
            end

            if not self.currAppIdx then
                self.currAppIdx = 1
            else
                self.currAppIdx = self.currAppIdx + 1
                if self.currAppIdx > #apps then
                    self.currAppIdx = 1
                end
            end

			local icon = CCClippingNode:create()
			icon:setAnchorPoint(ccp(0.5, 0.5))
			local content = CCSprite:create(apps[self.currAppIdx].icon_file)
			local stencil = CCSprite:create("lib/moregames/moregame_icon_mask.png")
			local size = stencil:getContentSize()
			icon:setContentSize(CCSizeMake(size.width, size.height))
			content:setAnchorPoint(ccp(0, 0))
			content:setPosition(ccp(0, 0))
			stencil:setAnchorPoint(ccp(0, 0))
			stencil:setPosition(ccp(0, 0))
			icon:setStencil(stencil)
			icon:addChild(content)
			icon:setAlphaThreshold(0)
			icon:setInverted(false)

			local size = icon:getContentSize()
			icon:setScaleX(buttonSize.width / size.width * 0.9)
			icon:setScaleY(buttonSize.height / size.height * 0.9)

            self:setStateSprite(icon, "normal")

            local shadow = self:getChildByTag(tagShadow)
            if shadow then
                shadow:setVisible(true)
				size = shadow:getContentSize()
            end
        end

        if self.revolveMoreGamesIconsAction then
            self:stopAction(self.revolveMoreGamesIconsAction)
            self.revolveMoreGamesIconsAction = nil
        end

        nextIcon()  -- change icon immediately
        self.revolveMoreGamesIconsAction = schedule(self, nextIcon, revolveInterval)
    end

    function button:onEnter()
        local function checkReady()
            local ready = self:checkMoreGamesData()

            cclog("check More Games data ready -- %s", tostring(ready))

            if ready then
                self:stopAction(self.checkMoreGamesDataAction)
                self.checkMoreGamesDataAction = nil

                self:revolveMoreGamesIcons()
            end
        end

        self.checkMoreGamesDataAction = schedule(self, checkReady, checkInterval)
    end

    function button:onExit()
        if self.checkMoreGamesDataAction then
            self:stopAction(self.checkMoreGamesDataAction)
            self.checkMoreGamesDataAction = nil
        end
    end

    button.clickHandler = function(sender)
        local function topMostLayer()
            local currParent = sender

            repeat
                currParent = currParent:getParent()
            until (not currParent:getParent()) or (not currParent:getParent().addToTouchResponders)

            return currParent
        end

        if moreGamesData:isReady() then
            __G__showPopup(function(closeCallback) return config_popup.createMoreGames(closeCallback, moreGamesData) end, topMostLayer(), hideBannerAdOnPopup)
        else
            Utils:sharedUtils():messageBox("More Games", "Downloading More Games! Please try again later.", "Ok", function() end);
        end
    end

    return button
end

_G["MoreGamesUI"] = { createButton = createButton, }
