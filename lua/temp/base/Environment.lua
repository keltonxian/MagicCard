-- common functions / global constants etc
require "lib/extern"
require "config/config_game"
require "config/config_sound_effects"

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
local visibleCenterX, visibleCenterY = visibleOrigin.x + visibleSize.width / 2, visibleOrigin.y + visibleSize.height / 2

__G__visibleSize = visibleSize
__G__visibleOrigin = visibleOrigin
__G__visibleCenter = ccp(visibleCenterX, visibleCenterY)

-- the raw design resolution size
__G__designResolutionSize = nil
-- the actual screen size, in pixels
__G__frameSize = CCEGLView:sharedOpenGLView():getFrameSize()

-- the actual drawing resolution (in points) after properly scaled and offset; again, we assume the kResolutionFixedWidth is applied
-- we should always use the following variable to layout our assets on screen like
__G__canvasOrigin = nil
__G__canvasSize = nil
__G__canvasCenter = nil
__G__canvasScaleFactor = nil

-- see: http://discuss.cocos2d-x.org/t/how-to-get-current-device-orientation-in-cocos2d-x/9216
__G__isOrientationLandscape = CCDirector:sharedDirector():getOpenGLView():getFrameSize().width / CCDirector:sharedDirector():getOpenGLView():getFrameSize().height > 1

__G__isMacLuaPlayer = (CCApplication:sharedApplication():getTargetPlatform() == kTargetMacOS)

if __G__isMacLuaPlayer then
    if __G__isOrientationLandscape then
        __G__isIPAD = (__G__frameSize.width == 2048)
        __G__isIPHONE = (__G__frameSize.width == 960)
        __G__isIPHONE5 = ((__G__frameSize.width == 1136) and (__G__frameSize.height == 640))
    else
        __G__isIPAD = (__G__frameSize.width == 1536)
        __G__isIPHONE = (__G__frameSize.width == 640)
        __G__isIPHONE5 = ((__G__frameSize.width == 640) and (__G__frameSize.height == 1136))
    end
else
    __G__isIPAD = (CCApplication:sharedApplication():getTargetPlatform() == kTargetIpad)
    __G__isIPHONE = (CCApplication:sharedApplication():getTargetPlatform() == kTargetIphone)
    if __G__isOrientationLandscape then
        __G__isIPHONE5 = (__G__isIPHONE and __G__frameSize.width == 1136)
    else
        __G__isIPHONE5 = (__G__isIPHONE and __G__frameSize.height == 1136)
    end
end

-- return the iOS platform specified value among the 3 arguments
-- NOTE: all 3 arguments must not be false or nil values
__G__iOSValue = function(iphone4, iphone5, ipad)
    return (__G__isIPAD and ipad) or (__G__isIPHONE5 and iphone5) or iphone4
end

-- args: fp == folder_path, i4fn == iphone4_filename, i5fn == iphone5_filename, idfn == ipad_filename
__G__iOSValueP = function(fp, i4fn, i5fn, idfn)
	return __G__iOSValue((fp .. i4fn), (fp .. i5fn), (fp .. idfn))
end

-- a simplified version of the above method
__G__iOSValue2 = function(iphone, ipad)
    return __G__isIPAD and ipad or iphone
end

-- setup the design resolution here, then other global coordinate variables are calculated automatically
__G__setDesignResolutionSize = function(w, h)
    local designResolutionSize = CCSizeMake(w, h)
    __G__designResolutionSize = designResolutionSize
    __G__canvasOrigin = ccp(0, math.max(0, (visibleSize.height - designResolutionSize.height) / 2))
    __G__canvasSize = CCSizeMake(visibleSize.width, math.min(visibleSize.height, designResolutionSize.height))
    __G__canvasCenter = ccp(__G__canvasOrigin.x + __G__canvasSize.width / 2, __G__canvasOrigin.y + __G__canvasSize.height / 2)
    __G__canvasScaleFactor = math.max(__G__canvasSize.width / __G__frameSize.width, __G__canvasSize.height / __G__frameSize.height)
end




-- given a CCNode object and the basic image filename, return the full path of the saved image when success, else return nil
__G__saveImageFile = function(node, filename)
    -- http://www.cocos2d-x.org/wiki/How_to_Save_a_Screenshot
    local texture = CCRenderTexture:create(__G__canvasSize.width / __G__canvasScaleFactor, __G__canvasSize.height / __G__canvasScaleFactor)

    local oldScale = node:getScale()
    local oldX, oldY = node:getPosition()

    node:setScale(1 / __G__canvasScaleFactor)
    node:setPosition(__G__canvasSize.width / __G__canvasScaleFactor / 2, __G__canvasSize.height / __G__canvasScaleFactor / 2)

    texture:begin()
    node:visit()
    texture:endToLua()

    node:setScale(oldScale)
    node:setPosition(oldX, oldY)

    local ret = texture:saveToFile(filename, kCCImageFormatJPEG)
    return ret and (CCFileUtils:sharedFileUtils():getWritablePath() .. filename) or nil
end

-- sound related stuff
__G__isSoundMute = false

__G__soundMute = function(mute)
    if mute then
        AudioEngine.setMusicVolume(0.0)
        AudioEngine.setEffectsVolume(0.0)
    else
        AudioEngine.setMusicVolume(config_game:musicVolume())
        AudioEngine.setEffectsVolume(config_game:effectsVolume())
    end
    __G__isSoundMute = mute
end

-- create CCRect object from CCNode
__G__nodeRect = function(node)
    local s = node:getContentSize()
    local x, y = node:getPosition()
    return CCRectMake(x - s.width / 2, y - s.height / 2, s.width, s.height)
end

__G__nodeWorldRect = function(node)
    local s = node:getContentSize()

    local worldPosLB = node:convertToWorldSpace(ccp(0, 0))
    local worldPosRT = node:convertToWorldSpace(ccp(s.width, s.height))

    return CCRectMake(worldPosLB.x, worldPosLB.y, worldPosRT.x - worldPosLB.x, worldPosRT.y - worldPosLB.y)
end

-- App Store Id
__G__AppStoreID = ""

-- preload More Games data (JSON format)
print(' --- XXX TODELETE Environment MoreGamesData:refresh ')
--[[
require("lib/MoreGamesData")
__G__moreGamesData = MoreGamesData.new(Utils:moreGamesURL() .. "&format=json")
__G__moreGamesData:refresh()
]]--

-- IAP related stuff
__G__iapIDs = {}

-- localized IAP prices, has the same item order/index as __G__iapIDs
__G__iapPrices = {}

__G__iapIndex = function(id)
    for i, s in ipairs(__G__iapIDs) do
        if s == id then
            return i
        end
    end
    return -1
end

__G__iapUserDataKey = function(iapIndex)
    return "StoreUserDataForIAPPurchase" .. __G__iapIDs[iapIndex]
end

-- IAP Test
__G__iapTest = false

-- supports multiple index check: return true when one of the arguments is purchased
__G__checkIAP = function(...)
    -- IAP Test
    if __G__iapTest then
        return true
    end
    
    -- disable IAP for Android
    if __G__isAndroid then
        return true
    end

    -- IOS
    for _, v in pairs({...}) do
        if CCUserDefault:sharedUserDefault():getBoolForKey(__G__iapUserDataKey(v)) then
            return true
        end
    end
    return false
end

__G__setIAP = function(iapIndex)
    CCUserDefault:sharedUserDefault():setBoolForKey(__G__iapUserDataKey(iapIndex), true)
    CCUserDefault:sharedUserDefault():flush()
end

__G__isIAPPricesReady = function()
    return #__G__iapPrices == #__G__iapIDs 
end

__G__isGettingIAPPrices = false

__G__getIAPPrices = function(finishCallback)
    if __G__isGettingIAPPrices then
        print("__G__getIAPPrices: already running")
        return
    end

    if __G__isIAPPricesReady() then
        if finishCallback then
            finishCallback()
        end
        return
    end

    __G__isGettingIAPPrices = true
    print("__G__getIAPPrices: started")

    local array = CCArray:create()
    for i, v in ipairs(__G__iapIDs) do
        array:addObject(CCString:create(v))
    end

    Utils:sharedUtils():getIAPPrices(array,
        function(...)
            local rets = {...}
            -- rets: product id1, price1, product id2, price2, ....
            for i = 1, #rets, 2 do
                for j, jv in ipairs(__G__iapIDs) do
                    if rets[i] == jv then
                        __G__iapPrices[j] = rets[i + 1]
                        break
                    end
                end
            end
            if finishCallback then
                finishCallback()
            end

            __G__isGettingIAPPrices = false
            print("__G__getIAPPrices: done")
        end
    )
end


-- load chosen images and sound files into memory in order to improve the user experiences
__G__loadResources = function(images, sounds, musics)
    local nImages, nSounds, nMusics = 0, 0, 0
    local timeStart = os.clock()

    if type(images) == "table" then
        for _, i in pairs(images) do
            if CCTextureCache:sharedTextureCache():addImage(i) then
                nImages = nImages + 1
            end
        end
    end

    if type(sounds) == "table" then
        nSounds = #sounds
        for _, s in pairs(sounds) do
            AudioEngine.preloadEffect(s)
        end
    end

    if type(musics) == "table" then
        nMusics = #musics
        for _, m in pairs(musics) do
            AudioEngine.preloadMusic(m)
        end
    end

    print(string.format("loaded %d images, %d sounds and %d musics in %.2f seconds", nImages, nSounds, nMusics, os.clock() - timeStart))
end

--[[
  show a popped up layer over the top of the given parent layer
  argument:
    -- popupCreateFunc: a function returns the popup layer, it takes one argument as the "popup dismiss function"
    -- parent: the parent layer which the popup is attached to
    -- needHideBannerAd: true if we need to hide the banner ad when popup shown; if nil, the code will detect the current ad banner status
]]
__G__showPopup = function(popupCreateFunc, parent, needHideBannerAd)
    local function popupAnimate(node, finishCallback)
        local actionArray = CCArray:create()
        actionArray:addObject(CCScaleTo:create(0.1, 1.1))
        actionArray:addObject(CCScaleTo:create(0.1, 1.0))
        if finishCallback then
            actionArray:addObject(CCCallFunc:create(function() finishCallback(node) end))
        end
        node:runAction(CCSequence:create(actionArray))
    end

    local function dismissAnimate(node, finishCallback)
        -- no animation for the time being, just invoke the callback directly
        if finishCallback then
            finishCallback(node)
        end
    end

    if nil == needHideBannerAd then
        needHideBannerAd = AdsPopupManager:sharedManager():bannerIsShowing()
    end
    local _originBannerAdShowState = AdsPopupManager:sharedManager():bannerIsShowing()

    local popup
    popup = popupCreateFunc(
        function()
            dismissAnimate(popup, function()
                performWithDelay(popup,
                    function()
                        parent:removeFromTouchResponders(popup)
                        parent:removeChild(popup, true)
                        if _originBannerAdShowState then
                            AdsPopupManager:sharedManager():showBannerAd()
                        end
                    end, 0.1)
                end)
            end)

    popup:setPosition(__G__canvasSize.width / 2, __G__canvasSize.height / 2)
    popup:setTouchPriority(1000000)

    parent:addChild(popup, 1000000)
    parent:addToTouchResponders(popup)

    if needHideBannerAd then
        AdsPopupManager:sharedManager():hideBannerAd()
    end

    popupAnimate(popup)
end

-- indicating if application (or its main activity in Android) is in background
__G__isBackground = false

__G__isHomeInit = true

----------------- Android patch ----------------------

-- Android or not
__G__isAndroid = CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid

if __G__isAndroid then
    __G__iOSValue = function(iphone4, iphone5, ipad)
        return iphone5
    end

    __G__iOSValue2 = function(iphone, ipad)
        return iphone
    end
end

-- android: v1, v2, v3
-- iOS: v4, v5, v6
__G__AndroidOriOSValue = function(v1, v2, v3, v4, v5, v6)
	return __G__isAndroid and __G__iOSValue(v1, v2, v3) or __G__iOSValue(v1, v2, v3)
end


------- 20150521 modified by huaxing
local resolution = nil
if __G__isOrientationLandscape then
    resolution = __G__iOSValue({960, 640}, {1136, 640}, {1024, 768})
else
    resolution = __G__iOSValue({640, 960}, {640, 1136}, {768, 1024})
end
__G__setDesignResolutionSize(unpack(resolution))


-- 设置查找路径
local usePAK = Utils:isFileExist("assets.pak")
-- disable PAK support for Android for the time being
--[[
if __G__isAndroid then
    usePAK = false
end
]]--

local resourcePath = nil

if usePAK then
    resourcePath = __G__iOSValue2("image", "image")
    CCFileUtils:sharedFileUtils():addSearchPath(resourcePath)  -- for resolution dependant assets such as images
else
    if __G__isAndroid then
        resourcePath = __G__iOSValue2("assets/assets/image", "assets/assets/image")
    else
        resourcePath = __G__iOSValue2("assets/image", "assets/image")
    end
    CCFileUtils:sharedFileUtils():addSearchPath(resourcePath)  -- for resolution dependant assets such as images
    --[[ no need to do the following, "assets" has been added in AppDelegate.cpp
    CCFileUtils:sharedFileUtils():addSearchPath("assets")  -- for common assets such as sound files
    ]]
end

-- 打印信息
if true then
    print("")
    print("------------------------------")
    print(string.format("frame size: %.2f, %.2f", __G__frameSize.width, __G__frameSize.height))
    print(string.format("visible size: %.2f, %.2f", __G__visibleSize.width, __G__visibleSize.height))
    print(string.format("canvas origin: %.2f, %.2f", __G__canvasOrigin.x, __G__canvasOrigin.y))
    print(string.format("canvas size: %.2f, %.2f", __G__canvasSize.width, __G__canvasSize.height))
    print(string.format("canvas scale factor: %.2f", __G__canvasScaleFactor))
    print("------------------------------")
    if __G__isAndroid then
        print(string.format("Android device, using %s size graphics", __G__iOSValue("iphone4", "iphone5", "ipad")))
    else
        print(string.format("iOS device: %s", __G__iOSValue("iphone4", "iphone5", "ipad")))
    end
    print(string.format("is orientation landscape: %s", tostring(__G__isOrientationLandscape)))
    print("")
end


local cfg = nil
-- Android doesnt not use the CSV config, it configs data in manifest XML
if not __G__isAndroid then
    cfg = config_game:configCSV()

    -- setup appstore id and IAP product id
    __G__AppStoreID = cfg:string("appstore id")

    for _, id in ipairs(cfg:stringKeyContains("iap")) do
        table.insert(__G__iapIDs, id)
    end
    print("---------------------iap counts ---------------------", #__G__iapIDs)
end

__G__ADLoadingCall = nil
__G__ADLoadingCallFunc = nil
__G__SceneLoadingRunning = false  

------video ad  handle-----
__G__recallFunction = nil
-- require("config_video")
__G__isShowRewardAD = nil
__G__fromShowFail = nil
__G__failRecallFunc = nil

__G__videoHandler = function(flag)
    if flag and __G__recallFunction then
        ------
        __G__recallFunction()
        -- config_video.unlockAndRecord()
    end
end

__G__popBG = nil 

__G__removeAds = function()
    if __G__checkIAP(1) and not __G__isAndroid then
        AdsPopupManager:sharedManager():hideBannerAd()
        AdsPopupManager = {
            sharedManager = function() return {
                showBannerAd = function() end,
                hideBannerAd = function() end,
                showInterstitialCrossPromote = function() end,
                showInterstitial = function() end,
                bannerIsShowing = function() return false end,
                -- showNewsBlast = function() return newsblast end,
            } end,
        }

    end
end

local recordItems = {
    MAKEUP_TOOLS_EYEBROW = "",
    MAKEUP_TOOLS_EYELINE = "",
    MAKEUP_TOOLS_EYELASH = "",
    MAKEUP_TOOLS_BLUSH = "",
    MAKEUP_HAIR = "",
    MAKEUP_PUPIL = "",
    MAKEUP_EYESHADOW = "",
    MAKEUP_LISTICK1 = "",
    MAKEUP_LISTICK2 = "",

    MAKEUP_AND_DRESS_HEADWEAR = "", --DRESS_ITEM_F 
    MAKEUP_AND_DRESS_EARRING = "", --DRESS_ITEM_G 

    DRESS_ITEM_A = "",
    DRESS_ITEM_B = "",
    DRESS_ITEM_C = "",
    DRESS_ITEM_D = "",
    DRESS_ITEM_E = "",
    DRESS_ITEM_F = "",
    DRESS_ITEM_G = "",
    DRESS_ITEM_H = "",
    DRESS_ITEM_I = "",
    DRESS_ITEM_J = "",

    SEC_DRESS_ITEM_A = "",
    SEC_DRESS_ITEM_B = "",
    SEC_DRESS_ITEM_C = "",
    SEC_DRESS_ITEM_D = "",
    SEC_DRESS_ITEM_E = "",
    SEC_DRESS_ITEM_F = "",
    SEC_DRESS_ITEM_G = "",
    SEC_DRESS_ITEM_H = "",
    SEC_DRESS_ITEM_I = "",
    SEC_DRESS_ITEM_J = "",
}

__G__RecordItems = {}
for k,v in pairs(recordItems) do
    __G__RecordItems[k]=k
end

local NOVALUE = -10010
-- 记录通过视频解锁的id值
__G__recordItemUnlock = function (key, value)
    for k,v in pairs(recordItems) do
        if k == key then
            local valueString = (NOVALUE == value) and "" or v.."_"..string.format("%02d", value)
            recordItems[k] = valueString

            CCUserDefault:sharedUserDefault():setStringForKey(key, valueString)
            CCUserDefault:sharedUserDefault():flush()
            print (key ,valueString, "------------------------flush")
    
            break
        end
    end
end

__G__initRecordItemUnlockValue = function ()
    local isNeedClear = false

    local oldYear = CCUserDefault:sharedUserDefault():getStringForKey("RECORD_TIME_YEAR")
    local oldyDay = CCUserDefault:sharedUserDefault():getStringForKey("RECORD_TIME_Y_DAY")  ---- 一年中的第几天

    local year = os.date("%Y")
    local yDay = os.date("%j")

    if oldyDay ~= "" and oldYear ~= "" then
        if math.abs(tonumber(year) - tonumber(oldYear)) > 0 then
            isNeedClear = true
        elseif math.abs(tonumber(yDay) - tonumber(oldyDay)) > 0 then
            isNeedClear = true
        end
    end

    CCUserDefault:sharedUserDefault():setStringForKey("RECORD_TIME_YEAR", year)
    CCUserDefault:sharedUserDefault():setStringForKey("RECORD_TIME_Y_DAY", yDay)  ---- 一年中的第几天

    for k,v in pairs(recordItems) do
        if isNeedClear then
            __G__recordItemUnlock(k, NOVALUE)
        else
            local valueString = CCUserDefault:sharedUserDefault():getStringForKey(k)
            recordItems[k] = valueString
        end
    end
end

-- keyStr 关键字
__G__checkItemLock = function (key, value)

    if __G__isAndroid then

    else -- 检查iap是否解锁
        if __G__checkIAP(1) then
            return false
        end
    end
    
    local valueString = ""
    for k,v in pairs(recordItems) do
        if key == k then
            valueString = v
            break
        end
    end

    local ret = true

    for v in string.gmatch(valueString, "%d%d") do
        local num = tonumber(v)
        if value == num then
            ret = false
            break
        end
    end

    print (key, ret, "----------------------------------")

    return ret
end
