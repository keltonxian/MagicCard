
--==================================================
--    @Brief:   laout数据类
--    @Author:  Rios
--    @Date:    2015-09-06
--==================================================

LayoutData = LayoutData or class("LayoutData")


function LayoutData:ctor(data_file, baseTag)
	-- 读取JSON
	local fileData = Utils:getFileData(data_file)
	local aJsonString = fileData:getData()
	local json = require("lib/json")
    local inspect = require("lib/inspect")
	local jsonObj = json.decode(aJsonString)

    self.datas = jsonObj

    self.items = {}
    self.zOrders = {}
    self.positions = {}
    self.sizes = {}

	for k,v in pairs(self.datas) do
		self.zOrders[k] = v.z
		self.positions[k] = ccp(v.x, v.y)
		self.sizes[k] = CCSize(v.width, v.height)
    end

    -- tags
    require("lib/Number")
    self.tags = Number:generateTagsFromZOrders(baseTag or 1000, self.zOrders)

    for k,v in pairs(self.datas) do
    	self.items[k] = {}
		self.items[k].x = v.x
		self.items[k].y = v.y
		self.items[k].width = v.width
		self.items[k].height = v.height
		self.items[k].z = v.z
		self.items[k].tag = self.tags[k]
    end
end


----------------------------------------------------
-- Demo
----------------------------------------------------
function LayoutData:test()
end

