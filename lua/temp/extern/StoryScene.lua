

require "base/Scene"
StoryScene = StoryScene or class("StoryScene", Scene)

function StoryScene:ctor( level )
	

    self.m_story_level = level
end


----------------------------------
--  DelegatePlayStory
----------------------------------
function StoryScene:getStoryImage()
	return string.format("Sketch/level%d.png", self.m_story_level)
end

function StoryScene:getStoryParentLayer()
	return nil
end

function StoryScene:getStoryVoiceOver()
	return string.format("sfx/story/%d.mp3", self.m_story_level+1)
end

function StoryScene:canPlayStory()
	return true
end

function StoryScene:hideBannerAd()
	return true
end

function StoryScene:BackgroundMusic()
    return "sfx/levels.mp3"
end

function StoryScene:VoiceOver()
    return
end

----------------------------------
--  Private Methods
----------------------------------
function StoryScene:playStory( callback )
	local function CALLBACK()
		if callback then
			return callback()
		end
	end

    -- 跳过剧情的测试接口
    if config_game and config_game.DebugNoStory then
        return CALLBACK()
    end

	local storyImage = self:getStoryImage()
	local storyParentLayer = self:getStoryParentLayer()
	if not ( self:canPlayStory() and storyImage and storyParentLayer) then
		return CALLBACK()
	end

    local storySoundHandle = nil
    local autoHideTime = 6
    local hideBannerAd = self:hideBannerAd()
    config_spa.showStory(storyParentLayer, storyImage, __G__iOSValue(0.9, 0.9, 1), function ()
    	-- 关闭事件
        if storySoundHandle then
            AudioEngine.stopEffect(storySoundHandle)
        end

        -- 关闭后的回调
        return CALLBACK()
    end, autoHideTime, hideBannerAd)
    local storyVoiceOver = self:getStoryVoiceOver()
    if storyVoiceOver then
        performWithDelay(storyParentLayer, function ()
            storySoundHandle = AudioEngine.playEffect(storyVoiceOver, false)
        end, 1)
    end
end