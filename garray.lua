-- "Generic array"

local ffi = require("ffi")

local string = require("string")
local format = string.format

local assert = assert
local error = error
local tonumber = tonumber
local tostring = tostring
local type = type

----------

local GA_BASE_CDECL = [[
struct {
    const int32_t ndims;  // number of dims (1: vector, 2: matrix, 3: NYI)
    const int32_t size[3];  // length of the 1st, 2nd and 3rd dim

    $ v[?];  // the actual, linearized array
}
]]


-- The table of exported functions and other API elements.
local garray = {}


-- [<garray type cdata number>] = <string of basetype>
local garray_basetypestr = {}

local garray_mt = {
    __add = function(self, other)
        assert(type(other) == "number", "RHS other than number NYI")
        local typ = ffi.typeof(self)
        local ar = typ(self:numel(), self.ndims, { self.size[0], self.size[1] })
        for i=0,self:numel()-1 do
            ar.v[i] = self.v[i] + other
        end
        return ar
    end,

    __sub = function(self, other)
        return self + -other
    end,

    __index = {
        numel = function(self)
            return self.size[0] * self.size[1]
        end,

        basetypestr = function(self)
            local typnum = tonumber(ffi.typeof(self))
            return garray_basetypestr[typnum]
        end,

        __tostring = function(self)
            return format("garray<%s>: size %d%s", self:basetypestr(),
                          self.size[0], self.ndims>1 and " x "..self.size[1] or "")
        end,

        _bcheck = function(self, dimi, i)
            if (i >= self.size[dimi]+0ULL) then
                error("Out-of-bounds access of dim "..dimi.." with number "..i, 2)
            end
        end,

        -- Calculate linear index.
        _i = function(self, i, j)
            -- "Column-major"
            return i + self.size[0]*j
        end,

        get = function(self, i, j)
            self:_bcheck(0, i)
            if (self.ndims > 1) then
                self:_bcheck(1, j)
                return self.v[self:_i(i, j)]
            else
                assert(j==nil, "Vectors must be indexed with only one index")
                return self.v[i]
            end
        end,
    },
}

function garray.newType(basetype)
    local typ = ffi.typeof(GA_BASE_CDECL, ffi.typeof(basetype))
    ffi.metatype(typ, garray_mt)

    local typnum = tonumber(typ)
    garray_basetypestr[typnum] = tostring(basetype)

    local constructor = function(sz1, sz2, vals)
        sz2 = sz2 or 1
        -- XXX: may have sz1*sz2 ~= 0 but (int)sz1*(int)sz2 == 0
        assert(sz1*sz2 > 0, "Empty arrays not supported")
        return typ(sz1*sz2, sz2~=0 and 2 or 1, { sz1, sz2 }, vals)
    end
    return constructor
end

-- garray.is(val)
-- Check whether <val> is a garray.
function garray.is(val)
    return (type(val)=="cdata" and garray_basetypestr[tonumber(ffi.typeof(val))]~=nil)
end



-- Done, return API table!
return garray
