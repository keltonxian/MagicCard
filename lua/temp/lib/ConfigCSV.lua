--[[---------------------------------------------------------
The class provides helpers to CSV-based configuration data.
-----------------------------------------------------------]]

require("lib/extern")

--[[---------------------------------------------------------
Global Variables / Constants
-----------------------------------------------------------]]

--[[---------------------------------------------------------
Class Prototype Definition
-----------------------------------------------------------]]

local clsName = "ConfigCSV"

local prototype = {
    --[[---------------------------------------------------------
                        Member Variables
    -----------------------------------------------------------]]

    -- ignore header (the first line of the CSV) when searching data within it
    ignoreHeader = true,

    --[[---------------------------------------------------------
                        Member Methods
    -----------------------------------------------------------]]

    -- argument: key (string)
    -- return the first raw CSV line data (splited as a table per line) which matches the given key
    line = nil,

    -- argument: string
    -- return a table of raw CSV lines (splited as a table per line) which the keys contain the given string
    linesKeyContains = nil,

    -- argument: key (string)
    -- return the platform specified string value, will use the default value automatically
    string = nil,

    -- argument: string
    -- return a table of strings which the keys contain the given string
    stringKeyContains = nil,

    -- argument: key (string)
    -- return the platform specified number value, will use the default value automatically
    -- NOTE: if the raw number string is comma separated, a table of numbers returned
    number = nil,

    -- argument: string
    -- return a table of numbers which the keys contain the given string
    numberKeyContains = nil,

    -- argument: key (string)
    -- return the platform specified CCPoint value, will use the default value automatically
    point = nil,

    -- argument: string
    -- return a table of CCPoint which the keys contain the given string
    pointKeyContains = nil,

    -- argument: key (string)
    -- return the platform specified CCSize value, will use the default value automatically
    size = nil,

    -- argument: string
    -- return a table of CCSize which the keys contain the given string
    sizeKeyContains = nil,

    -- argument: key (string)
    -- return the platform specified (string, CCPoint) pair, will use the default value automatically
    stringCoord = nil,

    -- argument: string
    -- return a table of (string, CCPoint) pair which the keys contain the given string
    stringCoordKeyContains = nil,

    splitLines = nil,
    parseCSVLine = nil,
}

--[[---------------------------------------------------------
Class Constructor & Export to Package
-----------------------------------------------------------]]

local cls = class(clsName, function()
        local obj = {}

        -- MUST copy the prototype attributes to it
        for k, v in pairs(prototype) do
            obj[k] = v
        end

        return obj
    end
)

-- constructor definition
-- arguments: CSV filename (with path relative to "asssets" folder)
-- return the object of class
function cls.create(csvfile)
    local obj = cls.new()

    local timeStart = os.clock()

    local fileData = Utils:getFileData(csvfile)  -- user is responsible to delete the returned object after use
    obj._csvlines = obj:splitLines(fileData:getData())
    fileData:delete()

    cclog("total %d CSV lines in file %s", #obj._csvlines, csvfile)

    obj._csvtable = {}
    obj._csvkeys = {}  -- use first column as the key, header included

    -- trim spaces from both ends of the given string: http://snippets.luacode.org/snippets/trim_whitespace_from_string_76
    local trim = function(s) return s:find'^%s*$' and '' or s:match'^%s*(.*%S)' end

    for _, l in ipairs(obj._csvlines) do
        obj:parseCSVLine(l, nil,
            function(d)
                for i, t in ipairs(d) do d[i] = trim(t) end

                table.insert(obj._csvtable, d)
                table.insert(obj._csvkeys, d[1])
            end)
    end

    cclog("ConfigCSV: CSV parsed in %.2f seconds", os.clock() - timeStart)
    return obj
end

-- let the cls inherit all the attributes from prototype
setmetatable(cls, { __index = prototype })

-- export the cls to package
_G[clsName] = cls

--[[---------------------------------------------------------
Class Prototype Implementation
-----------------------------------------------------------]]

function prototype:line(key)
    local idx = nil

    for i, k in ipairs(self._csvkeys) do
        if self.ignoreHeader and 1 == i then
            -- ignore
        elseif k == key then
            idx = i
            break
        end
    end

    return idx and self._csvtable[idx] or {}
end

function prototype:linesKeyContains(s)
    local ret = {}

    for i, k in ipairs(self._csvkeys) do
        if self.ignoreHeader and 1 == i then
            -- ignore
        elseif string.find(k, s, 1, true) then
            table.insert(ret, self._csvtable[i])
        end
    end

    return ret
end

-- return the right value, will auto fall back to i4 when no matched one found
local function _autoString(i4, i5, iPad)
    local ret = __G__iOSValue(i4, i5, iPad)
    return (ret and "" ~= ret) and ret or i4
end

local function _autoNumber(i4, i5, iPad)
    local v = _autoString(i4, i5, iPad)
    if not v then return nil end

    v = prototype.parseCSVLine(nil, v, nil)

    if 1 == #v then
        return tonumber(v[1])
    else
        local ret = {}
        for _, i in ipairs(v) do table.insert(ret, tonumber(i)) end
        return ret
    end
end

local function _autoPoint(i4, i5, iPad)
    local v = _autoNumber(i4, i5, iPad)
    if type(v) == "table" and 2 == #v then
        return ccp(v[1], v[2])
    else
        return nil
    end
end

local function _autoSize(i4, i5, iPad)
    local v = _autoNumber(i4, i5, iPad)
    if type(v) == "table" and 2 == #v then
        return CCSizeMake(v[1], v[2])
    else
        return nil
    end
end

local function _singleValueFuncTemplate(valueFunc)
    return function(self, key)
                local t = self:line(key)
                return valueFunc(t[2], t[3], t[4])
            end
end

local function _multipleValuesFuncTemplate(valueFunc)
    return function(self, s)
                local ret = {}

                for _, t in ipairs(self:linesKeyContains(s)) do
                    table.insert(ret, valueFunc(t[2], t[3], t[4]))
                end

                return ret
            end
end

prototype.string = _singleValueFuncTemplate(_autoString)
prototype.stringKeyContains = _multipleValuesFuncTemplate(_autoString)

prototype.number = _singleValueFuncTemplate(_autoNumber)
prototype.numberKeyContains = _multipleValuesFuncTemplate(_autoNumber)

prototype.point = _singleValueFuncTemplate(_autoPoint)
prototype.pointKeyContains = _multipleValuesFuncTemplate(_autoPoint)

prototype.size = _singleValueFuncTemplate(_autoSize)
prototype.sizeKeyContains = _multipleValuesFuncTemplate(_autoSize)

function prototype:stringCoord(key)
    local t = self:line(key)
    return _autoString(t[2], t[3], t[4]), _autoPoint(t[5], t[6], t[7])
end

function prototype:stringCoordKeyContains(s)
    local ret = {}

    for _, t in ipairs(self:linesKeyContains(s)) do
        table.insert(ret, {_autoString(t[2], t[3], t[4]), _autoPoint(t[5], t[6], t[7])})
    end

    return ret
end

-- taken from http://lua-users.org/wiki/SplitJoin
-- split strings into lines, using CR/LF as the separator
function prototype:splitLines(str)
    local t = {}
    local function helper(line) table.insert(t, line); return "" end
    -- unify and simplify the CR/LF stuff: \r -> \n, \r\n -> \n\n
    str = str:gsub("\r", "\n")
    str = str:gsub("\n\n", "\n")
    helper((str:gsub("(.-)\n", helper)))
    return t
end

-- taken from http://lua-users.org/wiki/LuaCsv
-- parse a CSV line, returning a table which holds the splited content of the given line
function prototype:parseCSVLine(line, sep, callback)
    local res = {}
    local pos = 1
    sep = sep or ','
    while true do 
        local c = string.sub(line,pos,pos)
        if (c == "") then break end
        if (c == '"') then
            -- quoted value (ignore separator within)
            local txt = ""
            repeat
                local startp,endp = string.find(line,'^%b""',pos)
                txt = txt..string.sub(line,startp+1,endp-1)
                pos = endp + 1
                c = string.sub(line,pos,pos) 
                if (c == '"') then txt = txt..'"' end 
                -- check first char AFTER quoted string, if it is another
                -- quoted string without separator, then append it
                -- this is the way to "escape" the quote char in a quote. example:
                --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
            until (c ~= '"')
            table.insert(res,txt)
            assert(c == sep or c == "")
            pos = pos + 1
        else    
            -- no quotes used, just look for the first separator
            local startp,endp = string.find(line,sep,pos)
            if (startp) then 
                table.insert(res,string.sub(line,pos,startp-1))
                pos = endp + 1
            else
                -- no separator found -> use rest of string and terminate
                table.insert(res,string.sub(line,pos))
                break
            end 
        end
    end

    if callback then callback(res) end

    return res
end
