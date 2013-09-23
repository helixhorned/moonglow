-- "Generic array"

local ffi = require("ffi")


module(...)


local GA_BASE_CDECL = [[
struct {
    const int32_t ndims;  // number of dims (1: vector, 2: matrix, 3: NYI)
    const int32_t size[3];  // length of the 1st, 2nd and 3rd dim

    $ v[?];  // the actual, linearized array
}
]]

function newType(basetype)
    local typ = ffi.typeof(GA_BASE_CDECL, ffi.typeof(basetype))
end
