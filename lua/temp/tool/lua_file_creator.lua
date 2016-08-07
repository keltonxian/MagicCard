
--============================================================
--   @Brief: 	lua 文件构造器类
--   @Author:  Huaxing Zheng
--   @Date:    2015-05-14-15:05:02
--============================================================

require "baseclass"

local LuaFileCreator = BaseClass()

--============================================================
-- API
--============================================================
--[[ 
	@Brief: 
		使用构建器初始化
	@Input:
		file_instructor(table<FileInstructor>)
	@Output:
		nil
]]

function LuaFileCreator:InitWithFileInstructor( file_instructor )
	self.file_instructor = file_instructor
end

function LuaFileCreator:CreateLuaFile()
	if not self.file_instructor then
		error(
			[==[>>>>> you have to call the methods:
			LuaFileCreator:InitWithFileInstructor( file_instructor )
			and make sure the file_instructor object is correct.]==])
		return
	end

	local file_location = string.format("%s.lua", self.file_instructor:filePath())

	local file_handle = io.open(file_location, "a+")

	if file_handle then

		if self.file_instructor:hasInstruction() then
			self:append(file_handle, self.file_instructor:instruction())
		end

		self:append(file_handle, self.file_instructor:template())

		file_handle:close()
	end
end


--============================================================
-- Private Methods
--============================================================

function LuaFileCreator:__init()
	
end

function LuaFileCreator:append(file_handle, string_list)
	if file_handle and string_list and type(string_list) == "table" then
		for _, str in ipairs(string_list) do
			file_handle:write(str)
		end
	end
end

return LuaFileCreator








