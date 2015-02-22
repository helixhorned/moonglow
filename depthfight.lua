
--== Depth fighting interactive testing app ==--

local ffi = require"ffi"

----------

local glow = require("moonglow")
local gl, glut, GL, GLUT = glow.gl, glow.glut, glow.GL, glow.GLUT

local garray = require("garray")
local ga_double = garray.newType("double")

local assert = assert
local setmetatable = setmetatable

local bit = require("bit")

local math = require("math")
local abs = math.abs

local string = require("string")
local format = string.format


-- Create a 2xN 'double' garray matrix from <tab>.
local function dvec2(tab)
    local numverts = #tab/2
    return ga_double(2, numverts, tab)
end

-- Create a 3xN 'double' garray matrix from <tab>.
local function dvec3(tab)
    local numverts = #tab/3
    return ga_double(3, numverts, tab)
end


-- Application data, per-window. [windowid] = <AppData object>
local g_data = {}

-- Get AppData of current window.
local function getdata()
    return assert(g_data[glut.glutGetWindow()])
end

local function clamp(x, min, max)
    return
        x < min and min or
        x > max and max or x
end


local function setup_3d_scene()
    local d = getdata()
    gl.glViewport(0, 0, d.w, d.h)

    gl.glMatrixMode(GL.PROJECTION)
    gl.glLoadIdentity()
    local a = d.w/d.h
    gl.glFrustum(-a, a, 1, -1, 1, 10^d.log10zfar)

    gl.glMatrixMode(GL.MODELVIEW)
    gl.glLoadIdentity()

    gl.glDisable(GL.DEPTH_TEST)
    gl.glDisable(GL.POLYGON_OFFSET_FILL)
end

local function setup_2d_scene()
    local d = getdata()
    glow.setup2d(d.w, d.h, 1, false)

    gl.glDisable(GL.DEPTH_TEST)
    gl.glDisable(GL.POLYGON_OFFSET_FILL)
end

--== window reshape callback ==--
local function reshape_cb(w, h)
    local d = getdata()
    d.w = w
    d.h = h
end

-- dv = rectquad(pq)
-- pq: table { x1, x2; y1, y2; [z] }
local function rectquad(pq)
    local x1, x2 = pq[1], pq[2]
    local y1, y2 = pq[3], pq[4]
    local z = pq[5] or 0

    return dvec3{
        x1, y1, z;
        x2, y1, z;
        x2, y2, z;
        x1, y2, z;
    }
end

--== display callback ==--
local function display_cb()
    local d = getdata()

    glow.clear(0.9)

    -- 3D scene

    local board = {-10, 10; -5, 5}
    local board_colors = dvec3{
        0, 0, 0;
        1, 0, 0;
        0, 0, 0;
        0, 0, 1;
    }

    -- not offset quads
    local BaseQuads = {
        board, board_colors;
        {-7.5, -6.5; -5, 5; 10^d.log10zofs}, {1, 0, 0};
    }

    -- offset quads
    local Quads = {
        {-8, -4; -2, 4}, {0, 1, 0};
        {-6, -2; 2, -4}, {0, 1, 1};
        {-9, 7; -1, 1}, {1, 1, 1};
    }

    setup_3d_scene()

    local a = d.w/d.h
    for i=1,3 do
        local c = i/4
        local z1, z2 = -10^(i-1), -10^i
        glow.draw(GL.QUADS, dvec3{a,0,z1; a,1,z1; a,1,z2; a,0,z2}, { colors={c,c,c} })
    end

    gl.glTranslated(d.trans.x, d.trans.y, d.trans.z)
    gl.glRotated(d.rot.y, 1, 0, 0)
    gl.glRotated(d.rot.x, 0, 1, 0)
    gl.glRotated(d.rot.z, 0, 0, 1)

    gl.glEnable(GL.DEPTH_TEST)

    for i=0,#BaseQuads/2-1 do
        glow.draw(GL.QUADS, rectquad(BaseQuads[2*i+1]), { colors = BaseQuads[2*i+2] })
    end

    gl.glEnable(GL.POLYGON_OFFSET_FILL)

    for i=0,#Quads/2-1 do
        local depf = (i+1) * (d.huge and 1024 or 1)
        local factor = -d.factor * (d.indexDependent.f and depf or 1)
        local units = -d.units * (d.indexDependent.u and depf or 1)
        gl.glPolygonOffset(factor, units)

        local quad = rectquad(Quads[2*i+1])
        local opts = { colors = Quads[2*i+2] }

        glow.draw(GL.QUADS, quad, opts)
    end

    -- Overlays

    setup_2d_scene()
    glow.draw(GL.QUADS, rectquad{0, 320; 0, 260}, { colors = {0.95, 0.95, 0.95, 0.9} })

    glow.text({10, 20}, 12, format("Trans:  %.2f  %.2f  %.2f", d.trans.x, d.trans.y, d.trans.z))
    glow.text({310, 20}, 12, "[lmb, mmb]", {1, -1})
    glow.text({10, 40}, 12, format("Rot:    %.2f  %.2f  %.2f", d.rot.x, d.rot.y, d.rot.z))
    glow.text({310, 40}, 12, "[rmb]", {1, -1})
    glow.text({10, 60}, 12, format("log10(zofs red quad): %.2f", d.log10zofs))
    glow.text({310, 60}, 12, "[pgup/pgdn]", {1, -1})
    glow.text({10, 80}, 12, format("log10(zfar): %.2f", d.log10zfar))
    glow.text({310, 80}, 12, "[kp+/kp-]", {1, -1})

    local hugef = (d.huge and d.indexDependent.f) and "* 1024" or ""
    local hugeu = (d.huge and d.indexDependent.u) and "* 1024" or ""

    glow.text({10, 120}, 10, format('For glPolygonOffset(); offset is factor*DZ + r*units:'))
    glow.text({10, 140}, 12, format("[F]actor: %.1f (%s) %s", d.factor, d:getDependent('f'), hugef))
    glow.text({310, 140}, 12, "[up/down]", {1, -1})
    glow.text({10, 160}, 12, format("[U]nits: %.1f (%s) %s", d.units, d:getDependent('u'), hugeu))
    glow.text({310, 160}, 12, "[left/right]", {1, -1})
    glow.text({10, 180}, 10, format("Hold CTRL for steps of 10 | TAB toggles *= 1024"), { color = {0.5, 0.5, 0.5}})

    glow.text({10, 220}, 12, format("[0]: reset x/y translation and rotation"))
    glow.text({10, 240}, 12, format("Locked: [X]:%s, [Y]:%s", d.lock.x, d.lock.y))

    assert(gl.glGetError() == GL.NO_ERROR)
    glut.glutSwapBuffers()
end


--== mouse button callback ==--
local function mouse_cb(button, state, x, y)
    local d = getdata()

    local but = 2^button

    if (state == GLUT.DOWN) then
        d.mb = bit.bor(d.mb, but)
    else
        d.mb = bit.band(d.mb, 0xff-but)
    end

    d:setMouse(x, y, d.mb~=0)
end


--== mouse motion callback ==--
local function motion_both_cb(isdown, x, y)
    local d = getdata()

    if (isdown) then
        local mb = d.mb

        -- LMB: x/y translation, RMB: rotation
        local what =
            mb==1 and "trans" or
            mb==4 and "rot" or
            nil

        if (what) then
            local dx = d.lock.x and 0 or x-d.mx
            local dy = d.lock.y and 0 or y-d.my

            local xmul = (what=="rot") and -1 or 1
            local ymul = (what=="rot") and 2 or 1

            d[what].x = d[what].x + xmul*dx/20
            d[what].y = d[what].y + ymul*dy/20
        elseif (mb == 2) then
            -- MMB: z translation
            local dz = -(y-d.my) * d.trans.z/200
            d.trans.z = clamp(d.trans.z + dz, -200, -1)
        end
    end

    getdata():setMouse(x, y, isdown)
    glut.glutPostRedisplay()
end


--== key press callback ==--
local function key_both_cb(key, x, y, mods)
    local d = getdata()

    local what =
        (key==GLUT.KEY_UP or key==GLUT.KEY_DOWN) and "factor" or
        (key==GLUT.KEY_LEFT or key==GLUT.KEY_RIGHT) and "units" or
        nil

    local div = ((mods == GLUT.ACTIVE_CTRL) and 1 or 10)

    if (what) then
        local change = ((key==GLUT.KEY_LEFT or key==GLUT.KEY_DOWN) and -1 or 1) / div
        d[what] = math.max(d[what] + change, 0)
    elseif (key == 'f' or key == 'u' or key == 'q' or key == 'w') then
        local map = { q='f', w='u' }
        key = map[key] or key
        d.indexDependent[key] = not d.indexDependent[key]
    elseif (key == '\t') then
        d.huge = not d.huge
    elseif (key == '0' or key == 'o') then
        d.trans.x, d.trans.y = 0, 0
        d.rot.x, d.rot.y = 0, 0
    elseif (key == 'x' or key == 'y') then
        d.lock[key] = not d.lock[key]
    elseif (key == GLUT.KEY_PAGE_UP or key == GLUT.KEY_PAGE_DOWN) then
        local change = ((key == GLUT.KEY_PAGE_UP) and -1 or 1) / div
        d.log10zofs = clamp(d.log10zofs + change, -5, 0)
    elseif (key == '+' or key == '-') then  -- intended to be pressed on the keypad
        local change = ((key == '-') and -1 or 1) / div
        d.log10zfar = clamp(d.log10zfar + change, 1, 6)
    end

    glow.redisplay()
end


local g_callbacks = {
    Display=display_cb, MotionBoth=motion_both_cb,
    Reshape=reshape_cb, KeyBoth=key_both_cb,
    Mouse=mouse_cb,
}


local AppData_mt = {
    __index = {
        setMouse = function(self, mx, my, mdown)
            self.mx, self.my, self.mdown = mx, my, mdown
        end,

        getDependent = function(self, key)
            return self.indexDependent[key] and "scaled" or "fixed"
        end,
    },

    __metatable = true,
}

-- Return a table with DepthFight application data.
local function AppData(extent)
    -- Window extent
    local w, h = extent[1], extent[2]

    local d = {
        -- Window width and height
        w=w, h=h;

        -- Mouse pointer last position
        mx=0, my=0;

        -- Mouse button pressed?
        mdown = false;

        -- Mouse button down?
        -- (1: left, 2: middle, 4: right)
        mb = 0;

        --== (Drawing) state ==--

        trans = { x=0, y=0, z=-10 };
        rot = { x=1, y=0, z=0 };

        lock = { x=false, y=false };

        -- for glPolygonOffset
        factor = 0, units = 0;
        -- Should factor or units be multiplied with the running quad index?
        indexDependent = { f=false, u=false };
        -- Additionally multiply scaled factor or units with 1024?
        huge = false;

        -- log10 of the z offset of the red quad in front of the board
        log10zofs = -1;

        -- log10 of zfar for glFrustum()
        log10zfar = 4;
    }

    return setmetatable(d, AppData_mt)
end


local function createAppWindow()
    local extent = {1620, 1000-40}

    local wi = glow.window({name="Depth fighting test app",
                            pos={20, 10}, extent=extent},
                           g_callbacks)

    glut.glutSetCursor(GLUT.CURSOR_CROSSHAIR)

    -- App data for this window.
    g_data[wi] = AppData(extent)
end



createAppWindow()
glow.mainloop()
