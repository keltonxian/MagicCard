
--[==[============================================================
    @Brief:   事件配置
    @Author:  Zheng Huaxing
    @Date:    2015-06-05-17:06:01
============================================================--]==]

Event = Event or {}
Event.M_COUNT = 0
function Event:addEvent( event_name )
	Event.M_COUNT = Event.M_COUNT+1
	self[event_name] = Event.M_COUNT
end


Event:addEvent( "AdEvent" )