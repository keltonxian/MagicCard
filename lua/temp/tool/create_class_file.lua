
--==================================================
--	@Brief:    创建一个继承类文件
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
	local super_class_name = self:superClassName()

	local tbl = {
		"___REPLACE_THIS_CLASS_NAME__ = ___REPLACE_THIS_CLASS_NAME__ or class(\"___REPLACE_THIS_CLASS_NAME__\", ___SUPER_CLASS___)\n",
		"\n",
		"\n",
		"function ___REPLACE_THIS_CLASS_NAME__:ctor()\n",
		"	___SUPER_CLASS___.ctor(self)\n",
		"end\n",
		"\n",
		"----------------------------------------------------\n",
		"-- Demo\n",
		"----------------------------------------------------\n",
		"function ___REPLACE_THIS_CLASS_NAME__:test()\n",
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

function ClassFileInstructor:superClassName()
	return "AAAAA"
end

function ClassFileInstructor:className()
	return "BBBBB"
end

function ClassFileInstructor:filePath()
	local file_prepath = PATH_CONFIG.LIB
	local file_name = "BBBBB"
	local file_path  = string.format("%s%s", file_prepath, file_name)
	return file_path
end

-- 实例化一个文件构造器
local luaFileCreator = LuaFileCreator.New()

luaFileCreator:InitWithFileInstructor(ClassFileInstructor.New())

luaFileCreator:CreateLuaFile()

