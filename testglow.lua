#!/usr/bin/env luajit

local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local garray = require("garray")
local ga_int = garray.newType("int")
local ga_uint8 = garray.newType("uint8_t")

local math = require("math")
local cos, sin = math.cos, math.sin
local max = math.max

local unpack = unpack


local function ivec2(tab)
    local numverts = #tab/2
    return ga_int(2, numverts, tab)
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

local function display()
    local d = getdata()

    local ms = glut.glutGet(GLUT.ELAPSED_TIME)
    local color = d.mdown and {
        max(0.8, cos(ms/1000)),
        max(0.8, sin(0.4*ms/1000)),
        max(0.8, (0.0003*ms)%1),
    } or { 0.9, 0.9, 0.9 }

    glow.clear(unpack(color))

    local w, h = d.w, d.h
    local v = ivec2{1,1; 1,h; w,h; w,1} - 1
    glow.draw(GL.LINE_STRIP, v, {line=true, colors={0.2, 0.2, 0.2}})

    if (d.tex == 0) then
        local ph, pw = 128, 256
        local pic = ga_uint8(ph, pw, {})
        for r = 0,ph-1 do
            for c = 0,pw-1 do
                pic:set(r, c, max(r, c))
            end
        end

        d.tex = glow.texture(pic)
    end

    local v = ivec2{10,10; 10,h/2; w/2,h/2; w/2,10}
--    glow.draw(GL.LINE_LOOP, v, {line=true, colors={0.6, 0.2, 0.2}})
    glow.draw(GL.LINE_LOOP, v, {colors={1,1,1}})

    -- draw mouse reticle
    local mx, my = d.mx, d.my
    local v = ivec2{mx-10,my; mx+10,my; mx,my-10;mx, my+10}
    glow.draw(GL.LINES, v, {line=true, colors={0.2, 0.2, 0.8}})

    glut.glutSwapBuffers()
end

local function motion_common(x, y)
    local d = getdata()
    d.mx, d.my = x, y

    glut.glutPostRedisplay()
end

local function passivemotion(x, y)
    getdata().mdown = false
    motion_common(x, y)
end

local function motion(x, y)
    getdata().mdown = true
    motion_common(x, y)
end

local callbacks

local function createWindow()
    local win = glut.glutGetWindow()
    local pos = (win==0) and {500, 400} or
        {
            glut.glutGet(GLUT.WINDOW_X) + 20,
            glut.glutGet(GLUT.WINDOW_Y) + 20,
        }

    local wi = glow.window({name="MoonGLow test", pos=pos, extent={640, 480}}, callbacks)
    glut.glutSetCursor(GLUT.CURSOR_CROSSHAIR)
    -- App data for this window. Don't init width/height yet.
    g_data[wi] = { w=0, h=0, mx=0, my=0, mdown=false, tex=0 }
end

local function mouse(button, state)
    if (button==GLUT.MIDDLE_BUTTON and state==GLUT.DOWN) then
        createWindow()
    end
end

callbacks = {
    Display=display, PassiveMotion=passivemotion, Motion=motion, Mouse=mouse,
    Reshape=reshape,
}


createWindow()
glow.mainloop()
