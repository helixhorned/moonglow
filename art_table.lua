
local ffi = require("ffi")

local math = require("math")

local assert = assert
local pairs = pairs
local type = type

----------

local api = {}

function api.validate(artTab)
    assert(type(artTab) == "table")

    local minTileNum = math.huge
    local maxTileNum = -math.huge

    for tileNum, tileTab in pairs(artTab) do
        assert(type(tileNum) == "number", "argument #2 must contain only number keys")
        assert(type(tileTab) == "table", "argument #2 must contain only table values")

        minTileNum = math.min(minTileNum, tileNum)
        maxTileNum = math.max(maxTileNum, tileNum)

        local sx, sy = tileTab.w, tileTab.h
        local data = tileTab.data

        assert(type(sx) == "number" and type(sy) == "number",
               "tile tables must contain keys 'w' and 'h'")
        assert(type(data) == "cdata", "tile tables must contain key 'data' of cdata type")
        assert(sx > 0 and sy > 0, "tile width/height must be strictly positive")
        assert(sx * sy == ffi.sizeof(data), "inconsistent tile width/height and 'data'")
    end

    return minTileNum, maxTileNum
end

-- Done!
return api
