


--[==[============================================================
    @Brief:   file instructor <base class>
    @Author:  Huaxing Zheng
    @Date:    2015-05-19-09:05:49
============================================================--]==]

require "baseclass"

require "config_common"


FileInstructor = FileInstructor or BaseClass(nil)


function FileInstructor:__init()

end

function FileInstructor:filePath()
	local file_prepath = PATH_CONFIG and PATH_CONFIG.CURRENT or ""
	local file_name = "untitled"
	return string.format("%s%s", file_prepath, file_name)
end


function FileInstructor:brief()
	return "___BRIEF_PLACEHOLDER___"
end


function FileInstructor:authorName()
	return "___AUTHOR_NAME_PLACEHOLDER___"
end


-- 是否拥有文件头说明(brief author date) 默认有
function FileInstructor:hasInstruction()
	return true
end


-- 文件头说明配置
function FileInstructor:instruction()
	return {
		"\n",
		"--==================================================",
		"\n",
		string.format("--    @Brief:   %s", self:brief()),
		"\n",
		string.format("--    @Author:  %s", self:authorName()),
		"\n",
		string.format("--    @Date:    %s", os.date("%Y-%m-%d")),
		"\n",
		"--==================================================",
		"\n",
		"\n",
	}
end


-- 返回文档的模板配置
function FileInstructor:template()
	return {}
end
