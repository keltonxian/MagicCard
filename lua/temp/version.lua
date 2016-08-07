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

KEY_PATCH_INDEX = 'unzip_ep_index'; -- see in v_update_res and game.lua check_ip
KEY_COPY_ASSETS_INDEX = 'copy_assets_index';
KEY_LOGIC_VER = 'core_logic_ver';
KEY_GAME_VER = 'core_game_ver';

SHOW_VERSION = 00001;
-- 10004 appstore
-- 10005 for all in pay
-- 10005 for anysdk uc
CLIENT_VERSION = 00001;
CLIENT_PATCH_CONSTANT = 19; -- for game.lua layer_debug delete_res
CLIENT_PATCH = CLIENT_PATCH_CONSTANT;
DEBUG_MODE = false;
RES_DEBUG = false; -- use res(include lua) in res/temp
version_btn_retry = nil;
version_btn_next = nil;
version_btn_del_res = nil;
version_bar = nil;
IP_ADDR = nil;
version_tip = nil;
version_am = nil;
server_list = nil;
--ANYSDK = true;

SKIP_UPDATE = false;

-- also define at game.lua
-- define at game_initialize
CPID               = 0;
CHANNEL_VER        = 0;
VER_APPSTORE       = 1;
VER_APAY_deprecated= 2;
VER_ANYSDK         = 3;
VER_APAY           = 4;
VER_ANYSDK_NO_LOGIN= 5;
VER_LJSDK          = 6;
VER_UCSDK          = 7;

-- ============================ DATA PROCESS START =====================
function delete_download_resource()
	CLIENT_PATCH = CLIENT_PATCH_CONSTANT;
	local user = cc.UserDefault:getInstance();
	user:setIntegerForKey(KEY_PATCH_INDEX, tonumber(CLIENT_PATCH));
	local path = cc.FileUtils:getInstance():getWritablePath() .. 'res/';
	local list = KUtils:dfsFolder(path, 0);
	for i = 1, #list do
		local fname = list[i];
		local p = path .. fname;
		KUtils:deleteDownloadDir(p);
	end 
end

function set_version_tip(tip, no_enter)
	if nil ~= version_tip then
		local t = version_tip:getString();
		if true ~= no_enter then
			t = t .. '\n';
		end
		version_tip:setString(t .. tip);
		--version_tip:setString(tip);
	end
end

function v_unzip_ep(files)
	local utils = cc.FileUtils:getInstance();
	local user = cc.UserDefault:getInstance();
	local mark = user:getIntegerForKey(KEY_PATCH_INDEX);
	--print('ep num mark: ', mark);
	--local tip = 'unzip:\n';
	local dir_path = cc.FileUtils:getInstance():getWritablePath();
	for i = 1, #files do
		local info = files[i];
		local src_path = info.path;
		local fname = info.fname; -- e.g. p1.ep
		local index = tonumber(string.sub(fname, 2, string.len(fname)-3)) or 0;
		if index > mark then
			local dst_path = dir_path;
			set_version_tip(string.format("unpack[%s]...", fname));
			local is_done = KUtils:unzipPatch(src_path, dst_path);
			if true == is_done then
				print('unpack ep done : ', dst_path, index, fname);
				user:setIntegerForKey(KEY_PATCH_INDEX, index);
				--dst_path = dst_path .. string.sub(fname, 1, string.len(fname)-3);
				--utils:addSearchPath(dst_path);
				set_version_tip(string.format("unpack[%s] done", fname));
				--tip = string.format("%sfname[%s][just done]\n", tip, fname);
			else
				print('unpack ep fail : ', src_path);
				set_version_tip(string.format("unpack[%s] fail", fname));
			end
		else
			--local dst_path = dir_path;
			--dst_path = dst_path .. string.sub(fname, 1, string.len(fname)-3);
			--utils:addSearchPath(dst_path);
			--tip = string.format("%sfname[%s][already done]\n", tip, fname);
		end
	end
	print('unzip done!!!!');
	--version_tip:setVisible(false);
	version_bar:setVisible(true);
	v_update_slist();
end

function v_cb_android_ep()
	-- Android:
	-- TODO: ep in asset has copy to writable path, do unzip here, 
	-- 1. maybe should delete the copy file after unzip
	-- 2. set mark to remember has copy the ep or not, maybe do some better way
	local user = cc.UserDefault:getInstance();
	user:setIntegerForKey(KEY_COPY_ASSETS_INDEX, 1);
	local files = {};
	local path = cc.FileUtils:getInstance():getWritablePath() .. 'a_local_ep/';
	local ret = KUtils:createDirByPath(path);
	if 0 ~= ret then
		print('BUG cb_android create a_local_ep dir fail');
	end
	local list = KUtils:dfsFolder(path, 0);
	for i = 1, #list do
		local fname = list[i];
		--print('fname: ', fname);
		local n = string.find(fname, ".ep");
		if n+2 == string.len(fname) then
			local p = path .. fname;
			table.insert(files, { path = p, fname = fname });
		end
	end
	v_unzip_ep(files);
end

function v_process_data()
	-- TODO: handle error case
	local platform = cc.Application:getInstance():getTargetPlatform();
	if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_MAC then
		local files = {};
		local path = KUtils:getResourcePath() .. '/patch/';
		local list = KUtils:dfsFolder(path, 0);
		print('path, #list:', path, #list);
		for i = 1, #list do
			local fname = list[i];
			local n = string.find(fname, ".ep");
			if n+2 == string.len(fname) then
				local p = path .. fname;
				table.insert(files, { path = p, fname = fname });
			end
		end
		v_unzip_ep(files);
	elseif platform == cc.PLATFORM_OS_ANDROID then
		local user = cc.UserDefault:getInstance();
		local mark = user:getIntegerForKey(KEY_COPY_ASSETS_INDEX);
		if 1 == mark then
			v_cb_android_ep();
			return;
		end
		local path = cc.FileUtils:getInstance():getWritablePath() .. 'a_local_ep';
		local ret = KUtils:createDirByPath(path);
		if 0 ~= ret then
			print('BUG create a_local_ep dir fail');
		end
		local args = { 
			path, v_cb_android_ep,
		};    
		local sigs = "(Ljava/lang/String;I)V";
		local luaj = require "luaj";
		local class_name = "org/cocos2dx/lua/AppActivity";
		local ok, ret = luaj.callStaticMethod(class_name, "copyRes", args, sigs);
		--print('--- copy_files_to_writable_path, ok, ret: ', ok, ret);
		--if ok then
		--end
	else -- elseif platform == cc.PLATFORM_OS_WINDOWS then
		local files = {};
		-- print_search_path();
		local utils = cc.FileUtils:getInstance();
		local searchPath = utils:getSearchPaths();
		local path = searchPath[1] .. 'res/patch/';
		local list = KUtils:dfsFolder(path, 0);

		for i = 1, #list do
			local fname = list[i];
			local n = string.find(fname, ".ep");
			if n+2 == string.len(fname) then
				local p = path .. fname;
				table.insert(files, { path = p, fname = fname });
			end
		end
		v_unzip_ep(files);
	end
end
-- ============================ DATA PROCESS END   =====================

-- ============================ DOWNLOAD PROCESS START =====================
function v_update_by_path(ip_res, callback)
	local save_path = cc.FileUtils:getInstance():getWritablePath();
	--kdebug('save_path: ', save_path);

	local item = version_btn_retry;
	local bar = version_bar;
	local progress = bar:getChildByTag(111);
	local amanager = nil;

	local function on_success(flag)
		kdebug("success");
		--amanager:release();
		callback(flag);
	end

	local function on_error(error_code)
		kerror("error_code: ", error_code);
		if error_code == cc.ASSETSMANAGER_CREATE_FILE then
			kerror("fail create file");
			set_version_tip(string.format("创建文件失败"));
			item:setVisible(true);
		elseif error_code == cc.ASSETSMANAGER_NETWORK then
			kerror("no network");
			set_version_tip(string.format("网络异常"));
			item:setVisible(true);
		elseif error_code == cc.ASSETSMANAGER_NO_NEW_VERSION then
			kdebug("no new version");
			on_success(error_code); -- set a flag true means download res is done
		elseif error_code == cc.ASSETSMANAGER_UNCOMPRESS then
			kerror("fail uncompress");
			set_version_tip(string.format("解压失败"));
			item:setVisible(true);
		end
	end

	local function on_progress(percent)
		if nil == percent then
			return;
		end
		--kdebug("percent[%f]", percent);
		progress:setPercentage(percent);
		local x = progress:getPositionX();
		local s1 = progress:getContentSize();
		--local s2 = tap:getContentSize();
		--tap:setPositionX(x - s1.width/2 + s1.width * percent / 100 - s2.width/2);
	end

	--KUtils:deleteDownloadDir(save_path);
	amanager = version_am;
	amanager:setPackageUrl(ip_res);
	--amanager:setVersionFileUrl(ip_res);
	amanager:setStoragePath(save_path);
	--amanager = cc.AssetsManager:new(ip_res, ip_version, save_path); --is autorelease
	--amanager = cc.AssetsManager:create(ip_res, ip_version, save_path, on_error, on_progress, on_success);
	--if true == GAMELUA_DEBUG then
		--amanager:deleteVersion();
	--end
	local user = cc.UserDefault:getInstance();
	local mark = user:getStringForKey('re_update_lua');
	if nil ~= mark and 'yes' == mark then
		amanager:deleteVersion();
	end
	--print('version-------: ', amanager:getVersion());
	--amanager:retain();
	amanager:setDelegate(on_error, cc.ASSETSMANAGER_PROTOCOL_ERROR);
	amanager:setDelegate(on_progress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS);
	amanager:setDelegate(on_success, cc.ASSETSMANAGER_PROTOCOL_SUCCESS);
	amanager:setConnectionTimeout(5);
	--amanager:deleteVersion();

	--[[
	local ver = t_version .. ": " .. amanager:getVersion();
	local label = cc.Label:createWithSystemFont(ver, "Arial", 25);
	label:setAnchorPoint(1, 0);
	label:setPosition(vsize.width, 0);
	layer:addChild(label);
	label_version = label;
	]]--

	amanager:update();
end

function v_update_done()
	version_btn_retry:setVisible(false);
	--[[
	version_btn_next:setVisible(true);
	version_btn_del_res:setVisible(true);
	]]--
	main_start_game();
end

function v_cb_res(flag)
	if cc.ASSETSMANAGER_NO_NEW_VERSION == flag then
		set_version_tip(string.format("更新资源 完毕"));
		v_update_done();
		--main_start_game();
		return;
	end
	local user = cc.UserDefault:getInstance();
	local mark = user:getIntegerForKey(KEY_PATCH_INDEX);
	mark = mark + 1;
	user:setIntegerForKey(KEY_PATCH_INDEX, mark);
	--set_version_tip(string.format("更新资源[%d] 成功", mark));
	set_version_tip(string.format("成功", mark), true);
	v_update_res();
end

function v_update_res()
	local ip = IP_ADDR;
	local user = cc.UserDefault:getInstance();
	local mark = user:getIntegerForKey(KEY_PATCH_INDEX);
	if 0 == mark then
		mark = CLIENT_PATCH;
		user:setIntegerForKey(KEY_PATCH_INDEX, tonumber(mark));
	end
	mark = mark + 1;

	local ip_res = string.format("http://%s:8899/patch/p%d.ep", ip, mark);
	--print('patch ip_res: ', ip_res);
	set_version_tip(string.format("更新资源[%d]...", mark));
	v_update_by_path(ip_res, v_cb_res);
end

function v_cb_core(flag)
	--print('v_update_core done');
	if cc.ASSETSMANAGER_NO_NEW_VERSION == flag then
		set_version_tip(string.format("找不到逻辑文件"), true);
		version_btn_retry:setVisible(true);
		return;
	end
	set_version_tip(string.format("成功"), true);
	--[[
	local utils = cc.FileUtils:getInstance();
	local path = utils:getWritablePath() .. 'g/';
	local ret = KUtils:createDirByPath(path);
	if 0 ~= ret then
		print('BUG create g/ dir fail');
		set_version_tip(string.format("创建文件夹g 失败"));
		version_btn_retry:setVisible(true);
		return;
	end
	utils:addSearchPath(path);
	]]--

	local utils = cc.FileUtils:getInstance();
	--local core_list = {'logic.lua', 'lang_zh.lua', 'game.lua', 'lang_local.lua'};
	local core_list = {'logic.evil', 'lang_zh.lua', 'game.evil', 'lang_local.lua'};
	local tip = '';
	for i=1, #core_list do
		local name = core_list[i];
		if false == utils:isFileExist(name) then
			tip = string.format("%s[%s]", tip, name);
		end
	end
	--[[
	local utils = cc.FileUtils:getInstance();
	local b_logic = utils:isFileExist("logic.lua");
	local b_lang = utils:isFileExist("lang_zh.lua");
	local b_game = utils:isFileExist("game.lua");
	local b_local = utils:isFileExist("lang_local.lua");
	--local b_game = utils:isFileExist("game.evil");
	print('b_logic: ', b_logic);
	print('b_lang: ', b_lang);
	print('b_game: ', b_game);
	print('b_local: ', b_local);
	]]--
	--if true ~= b_logic or true ~= b_lang or true ~= b_game or true ~= b_local then
	if 0 < string.len(tip) then
		set_version_tip(string.format("缺少逻辑文件%s", tip));
		version_btn_retry:setVisible(true);
		return;
	end

	v_update_res();
end

function v_update_core()
	set_version_tip(string.format("更新逻辑..."));
	local ip = IP_ADDR;
	local user = cc.UserDefault:getInstance();
	local logic_ver = user:getIntegerForKey(KEY_LOGIC_VER);
	local game_ver = user:getIntegerForKey(KEY_GAME_VER);
	--http://host:8080/s/patch.core?game_ver=1025&logic_ver=1029
	local ip_res = string.format("http://%s:8899/s/patch.core?game_ver=%d&logic_ver=%d", ip, game_ver, logic_ver);
	--print('ip_core: ', ip_res);
	v_update_by_path(ip_res, v_cb_core);
end

function v_cb_slist()
	local save_path = cc.FileUtils:getInstance():getWritablePath();
	local path = string.format("%sslist", save_path);
	local utils = cc.FileUtils:getInstance();
	utils:addSearchPath(path);
	local is_has = utils:isFileExist('slist.txt');
	--print('---- is_has slist.txt: ', is_has);
	if true ~= is_has then
		set_version_tip(string.format("失败"), true);
		version_btn_retry:setVisible(true);
		return;
	end
	local is_test = false;
	local path = utils:getWritablePath();
	path = path .. 'slist/slist.txt';
	local list = {};
	local file = io.open(path, "r"); 
	if nil ~= file then
		local data = file:read("*all");
		--print('data: ', data);
		local lines = version_csplit(data, "[\n\r]");
		for i = 1, #lines do
			--print('line, i: ', i, lines[i]);
			local l = version_csplit(lines[i], ","); 
			-- flag > 0 normal server, == 0 debug server
			local ld = { sid = l[1], ip = l[2], flag = l[3], name = l[4], 
			state = l[5] };
			if true ~= RES_DEBUG and '99' == ld.flag then
				is_test = true;
			end
			table.insert(list, ld);
		end   
		io.close(file);
	end 
	if 0 == #list then
		version_btn_retry:setVisible(true);
	end
	local index = 1;
	local user = cc.UserDefault:getInstance();
	local mark = user:getStringForKey('ip_addr');
	if true == is_test then
		user:setStringForKey('is_test_ip', 'yes');
		mark = nil;
	else
		local f = user:getStringForKey('is_test_ip');
		if 'yes' == f then
			user:setStringForKey('is_test_ip', 'no');
			mark = nil;
		end
	end
	if nil ~= mark or '' ~= mark then
		for i = 1, #list do
			local info = list[i];
			if mark == info.ip then
				index = i;
				break;
			end
		end
	end
	mark = list[index].ip;
	server_list = list;
	IP_ADDR = mark;
	--http://host:8080/s/patch.core?game_ver=1025&logic_ver=1029
	--version_update_logic(IP_ADDR);
	print('IP_ADDR: ', IP_ADDR);
	set_version_tip(string.format("成功"), true);
	v_update_core();
end

function v_update_slist()
	set_version_tip(string.format("获取服务器列表..."));
	local flag = 0; -- 0 official, 1 test
	if true == RES_DEBUG then
		flag = 1;
	end
	local utils = cc.FileUtils:getInstance();
	local dic = utils:getValueMapFromFile("game_config.plist");
	local ip = dic["IP"];
	--local ip_res = string.format("http://%s:8899/slist.zip", ip);
	local ip_res = string.format("http://%s:8899/s/patch.slist?version=%d&flag=%d", ip, CLIENT_VERSION, flag);
	--print('slist ip_res: ', ip_res);
	v_update_by_path(ip_res, v_cb_slist);
end

-- ============================ DOWNLOAD PROCESS END   =====================

function print_search_path()
	local utils = cc.FileUtils:getInstance();
	local l = utils:getSearchPaths();
	for i = 1, #l do
		print('path:', i, l[i]);
	end
end

function get_lang()
	return 1;
	--[[
	local platform = cc.Application:getInstance():getTargetPlatform();
	if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD then
		local args = {}; 
		local luaoc = require "luaoc";
		local class_name = "SysTool";
		local ok, ret = luaoc.callStaticMethod(class_name, "getLanguage", args);
		if true == ok then
			return ret;
		end
	elseif platform == cc.PLATFORM_OS_ANDROID then
		return 1;
	else
		return 1;
	end
	return 1;
	]]--
end

-- delim e.g " " or "[ ]" or "[%.]" or "[%. ]"
function version_csplit(str, delim)
	--print('DEBUG csplit str, delim: ', str, delim);
	local result = {};
	if nil == str then
		return result;
	end 
	local count = 200; -- max 200 token
	local token; 

	repeat 
		local s_pos, e_pos = string.find(str, delim);
			if s_pos==nil or e_pos == nil then
			break; 
		end 
		-- print('s_pos = ', s_pos, ' e_pos = ', e_pos);
		token = string.sub(str, 1, s_pos-1);
		if string.len(token) > 0 then
			result[ #result + 1] = token;
		end 
		str = string.sub(str, e_pos+1); -- missing len means up to full len
		-- print('Result i : ', result[#result], '  str=', str);
		count = count - 1;
	until count <= 0;

	if string.len(str) > 0 then
		result[ #result + 1] = str ;
	end

	return result;
end

function main_start_game()
	--print_search_path();
	require ("game");
	local user = cc.UserDefault:getInstance();
	user:setIntegerForKey(KEY_LOGIC_VER, tonumber(LOGIC_VERSION));
	user:setIntegerForKey(KEY_GAME_VER, tonumber(GAME_VERSION));
	start_game();
end

v_anysdk_init_flag = nil;
function v_anysdk_init()
	require ("anysdkConst");
	local agent = AgentManager:getInstance();
	local appKey = "3914B2B1-A932-9543-3CA9-31ED2ED19477";
	local appSecret = "04ad2aabbc8e4cac0f8f1aec0e3e2ee3";
	local privateKey = "7D2713641F7809036DB5AB2FC78C8ABE";
	--local oauthLoginServer = "http://t3.17kapai.com:8899/pay_server/anysdklogin";
	local oauthLoginServer = string.format("http://%s:8899/pay_server/anysdklogin", IP_ADDR);
	--init
	agent:init(appKey,appSecret,privateKey,oauthLoginServer);
	--load
	agent:loadALLPlugin();
	v_anysdk_init_flag = true;
end

function main()
	collectgarbage("collect");
	-- avoid memory leak
	collectgarbage("setpause", 100);
	collectgarbage("setstepmul", 5000);

	local platform = cc.Application:getInstance():getTargetPlatform();
	cc.FileUtils:getInstance():addSearchPath("src");
	cc.FileUtils:getInstance():addSearchPath("res");
	if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_MAC then
		cc.FileUtils:getInstance():addSearchPath("startup");
	elseif platform == cc.PLATFORM_OS_ANDROID then
		cc.FileUtils:getInstance():addSearchPath("res/startup");
	else -- windows
		cc.FileUtils:getInstance():addSearchPath("res/startup");
	end
	local res_path = cc.FileUtils:getInstance():getWritablePath();
	cc.FileUtils:getInstance():addSearchPath(res_path);

	local dic = cc.FileUtils:getInstance():getValueMapFromFile("game_config.plist");
	CPID = dic["CPID"];
	CHANNEL_VER = dic["CHANNEL_VER"];
	if VER_ANYSDK == CHANNEL_VER then
		v_anysdk_init();
	end

	local director = cc.Director:getInstance();
	local glview = director:getOpenGLView();
	if nil == glview then
		if platform == cc.PLATFORM_OS_MAC then
			glview = cc.GLView:createWithRect("决战王者", cc.rect(0, 0, 400, 600));
		elseif platform == cc.PLATFORM_OS_WINDOWS then
			glview = cc.GLView:createWithRect("决战王者", cc.rect(0, 0, 400, 600));
		else
			glview = cc.GLView:createWithRect("决战王者", cc.rect(0, 0, 640, 960));
		end
		director:setOpenGLView(glview);
	end

	local frame_size = glview:getFrameSize();

	glview:setDesignResolutionSize(640, 640 * frame_size.height / frame_size.width, cc.ResolutionPolicy.SHOW_ALL);

	director:setDisplayStats(false);
	director:setAnimationInterval(1.0 / 60);
	
	print('--jit.version: ', jit.version);
	--local ffi = require 'ffi'
	--print('------ luajit : ', jit.version);
	--table.foreach(ffi, print);

	--print_search_path();
	local lang_type = get_lang();
	local t_retry, t_version;
	if lang_type == 1 then -- chinese
		t_retry = '重试';
		t_version = '资源版本';
	else
		t_retry = 'reload';
		t_version = 'version';
	end

	local vsize = director:getVisibleSize();
	local origin = director:getVisibleOrigin();

	--kdebug("pos[%f][%f]size[%f][%f]",origin.x,origin.y,vsize.width,vsize.height);

	local layer = cc.Layer:create();
	local sprite = cc.Sprite:create("bg_200.png");
	sprite:setAnchorPoint(0.5, 0.5);
	sprite:setPosition(vsize.width/2, vsize.height/2);
	if vsize.width / 640 > vsize.height / 960 then
		sprite:setScale(vsize.width/640);
	else
		sprite:setScale(vsize.height/960);
	end
	layer:addChild(sprite);

	sprite = cc.Sprite:create("logo_1.png");
	sprite:setAnchorPoint(0.5, 1);
	sprite:setPosition(vsize.width/2, vsize.height/2+328);
	sprite:setScale(vsize.width / 640);
	layer:addChild(sprite);

	local pos = cc.p(vsize.width/2, 200);
	local bar = cc.Node:create();
	bar:setAnchorPoint(0.5, 0);
	bar:setPosition(pos);
	layer:addChild(bar);

	sprite = cc.Sprite:create("bg_207.png");
	sprite:setAnchorPoint(0.5, 0.5);
	sprite:setPosition(cc.p(0, 0));
	bar:addChild(sprite);

	sprite = cc.Sprite:create("bg_208.png");
	local progress = cc.ProgressTimer:create(sprite);
	progress:setAnchorPoint(0.5, 0.5);
	--progress:setPosition(pos);
	progress:setPosition(cc.p(0, 0));
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	progress:setMidpoint(cc.p(0, 1));
	progress:setBarChangeRate(cc.p(1, 0));
	progress:setPercentage(0);
	--layer:addChild(progress);
	progress:setTag(111);
	bar:addChild(progress);

	sprite = cc.Sprite:create("bg_209.png");
	sprite:setAnchorPoint(0.5, 0.5);
	--sprite:setPosition(pos);
	--layer:addChild(sprite);
	sprite:setPosition(cc.p(0, 0));
	bar:addChild(sprite);

	--bar:setVisible(false);
	version_bar = bar;

	--[[
	local tap = cc.Sprite:create("bar_loading_3.png");
	tap:setAnchorPoint(0.5, 0.5);
	tap:setPosition(cc.p(progress:getPositionX()-progress:getContentSize().width/2, progress:getPositionY()));
	layer:addChild(tap);
	]]--
	sprite = cc.AssetsManager:new("", "", ""); --is autorelease
	layer:addChild(sprite);
	version_am = sprite;

	sprite = cc.Label:createWithSystemFont('开启...', "Arial", 25, cc.size(vsize.width, vsize.height/2), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM);
	sprite:setColor(cc.c3b(0, 0, 0));
	sprite:setAnchorPoint(0.5, 0);
	sprite:setPosition(cc.p(vsize.width/2, 300));
	layer:addChild(sprite);
	version_tip = sprite;

	local menu = cc.Menu:create();
	menu:setPosition(0, 0);
	layer:addChild(menu);

	local item, l;
	local function cb_retry(...)
		local args = {...};
		local item = args[2];
		version_tip:setString('重新更新');
		item:setVisible(false);
		v_update_slist(IP_ADDR);
	end
	item = cc.MenuItemImage:create("btn_8.png", "btn_8.png");
	item:setAnchorPoint(0.5, 0);
	item:setPosition(vsize.width/2, 80);
	item:registerScriptTapHandler(cb_retry);
	l = cc.Label:createWithSystemFont(t_retry, "Arial", 25);
	l:setAnchorPoint(0.5, 0.5);
	l:setPosition(item:getContentSize().width/2, item:getContentSize().height/2);
	item:addChild(l);
	item:setVisible(false);
	version_btn_retry = item;
	menu:addChild(item);

	--[[
	local function cb_next(...)
		local args = {...};
		local item = args[2];
		item:setVisible(false);
		main_start_game();
	end
	item = cc.MenuItemImage:create("btn_8.png", "btn_8_s.png");
	item:setAnchorPoint(0.5, 0);
	item:setPosition(vsize.width/2, 80);
	item:registerScriptTapHandler(cb_next);
	l = cc.Label:createWithSystemFont('进入游戏', "Arial", 25);
	l:setAnchorPoint(0.5, 0.5);
	l:setPosition(item:getContentSize().width/2, item:getContentSize().height/2);
	item:addChild(l);
	item:setVisible(false);
	version_btn_next = item;
	menu:addChild(item);

	local function cb_del_res(...)
		local args = {...};
		local item = args[2];
		version_tip:setString('重新更新');
		version_btn_retry:setVisible(false);
		item:setVisible(false);
		v_update_slist(IP_ADDR);
		delete_download_resource();
		v_update_slist(IP_ADDR);
	end
	item = cc.MenuItemImage:create("btn_8.png", "btn_8_s.png");
	item:setAnchorPoint(0, 1);
	item:setPosition(0, vsize.height);
	item:registerScriptTapHandler(cb_del_res);
	l = cc.Label:createWithSystemFont("删除资源", "Arial", 25);
	l:setAnchorPoint(0.5, 0.5);
	l:setPosition(item:getContentSize().width/2, item:getContentSize().height/2);
	item:addChild(l);
	item:setVisible(false);
	version_btn_del_res = item;
	menu:addChild(item);
	]]--

	local folders = { 'slist', 'g', 'res' };
	local wpath = cc.FileUtils:getInstance():getWritablePath();
	for i = 1, #folders do
		local f = folders[i];
		local p = wpath .. f;
		local ret = KUtils:createDirByPath(p);
		if 0 ~= ret then
			set_version_tip(string.format("创建文件夹%s 失败", f));
			version_btn_retry:setVisible(true);
			return;
		end
		cc.FileUtils:getInstance():addSearchPath(p, true);
	end

	if true == RES_DEBUG then
		local platform = cc.Application:getInstance():getTargetPlatform();
		if platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_MAC then
			cc.FileUtils:getInstance():addSearchPath("temp", true);
		elseif platform == cc.PLATFORM_OS_ANDROID then
			cc.FileUtils:getInstance():addSearchPath("res/temp", true);
		else -- windows
			cc.FileUtils:getInstance():addSearchPath("res/temp", true);
		end
		DEBUG_MODE = true;
	end

	--[[
	if true == ANYSDK then
		require ("anysdkConst");
	end
	]]--
	
	--print_search_path();
	--v_process_data();
	if true == SKIP_UPDATE then
		local utils = cc.FileUtils:getInstance();
		local dic = utils:getValueMapFromFile("game_config.plist");
		local ip = dic["IP"];
		local ld = { sid = '1', ip = ip, flag = '1', name = '本机', state = '1' };
		local list = { ld };
		server_list = list;
		IP_ADDR = ip;
		local function cb_start()
			layer:unscheduleUpdate();
			main_start_game();
		end
		layer:scheduleUpdateWithPriorityLua(cb_start, 1);
	else
		v_update_slist();
	end

	--local function onNodeEvent(event)
		--print('event: ', event);
	--end
	--layer:registerScriptHandler(onNodeEvent);
	local tap_count = 10;
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(
		function(touch, event)
			return true;
		end,  
		cc.Handler.EVENT_TOUCH_BEGAN
	);    
	listener:registerScriptHandler(
		function(touch, event)
			if true == DEBUG_MODE then
				return;
			end
			local location = touch:getLocation();
			if location.x > vsize.width-100 and location.y > vsize.height-100 then
				tap_count = tap_count - 1;
			end
			if tap_count < 0 then
				set_version_tip(string.format("====测试模式==="));
				DEBUG_MODE = true;
			end
		end,  
		cc.Handler.EVENT_TOUCH_ENDED
	);  
	local eventDispatcher = layer:getEventDispatcher();
	--print('lis layer: ', listener, layer, tolua.type(eventDispatcher));
	--eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer);

	local scene = cc.Scene:create();
	scene:addChild(layer);

	--cc.Director:getInstance():runWithScene(scene);

	if director:getRunningScene() then
		director:replaceScene(scene);
	else
		director:runWithScene(scene);
	end

end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
	error(msg)
end
