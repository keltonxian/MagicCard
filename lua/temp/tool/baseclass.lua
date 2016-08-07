

--============================================================
--   @Brief:   继承体系的基类
--   @Author:  Huaxing Zheng
--   @Date:    2015-05-14-15:05:34
--============================================================

local obj_record_list = {}
setmetatable(obj_record_list, {__mode = "kv"})

function BaseClass( super )
	local class_type = {}

	class_type.super = super
	class_type.__delete = false

	class_type.New = function(...)
		local obj = {}
		obj.__class_type = class_type
		-- 注册查找方法
		setmetatable(obj, { __index = class_type })

		-- 析构函数
		obj.RemoveSelf = function( obj_self )
			--防止重复调用
			if(not obj_record_list[obj_self]) then
				return
			end
			local now_class = obj_self.__class_type
			while now_class do
				if now_class.__delete then
					now_class.__delete(obj_self)
				end
				now_class = now_class.super
			end
			obj_record_list[obj] = false
		end

		class_type.__init(obj, ...)
		obj_record_list[obj] = true
		return obj
	end

	if super then
		-- 父类方法查找
		setmetatable(class_type, { __index = super })
	end

	return class_type
end
