require "Cocos2d"
require "Cocos2dConstants"

-- cclog
function cclog(...)
	print(string.format(...));
end

function kdebug(...)
	local msg = string.format(...);
	msg = "DEBUG " .. msg;
	print(msg);
end

function kerror(...)
	local msg = string.format(...);
	msg = "ERROR " .. msg;
	print(msg);
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	local tb = debug.traceback();
	if nil ~= show_err then
		local t = string.format("LUA ERROR:\n%s\ndebug.traceback\n%s", tostring(msg), tb);
		show_err(t, true);
	end
	cclog("----------------------------------------")
	cclog("LUA ERROR: " .. tostring(msg) .. "\n")
	cclog(tb)
	cclog("----------------------------------------")
	return msg
end

-- 游戏逻辑引擎引入
require "base/GameApplication"

local function main()
	collectgarbage("collect");
	-- avoid memory leak
	collectgarbage("setpause", 100);
	collectgarbage("setstepmul", 5000);
    -- 游戏逻辑引擎开始运行
    game_app:start()
end

-----------------------------------------------------------------------------
-- Lua AppDelegate
-----------------------------------------------------------------------------
-- redefine the application event hooks
__G__onApplicationDidFinishLaunching = function()
    return game_app:applicationDidFinishLaunching()
end

__G__onApplicationDidEnterBackground = function()
    return game_app:applicationDidEnterBackground()
end

__G__onApplicationWillEnterForeground = function()
    return game_app:applicationWillEnterForeground()
end

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end
xpcall(main, __G__TRACKBACK__)
