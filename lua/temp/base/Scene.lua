
--[[--==================================================
--	@Brief:    场景基类
--	@Author:   Rios
--	@Date:     2015-07-14
	假设从A场景切换到B场景，调用各场景方法的顺序为：
		如果没有切换效果(transition)，则先调用B的init()，再调用A的onExitTransitionStart()，接着调用A的onExit()，然后调用B的onEnter()，最后调用B的onEnterTransitionFinish；
		如果有切换效果(transition)，则为先调用B的init()，再调用A的onExitTransitionStart()，接着调用B的onEnter()，然后调用A的onExit()，最后调用B的onEnterTransitionFinish

--]]--==================================================

Scene = Scene or class("Scene", function ( scene_data )
	local _objScene = CCScene:create()
	
	--初始化成员变量
	_objScene.__m_update_interval = 0.04
	_objScene.__m_scene_data = scene_data
	_objScene.__m_schedule_update = false

    local function ccnodeEventHandler(eventType)
        if eventType == "enter" then
            _objScene:Enter()
        elseif eventType == "exit" then
            _objScene:Exit()
        elseif eventType == "enterTransitionFinish" then
            _objScene:EnterTransitionFinish()
        elseif eventType == "exitTransitionStart" then
            _objScene:ExitTransitionStart()
        elseif eventType == "cleanup" then
            _objScene:Cleanup()
        end
    end
    _objScene:registerScriptHandler(ccnodeEventHandler)

	return _objScene
end)

-- override
----------------------------------------------------
function Scene:onEnter( ... )
end

function Scene:onExit( ... )
end

function Scene:onEnterTransitionFinish()
end

function Scene:onExitTransitionStart()
end

function Scene:onCleanup()
end

function Scene:onUpdate( ... )
end
----------------------------------------------------


-- Life Cycle
----------------------------------------------------
function Scene:scheduleUpdate( enable )
	print(string.format(">>>>> Scene:scheduleUpdate(%s) %s", tostring(enable), self.__cname))

	if self.__m_schedule then
		self:stopAction(self.__m_schedule)
		self.__m_schedule = nil
	end
	if enable then
		local callback = function()
			return self:Update(self.__m_update_interval)
		end
		self.__m_schedule = schedule(self, callback, self.__m_update_interval)
	end
end
function Scene:Enter( ... )
	print(string.format(">>>>> Scene:Enter %s", self.__cname))
	
	-- 背景音乐
	local backgroundMusicPath = self:backgroundMusic()
	if backgroundMusicPath then
		-- AudioEngine.stopMusic(true)
		AudioEngine.playMusic(backgroundMusicPath, true)
	end

	-- 进入时的播放音效
	local voice_over = self:voiceOver()
	if voice_over then
		print(">>>> voice_over :", voice_over)
		performWithDelay(self, function() AudioEngine.playEffect(voice_over, false) end, 0.5)
	end

	self:onEnter( ... )
end

function Scene:Exit( ... )
	print(string.format(">>>>> Scene:Exit %s", self.__cname))

	self:scheduleUpdate(false)
	self:onExit( ... )
end

function Scene:EnterTransitionFinish()
	print(string.format(">>>>> Scene:EnterTransitionFinish %s", self.__cname))

	return self:onEnterTransitionFinish()
end

function Scene:ExitTransitionStart()
	print(string.format(">>>>> Scene:ExitTransitionStart %s", self.__cname))

	-- AudioEngine.stopAllEffects()
	-- AudioEngine.stopMusic(true)

	return self:onExitTransitionStart()
end

function Scene:Cleanup()
	return self:onCleanup()
end

function Scene:Update( ... )
	-- print(">>>>>> Scene:Update")
	return self:onUpdate( ... )
end

----------------------------------------------------
-- Public API
----------------------------------------------------

----------------------------------------------------
-- EventDelegate
----------------------------------------------------
function Scene:handleEvent(event_id, event_data)
	print(">>>>> Scene:handleEvent")
end

function Scene:notifyEvent(event_id, event_data)
	return game_app:notifyEvent(event_id, event_data)
end

----------------------------------------------------
-- getter and setter
----------------------------------------------------

function Scene:getUpdateInverval()
	return self.__m_update_interval
end

function Scene:backgroundMusic()
	return nil
end

function Scene:voiceOver()
	return nil
end
