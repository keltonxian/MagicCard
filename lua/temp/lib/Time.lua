
--==================================================
--    @Brief:   时间类
--    @Author:  Rios
--    @Date:    2015-07-17
--==================================================

Time = Time or class("Time")


function Time:ctor()
end

----------------------------------------------------
-- 得到当前日期 YYYYMMDDhhmmss
----------------------------------------------------
function Time:getDateYYYYMMDDhhmmss()
	local aDateStr = string.format("%s",os.date("%Y%m%d%H%M%S"))
	return aDateStr
end

----------------------------------------------------
-- 计算两日期的间隔（秒）
----------------------------------------------------
function Time:getIntervalFromDate(dateStr1,dateStr2)
    local Y1 = string.sub(dateStr1,1,4)
    local M1 = string.sub(dateStr1,5,6) 
    local D1 = string.sub(dateStr1,7,8)
    local H1 = string.sub(dateStr1,9,10)
    local MI1 = string.sub(dateStr1,11,12)
    local S1 = string.sub(dateStr1,13,14)

    local Y2 = string.sub(dateStr2,1,4)
    local M2 = string.sub(dateStr2,5,6)
    local D2 = string.sub(dateStr2,7,8)
    local H2 = string.sub(dateStr2,9,10)
    local MI2 = string.sub(dateStr2,11,12)
    local S2 = string.sub(dateStr2,13,14)

    local dt1 = os.time{year=Y1, month=M1, day=D1, hour=H1, min=MI1, sec=S1}
    local dt2 = os.time{year=Y2, month=M2, day=D2, hour=H2, min=MI2, sec=S2}

    return dt2-dt1
end

----------------------------------------------------
-- Demo
----------------------------------------------------
function Time:test()
	print("Now = ",Time:getDateYYYYMMDDhhmmss())
	print("Interval = ",Time:getIntervalFromDate(Time:getDateYYYYMMDDhhmmss(),"20150716152146"))
end

