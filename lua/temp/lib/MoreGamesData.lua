-- MoreGamesData: a Lua class encapsulating More Games data logic

local function savedFileFullPath(filename)
    return CCFileUtils:sharedFileUtils():getWritablePath() .. filename
end

-- the callback is invoked with the 3 arguments
-- (bool) success: download success or not
-- (bool) useCache: use cache or not, true means no download required, use the cached one directly
-- (string) fileFullPath: the full path of the downloaded file
local function download(url, callback)
    -- DO NOT use the pure Lua md5, it's extremely slow even make the asnyc call suck
    --[[
    local md5 = require("md5")
    local filename = md5.sumhexa(url)
    ]]

	-- filename's length should < 256
	--[[
	-- old method: use url as the filename
	local MAX_LENGTH = 255
	-- e.g: http://is5.mzstatic.com/image/thumb/Purple/v4/9e/68/22/9e682253-3001-713e-a1ab-eac9921efc61/source/100x100bb.jpg
	--local t = string.match(url, ".*thumb/(.*)/source*")
	local t = string.match(url, ".*://(.*)%..*")
	local ftype = string.match(url, ".+%.(%w+)$")
	t = string.gsub(t, "[^%a%d]", "_")
	local filename = string.format("%s.%s", (t or "temp"), (ftype or "png"))
	-- e.g: http://services.mystylinglounge.com/static/upload/002_gz.png 
	--local filename = string.match(url, ".*/(.*)")
	if string.len(filename) > MAX_LENGTH then
		local len = string.len(filename)
		filename = string.sub(filename, len - MAX_LENGTH + 1, len)
	end
	]]--
	local filename = MD5Checksum:GetMD5OfString(url) or "_unknown_"
    local fullpath = savedFileFullPath(filename)

    if Utils:isFileExist(fullpath) then
        cclog("file cache for URL %s is found, no download required", url)
        callback(true, true, fullpath)
        return
    end

    cclog("downloading %s as ... %s", url, filename)

    local util = Utils:new()

    util:httpGet(url,
        function(code, header, response)
            -- since we are using raw so the response is the string of the full path to the downloaded file
            if response ~= fullpath then
                cclog("warn: the full path of downloaded file (%s) doesn't match the one we calculated before.", response)
            end

            callback(code == 200, false, fullpath)
            util:release()
        end, true, filename)
end

local function unicodeFix(s)
    -- convert \uXXXXX unicode escape to legal Lua string form
    -- see: http://codea.io/talk/discussion/1479/emoji-experiments-with-unicode-emoji-print-and-text/p1

    -- Unicode code point to UTF-8 format string of bytes
    --
    -- Bit Last point Byte 1   Byte 2   Byte 3   Byte 4   Byte 5   Byte 6
    -- 7   U+007F     0xxxxxxx
    -- 11  U+07FF     110xxxxx 10xxxxxx
    -- 16  U+FFFF     1110xxxx 10xxxxxx 10xxxxxx
    -- 21  U+1FFFFF   11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    -- 26  U+3FFFFFF  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
    -- 31  U+7FFFFFFF 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
    --
    -- However, largest integer in Codea's Lua is 0x7FFFFF (23 bit)
    -- With acknowledgement also to Andrew Stacey's UTF-8 library
    function unicode2UTF8(u)
        u = math.max(0, math.floor(u)) -- A positive integer
        local UTF8
        if u < 0x80 then          -- less than  8 bits
            UTF8 = string.char(u)
        elseif u < 0x800 then     -- less than 12 bits
            local b2 = u % 0x40 + 0x80
            local b1 = math.floor(u/0x40) + 0xC0
            UTF8 = string.char(b1, b2)
        elseif u < 0x10000 then   -- less than 16 bits
            local b3 = u % 0x40 + 0x80
            local b2 = math.floor(u/0x40) % 0x40 + 0x80
            local b1 = math.floor(u/0x1000) + 0xE0
            UTF8 = string.char(b1, b2, b3)
        elseif u < 0x200000 then  -- less than 22 bits
            local b4 = u % 0x40 + 0x80
            local b3 = math.floor(u/0x40) % 0x40 + 0x80
            local b2 = math.floor(u/0x1000) % 0x40 + 0x80
            local b1 = math.floor(u/0x40000) + 0xF0
            UTF8 = string.char(b1, b2, b3, b4)
        elseif u < 0x800000 then -- less than 24 bits
            local b5 = u % 0x40 + 0x80
            local b4 = math.floor(u/0x40) % 0x40 + 0x80
            local b3 = math.floor(u/0x1000) % 0x40 + 0x80
            local b2 = math.floor(u/0x40000) % 0x40 + 0x80
            local b1 = math.floor(u/0x1000000) + 0xF8
            UTF8 = string.char(b1, b2, b3, b4, b5)
        else
            print("Error: Code point too large for Codea's Lua.")
        end
        return UTF8
    end

    local r, _ = string.gsub(s, "\\u(%d+)", function(s) return unicode2UTF8(tonumber(s, 16)) end)
    return r
end

local prototype = {}

-- return an instance (Lua table) of prototype
-- argument: the url to fetch the More Games json data
function prototype.new(url)
    local d = {}
    setmetatable(d, { __index = prototype })

    d.url = url
    d._isReady = false
    d._hasError = false
    d._isRefreshing = false

    return d
end

-- return true if all data are fetchted and parsed, ready for UI rendering
function prototype:isReady()
    return self._isReady
end

-- return true if any error occurs in data download
function prototype:hasError()
    return self._hasError
end

-- purge the downloaded data and restart the data download
function prototype:refresh()
    if self._isRefreshing then
        cclog("More Games is already fetching data.")
        return
    end

    self._isRefreshing = true
    self._isReady = false
    self._hasError = false
    self.jsonTable = nil

    local util = Utils:new()

    util:httpGet(self.url,
        function(code, header, response)
            cclog("More Games HTTP code: %d", code)
            cclog("More Games HTTP response header:\n%s", header)

            if code ~= 200 then
                cclog("non-200 HTTP code error.")
                self._hasError = true
            elseif nil == string.find(header, "application/json", 1, true) then
                cclog("not application/json Content-Type error.")
                self._hasError = true
            else
                local json = require("lib/json")
                self.jsonTable = json.decode(unicodeFix(response))

                if type(self.jsonTable) ~= "table" then
                    cclog("JSON data parse error.")
                    self.jsonTable = nil
                    self._hasError = true
                end
            end

            util:release()

            if nil == self.jsonTable then
                self._isRefreshing = false
                return
            end

            -- download icon files in sequential order
            local currApp = nil  -- the current processing app datatable
            local downloadNext = nil -- for recursive call

            downloadNext = function(url, nextFunc)
                if not url then
                    self._isReady = (not self._hasError)

                    -- inspecting the received JSON for debug
                    if self._isReady then
                        local inspect = require("lib/inspect")
                        cclog("More Games is ready, JSON inspect:\n%s", inspect(self.jsonTable))
                    else
                        cclog("More Games data done with error, may initiate a refresh call to resolve the problem.")
                    end

                    self._isRefreshing = false
                    return
                end

                download(url,
                    function(success, useCache, fullpath)
                        if success then
                            cclog("URL %s saved to file %s", url, fullpath)
                            currApp.icon_file = fullpath  -- inject the downloaded icon file full path
                        else
                            self._hasError = true
                            cclog("download failed for URL %s", url)
                        end

                        return downloadNext(nextFunc(), nextFunc)  -- recursive "tail call" here
                    end)
            end

			-- for test
			--[[
			self.jsonTable.apps = {}
			table.insert(self.jsonTable.apps, {
			    icon = "http://is5.mzstatic.com/image/thumb/Purple/v4/9e/68/22/9e682253-3001-713e-a1ab-eac9921efc61/source/100x100bb.jpg"
			})
			]]--
			--

            local nextURLIdx = 0
            local function nextURL()
                nextURLIdx = nextURLIdx + 1
                local app = self.jsonTable.apps[nextURLIdx]
                currApp = app
                return app and app.icon or nil
            end

            downloadNext(nextURL(), nextURL)
        end)

    cclog("HTTP request to %s sent, waiting for response...", self.url)
end

-- return a Lua table representing the JSON data in following format
--[[
{
  apps = {
    {
      bundle_id = "lipssalon",
      click_callback = "http://services.mystylinglounge.com/ping/conv/7/29/-/ffffffffffffffffffffffffffffffffffffffff/?ch=1",
      icon = "http://services.mystylinglounge.com/static/upload/AppIcon57x572x_26.png",
      icon_file = "/var/mobile/Applications/3044B48B-89A8-4FA9-8938-C4331BD48044/Documents/f24adb8f3f0120f320f95c6f53974b02",
      name = "Lips Salon",
      url = "http://itunes.apple.com/app/id893536429?mt=8&ct=newsblast",
      description = "blahblahblahblah....",
    },
    ...
  }
}
]]
function prototype:getData()
    return self.jsonTable
end

_G["MoreGamesData"] = prototype
