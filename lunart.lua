#!/usr/bin/env luajit

local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local B = require("build")

local garray = require("garray")
local ga_double = garray.newType("double")
local ga_int = garray.newType("int")
local ga_uint8 = garray.newType("uint8_t")
local ga_uint32 = garray.newType("uint32_t")

local assert = assert
local pairs = pairs
local setmetatable = setmetatable

local math = require("math")
local cos, sin = math.cos, math.sin
local max = math.max

local bit = require("bit")
local ffi = require("ffi")
local io = require("io")
local os = require("os")
local table = require("table")

local string = require("string")
local format = string.format

local arg = arg


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


-- Application data, per-window. [windowid] = <AppData object>
local g_data = {}

-- Get AppData of current window.
local function getdata()
    return assert(g_data[glut.glutGetWindow()])
end


--== window reshape callback ==--
local function reshape_cb(w, h)
    local d = getdata()

    glow.setup2d(w, h)
    d.w = w
    d.h = h
end

-- Is point (x, y) in the rect <r> (2x2 garray)?
local function ptinrect(x, y, r)
    local nr, nc = r:dims()
    return nr==2 and nc==2 and
        r.v[0] <= x and r.v[1] <= y and
        x <= r.v[2] and y <= r.v[3]
end

local function drawTile(aw, ltile, rect, mx, my)
    local v = rect.v
    -- Rect points:
    local rpts = ivec2{v[0],v[1]; v[2],v[1]; v[2],v[3]; v[0],v[3]}
    -- Rect width and height:
    local rw, rh = v[2]-v[0], v[3]-v[1]

    local tex = aw:getTex(ltile)

    if (tex ~= nil) then
        local pw, ph = aw.artf:dims(ltile)

        local tpts
        if (pw > ph) then
            local f = 1-ph/pw
            tpts = rpts + ivec2{0,0; 0,0; 0,-f*rh; 0,-f*rh}
        elseif (pw < ph) then
            local f = 1-pw/ph
            tpts = rpts + ivec2{0,0; -f*rw,0; -f*rw,0; 0,0}
        else
            tpts = rpts
        end

        glow.draw(GL.QUADS, tpts, {colors={1,1,1}, tex=tex,
                                   texcoords = dvec2{0,0; 0,1; 1,1; 1,0}})
    end

    glow.draw(GL.LINE_LOOP, rpts, {colors={0.1, 0.1, 0.1}})

    if (tex ~= nil) then
        if (ptinrect(mx, my, rect)) then
            glow.draw(GL.LINE_LOOP, rpts, {colors={1,1,0.4}})
        end
    end
end

-- Compare two ArtFileWrapper objects.
local function compare_aw(aw1, aw2)
    local af1, af2 = aw1.artf, aw2.artf

    if (af1.tbeg < af2.tbeg) then
        return true
    end

    if (type(af1.filename)=="string" and type(af2.filename)=="string"
            and af1.filename < af2.filename) then
        return true
    end
end

--== display callback ==--
local function display_cb()
    local d = getdata()

    glow.clear(0.9)

    local awraps = {}
    for _,aw in pairs(d.artwraps) do
        awraps[#awraps+1] = aw
    end
    table.sort(awraps, compare_aw)

    local w, h = d.w, d.h
    local rect = ivec2{0,0; 80,80} + 16

    for awi = 1,#awraps do
        local aw = awraps[awi]

        drawTile(aw, 0, rect, d.mx, d.my)

        rect:addBroadcast(ivec2{0,100})
        if (rect.v[3] > h-20) then
            break
        end
    end

--    local ti = d.tileinf
--    glow.text({20, h/3+20}, 14, format("Tile %d: %d x %d", ti.num, ti.w, ti.h))

    assert(gl.glGetError() == GL.NO_ERROR)

    glut.glutSwapBuffers()
end

--== mouse motion callback ==--
local function motion_both_cb(isdown, x, y)
    getdata():setMouse(x, y, isdown)
    glut.glutPostRedisplay()
end

local g_callbacks = {
    Display=display_cb, MotionBoth=motion_both_cb,
    Reshape=reshape_cb,
}


-- Terminate the LuaJIT process with a formatted error message.
local function doexit(fmt, ...)
    local msg = string.format(fmt, ...)
    io.stderr:write(msg)
    os.exit(1)
end

-- <basepal>: uint8_t [768] cdata
-- Returns: uint32_t [768] cdata (RGBA)
local function expand_basepal(basepal)
    local bpu = ga_uint32(768)
    for i=0,768-1 do
        local color = basepal[3*i+0] + 256*basepal[3*i+1] + 65536*basepal[3*i+2]
        if (ffi.abi("be")) then
            color = bit.bswap(color)
        end
        bpu.v[i] = color
    end
    return bpu
end

-- <palfn>: file name of PALETTE.DAT
local function getBasepal(palfn)
    local palette, errmsg = B.read_basepal(palfn)
    if (palette == nil) then
        doexit("Failed reading %s: %s", palfn, errmsg)
    end
    return expand_basepal(palette)
end

-- <img>: uint8_t [<pw>*<ph>] cdata
-- Returns: uint32_t [<pw>*<ph>] cdata
local function createTexture(img, pw, ph, palette)
    local teximg = ga_uint32(pw, ph)
    for i=0,pw*ph-1 do
        teximg.v[i] = palette.v[img[i]]
    end
    return teximg
end

--== ArtFileWrapper ==--

local ArtFileWrapper_mt = {
    __index = {
        -- Upload GL texture for local tile number <ltile> and get GL texture name
        getTex = function(self, ltile)
            if (self.tex[ltile]) then
                return self.tex[ltile]
            end

            local af = self.artf
            local img = af:getpic(ltile)
            if (img == nil) then
                return nil
            end

            local pw, ph = af:dims(ltile)
            local teximg = createTexture(img, pw, ph, self.basepal)
            self.tex[ltile] = glow.texture(teximg, {filter=GL.NEAREST})

            return self.tex[ltile]
        end,
    },

    __metatable = true,
}

-- A wrapper around the build.artfile class, containing app-time state.
-- <artfn>: The file name of the ART file to load.
-- <appdata>: The application data (AppData) object
local function ArtFileWrapper(artfn, appdata)
    local af, errmsg = B.artfile(artfn)
    if (af == nil) then
        doexit("Failed loading %s: %s", artfn, errmsg)
    end

    local aw = {
        -- The artfile object
        artf = af;

        -- Base palette, needed for texture uploading:
        basepal = appdata.basepal;

        -- [localtilenum] = GL texture name
        tex = {};
    }

    return setmetatable(aw, ArtFileWrapper_mt)
end


--== AppData ==--

local AppData_mt = {
    __index = {
        setMouse = function(self, mx, my, mdown)
            self.mx, self.my, self.mdown = mx, my, mdown
        end,
    },

    __metatable = true,
}

-- Return a table with LunART application data.
-- We probably won't ever need more than one AppData per one LuaJIT process,
-- but I find it somewhat cleaner this way.
local function AppData()
    local d = {
        -- Window width and height
        w=0, h=0;

        -- Mouse pointer last position
        mx=0, my=0;

        -- Mouse button pressed?
        mdown = false;

        -- [filename] = <ArtFileWrapper object>
        artwraps = {};

        -- The base palette (uint8_t [768] cdata)
        basepal = getBasepal("PALETTE.DAT");
    }

    -- Open ART files given on the command line.
    for i=1,#arg do
        d.artwraps[arg[i]] = ArtFileWrapper(arg[i], d)
    end

    return setmetatable(d, AppData_mt)
end


local function createAppWindow()
    local wi = glow.window({name="LunART", pos={500, 400}, extent={640, 480}}, g_callbacks)
    glut.glutSetCursor(GLUT.CURSOR_CROSSHAIR)

    -- App data for this window.
    g_data[wi] = AppData()
end


createAppWindow()
glow.mainloop()
