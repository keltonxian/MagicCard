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

local function initSearchPath()
	local platform = cc.Application:getInstance():getTargetPlatform()
	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")
	--cc.FileUtils:getInstance():addSearchPath("res/src")
	if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_MAC then
		cc.FileUtils:getInstance():addSearchPath("res/font")
		--cc.FileUtils:getInstance():addSearchPath("res/bg")
	elseif platform == cc.PLATFORM_OS_ANDROID then
		cc.FileUtils:getInstance():addSearchPath("res/startup")
	else -- windows
		cc.FileUtils:getInstance():addSearchPath("res/startup")
	end
	local res_path = cc.FileUtils:getInstance():getWritablePath()
	cc.FileUtils:getInstance():addSearchPath(res_path)

	--[[
	local dic = cc.FileUtils:getInstance():getValueMapFromFile("game_config.plist");
	CPID = dic["CPID"];
	CHANNEL_VER = dic["CHANNEL_VER"];
	]]--
end

local __G__gameApp = nil

local function main()
	collectgarbage("collect");
	-- avoid memory leak
	collectgarbage("setpause", 100);
	collectgarbage("setstepmul", 5000);

	initSearchPath()

	-- 游戏逻辑引擎引入
	require "base/GameApplication"
    -- 游戏逻辑引擎开始运行
	__G__gameApp = GameApplication:getInstance()
    __G__gameApp:start()
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
