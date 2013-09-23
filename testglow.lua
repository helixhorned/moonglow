#!/usr/bin/env luajit

local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local math = require("math")
local cos, sin = math.cos, math.sin

local function display()
    local ms = glut.glutGet(GLUT.ELAPSED_TIME)
    local color = { cos(ms/1000), sin(0.4*ms/1000), (0.0003*ms)%1 }
    glow.clear(color)

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
    glow.window({name="MoonGLow test", pos=pos, extent={640, 480}}, callbacks)
end

local function mouse(button, state)
    if (state==GLUT.DOWN) then
        createWindow()
    end
end

callbacks = { Display=display, PassiveMotion=motion, Motion=motion, Mouse=mouse }


createWindow()
glow.mainloop()
