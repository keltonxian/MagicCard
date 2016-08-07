module(..., package.seeall)

local ClassTable = nil

ClassTable = ClassTable or class("ClassTable", {
})

function ClassTable:ctor(...)
	print("ClassTable:ctor")
end

_G["ClassTable"] = ClassTable

