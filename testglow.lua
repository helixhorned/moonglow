#!/usr/bin/env luajit

local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local garray = require("garray")
local ga_int = garray.newType("int")

local math = require("math")
local cos, sin = math.cos, math.sin
local max = math.max

-- Test app data. [windowid] = { ... }
local g_data = {}

local function reshape(w, h)
    local d = assert(g_data[glut.glutGetWindow()])

    d.w = w
    d.h = h
end

local function display()
    local d = assert(g_data[glut.glutGetWindow()])

    local ms = glut.glutGet(GLUT.ELAPSED_TIME)
    local color = {
        max(0.8, cos(ms/1000)),
        max(0.8, sin(0.4*ms/1000)),
        max(0.8, (0.0003*ms)%1),
    }

    local w, h = d.w, d.h
    glow.setup2d(w, h)
    glow.clear(color)

    local v = ga_int(2, 4, {1,1; 1,h; w,h; w,1})
    glow.draw(GL.LINE_STRIP, v, {line=true, colors={0.2, 0.2, 0.2}})

    local v = ga_int(2, 4, {10,10; 10,h/2; w/2,h/2; w/2,10})
    glow.draw(GL.LINE_LOOP, v, {line=true, colors={0.6, 0.2, 0.2}})

    glut.glutSwapBuffers()
end

local function motion()
    glut.glutPostRedisplay()
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
    g_data[wi] = { w=0, h=0 }  -- don't init width/height yet
end

local function mouse(button, state)
    if (button==GLUT.MIDDLE_BUTTON and state==GLUT.DOWN) then
        createWindow()
    end
end

callbacks = {
    Display=display, PassiveMotion=motion, Motion=motion, Mouse=mouse,
    Reshape=reshape,
}


createWindow()
glow.mainloop()
