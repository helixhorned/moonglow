
local ffi = require("ffi")
local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local class = require("class").class
local garray = require("garray")

local error_util = require("error_util")
local check = error_util.check
local checktype = error_util.checktype

local assert = assert

----------

-- TODO: factor out into convenience file?

local ga_double = garray.newType("double")
local ga_int = garray.newType("int")
local ga_uint8 = garray.newType("uint8_t")
local ga_uint32 = garray.newType("uint32_t")

local GArrayTypes = {
    uint8_t = ga_uint8,
    uint32_t = ga_uint32,
}

-- Create a 2xN 'int' garray matrix from <tab>.
local function ivec2(tab)
    local numverts = #tab/2
    return ga_int(2, numverts, tab)
end

-- Create a 2xN 'double' garray matrix from <tab>.
local function dvec2(tab)
    local numverts = #tab/2
    return ga_double(2, numverts, tab)
end

----------

local twInstance = nil

local Callbacks = {
    Display = function()
        -- NOTE: misnomer, just for consistency
        local self = twInstance

        local w, h = self.ga:dims()
        local rect = ivec2{0,0; w,h}

        local v = rect.v
        -- Rect points:
        local rpts = ivec2{v[0],v[1]; v[2],v[1]; v[2],v[3]; v[0],v[3]}

        glow.draw(GL.QUADS, rpts, {colors={1,1,1}, tex=self.tex,
                                   texcoords = dvec2{0,0; 1,0; 1,1; 0,1}})

        assert(gl.glGetError() == GL.NO_ERROR)
        glut.glutSwapBuffers()
    end,
}

local TEXTURE_HACK = true

local TextureWindow = class
{
    function(width, height, pixelTypeStr)
        checktype(width, 1, "number", 2)
        checktype(height, 2, "number", 2)
        checktype(pixelTypeStr, 3, "string", 2)

        local gaType = GArrayTypes[pixelTypeStr]
        check(gaType ~= nil, "unsupported pixel type", 2)

        local windowArgs = {
            name = "TextureWindow",
            extent = {width, height}
        }

        glow.window(windowArgs, Callbacks)
        glow.setup2d(width, height)

        local ga = gaType(width, height)

        return {
            ga = ga,
            tex = glow.texture(ga, nil, nil, TEXTURE_HACK)
        }
    end,

    update = function(self, texture)
        self.ga:assignFromArray(texture)
        glow.texture(self.ga, {}, self.tex, TEXTURE_HACK)
        glow.redisplay()
    end,
}

----------

local api = {}

function api.create(...)
    check(twInstance == nil, "only a single window supported", 2)
    twInstance = TextureWindow(...)
    return twInstance
end

function api.step()
    glut.glutMainLoopEvent()
end

-- Done!
return api
