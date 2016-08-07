
--============================================================
--   @Brief: 	创建一个空文件
--   @Author:  Huaxing Zheng
--   @Date:    2015-05-14-15:05:55
--============================================================

-- 获取lua文件构造器类
local LuaFileCreator = require("lua_file_creator")

require "file_instructor"


local EmptyFileInstructor = BaseClass(FileInstructor)

function EmptyFileInstructor:__init()
	FileInstructor.__init(self)
end

-- 配置作者信息(Optional)
function EmptyFileInstructor:authorName()
	return "Rios"
end

function EmptyFileInstructor:filePath()
	local file_prepath = PATH_CONFIG.SCENE
	local file_name = "untitled"
	local file_path  = string.format("%s%s", file_prepath, file_name)
	return file_path
end

-- 实例化一个文件构造器
local luaFileCreator = LuaFileCreator.New()

luaFileCreator:InitWithFileInstructor(EmptyFileInstructor.New())

luaFileCreator:CreateLuaFile()












