
--==================================================
--	@Brief:    创建一个场景文件
--	@Author:   Rios
--	@Date:     2015-07-14
--==================================================

-- 获取lua文件构造器类
local LuaFileCreator = require("lua_file_creator")

require "file_instructor"

local ClassFileInstructor = BaseClass(FileInstructor)

function ClassFileInstructor:__init()
	FileInstructor.__init(self)
end

function ClassFileInstructor:template()
	local class_name = self:className()
	local super_class_name = "Scene"

	local tbl = {
		"___REPLACE_THIS_CLASS_NAME__ = ___REPLACE_THIS_CLASS_NAME__ or class(\"___REPLACE_THIS_CLASS_NAME__\", ___SUPER_CLASS___)\n",
		"\n",
		"\n",
		"----------------------------------------------------\n",
		"-- Life Cycle\n",
		"----------------------------------------------------\n",
		"function ___REPLACE_THIS_CLASS_NAME__:ctor(scene_data)\n",
		"	___SUPER_CLASS___.ctor(self)\n",
		"	self.scene_data = scene_data or {}\n",
		"	--Add aLayer to scene here. For example: self:addChild(aLayer)\n",
		"end\n",
		"\n",
		"function ___REPLACE_THIS_CLASS_NAME__:onEnter(scene_data)\n",
		"	___SUPER_CLASS___.Enter(self)\n",
		"	--Scene enter do something here\n",
		"end\n",
		"\n",
		"function ___REPLACE_THIS_CLASS_NAME__:onExit(scene_data)\n",
		"	___SUPER_CLASS___.Exit(self)\n",
		"	--Scene exit do something here\n",
		"end\n",
		"\n",
		"----------------------------------------------------\n",
		"-- getter and setter\n",
		"----------------------------------------------------\n",
		"function ___REPLACE_THIS_CLASS_NAME__:backgroundMusic()\n",
		"	return nil\n",
		"end\n",
		"\n",
		"function ___REPLACE_THIS_CLASS_NAME__:voiceOver()\n",
		"	return nil\n",
		"end\n",
		"\n",
	}
	if class_name then
		for i,v in ipairs(tbl) do
			tbl[i] = string.gsub(v, "___REPLACE_THIS_CLASS_NAME__", class_name)
		end
	end
	if super_class_name then 
		for i,v in ipairs(tbl) do
			tbl[i] = string.gsub(v, "___SUPER_CLASS___", super_class_name)
		end
	end
	return tbl
end

-- 配置作者信息(Optional)
function ClassFileInstructor:authorName()
	return "Rios"
end

function ClassFileInstructor:className()
	return "scene_test_appindexing"
end

function ClassFileInstructor:filePath()
	local file_prepath = PATH_CONFIG.SAMPLE_SCENE
	local file_name = "scene_test_appindexing"
	local file_path  = string.format("%s%s", file_prepath, file_name)
	return file_path
end

-- 实例化一个文件构造器
local luaFileCreator = LuaFileCreator.New()

luaFileCreator:InitWithFileInstructor(ClassFileInstructor.New())

luaFileCreator:CreateLuaFile()

