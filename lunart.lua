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

local math = require("math")
local cos, sin = math.cos, math.sin
local max = math.max

local bit = require("bit")
local ffi = require("ffi")
local io = require("io")
local os = require("os")

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


-- Application data, per-window. [windowid] = { ... }
local g_data = {}

-- Get current window.
local function getdata()
    return assert(g_data[glut.glutGetWindow()])
end


local function reshape(w, h)
    local d = getdata()

    glow.setup2d(w, h)
    d.w = w
    d.h = h
end

local function ptinrect(x, y, r)
    local nr, nc = r:dims()
    return nr==2 and nc==2 and
        r.v[0] <= x and r.v[1] <= y and
        x <= r.v[2] and y <= r.v[3]
end

local function display()
    local d = getdata()

    glow.clear(0.9)

    local w, h = d.w, d.h
    local v = ivec2{10,10; w/2,10; w/2,h/3; 10,h/3}
    glow.draw(GL.QUADS, v, {colors={1,1,1}, tex=d.tex,
                            texcoords = dvec2{0,0; 0,1; 1,1; 1,0}})

    local rect = ivec2{10,10; w/2,h/3}  -- CODEDUP; need "slices" or similar
    if (ptinrect(d.mx, d.my, rect)) then
        glow.draw(GL.LINE_LOOP, v, {colors={1,1,0.4}})
    end

    local ti = d.tileinf
    glow.text({20, h/3+20}, 14, format("Tile %d: %d x %d", ti.num, ti.w, ti.h))

    assert(gl.glGetError() == GL.NO_ERROR)

    glut.glutSwapBuffers()
end

local function motion_both(isdown, x, y)
    local d = getdata()
    d.mx, d.my = x, y
    d.mdown = isdown

    glut.glutPostRedisplay()
end

local callbacks = {
    Display=display, MotionBoth=motion_both,
    Reshape=reshape,
}


local function doexit(fmt, ...)
    local msg = string.format(fmt, ...)
    io.stderr:write(msg)
    os.exit(1)
end

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

-- <d>: table with some initialized fields
local function initAppData(d)
    local palfn, artfn, ltile = arg[1], arg[2], tonumber(arg[3])
    if (palfn==nil or artfn==nil or ltile==nil) then
        doexit("Usage: %s /path/to/PALETTE.DAT /path/to/TILES?.ART ltilenum\n", arg[0])
    end

    local palette, errmsg = B.read_basepal(palfn)
    if (palette == nil) then
        doexit("Failed reading %s: %s", palfn, errmsg)
    end
    palette = expand_basepal(palette)

    local artf, errmsg = B.artfile(artfn)
    if (artf == nil) then
        doexit("Failed reading %s: %s", artfn, errmsg)
    end

    local img = artf:getpic(ltile)
    local pw, ph = artf:dims(ltile)

    d.tileinf = { num=ltile, w=pw, h=ph }

    local teximg = ga_uint32(pw,ph)
    for i=0,pw*ph-1 do
        teximg.v[i] = palette.v[img[i]]
    end

    d.tex = glow.texture(teximg, {filter=GL.NEAREST})

    return d
end


local function createWindow()
    local win = glut.glutGetWindow()
    local pos = (win==0) and {500, 400} or
        {
            glut.glutGet(GLUT.WINDOW_X) + 20,
            glut.glutGet(GLUT.WINDOW_Y) + 20,
        }

    local wi = glow.window({name="LunART", pos=pos, extent={640, 480}}, callbacks)
    glut.glutSetCursor(GLUT.CURSOR_CROSSHAIR)

    -- App data for this window. Don't init width/height yet.
    g_data[wi] = initAppData{ w=0, h=0, mx=0, my=0, mdown=false, tex=0 }
end


createWindow()
glow.mainloop()
