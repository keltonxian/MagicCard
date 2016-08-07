local director = cc.Director:getInstance()
local visibleOrigin = director:getVisibleOrigin()
local visibleSize = director:getVisibleSize()
local visibleCenterX = visibleOrigin.x + visibleSize.width / 2
local visibleCenterY = visibleOrigin.y + visibleSize.height / 2

__G__vSize = visibleSize
__G__vOrigin = visibleOrigin
__G__vCenter = ccp(visibleCenterX, visibleCenterY)

local glview = director:getOpenGLView()
local frameSize = glview:getFrameSize()

__G__frameSize = frameSize

__G__isBackground = false
