-- =============== FRAME START ===============
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
-- =============== FRAME END   ===============

-- =============== STATE START ===============
__G__isBackground = false
-- =============== STATE END   ===============

-- =============== CONSTANT START ===============
TTF_DEFAULT    = "supercell-magic_0.ttf"

ANCHOR_NULL        = 99 -- the value is useless, just define for not scale
ANCHOR_LEFT        = 0
ANCHOR_RIGHT       = 1
ANCHOR_UP          = 1
ANCHOR_DOWN        = 0
ANCHOR_CENTER      = 0.5

ANCHOR_LEFT_UP		= cc.p(ANCHOR_LEFT, ANCHOR_UP)
ANCHOR_LEFT_DOWN	= cc.p(ANCHOR_LEFT, ANCHOR_DOWN)
ANCHOR_LEFT_CENTER	= cc.p(ANCHOR_LEFT, ANCHOR_CENTER)
ANCHOR_RIGHT_UP  	= cc.p(ANCHOR_RIGHT, ANCHOR_UP)
ANCHOR_RIGHT_DOWN	= cc.p(ANCHOR_RIGHT, ANCHOR_DOWN)
ANCHOR_RIGHT_CENTER	= cc.p(ANCHOR_RIGHT, ANCHOR_CENTER)
ANCHOR_CENTER_CENTER= cc.p(ANCHOR_CENTER, ANCHOR_CENTER)
ANCHOR_CENTER_UP    = cc.p(ANCHOR_CENTER, ANCHOR_UP)
ANCHOR_CENTER_DOWN  = cc.p(ANCHOR_CENTER, ANCHOR_DOWN)


C4B_WHITE = cc.c4b(255, 255, 255, 255)
C4B_BLACK = cc.c4b(0, 0, 0, 255)
-- =============== CONSTANT END   ===============
