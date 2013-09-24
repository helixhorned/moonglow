-- MoonGLow, a LuaJIT-based interface to FreeGLUT and a subset of OpenGL.

local ffi = require("ffi")

local gl = ffi.load("GL")
local glut = ffi.load("glut")

local glconsts = require("glconsts")
local GL = glconsts.GL
local GLUT = glconsts.GLUT

local garray = require("garray")


local bit = require("bit")

local assert = assert
local error = error
local pairs = pairs
local pcall = pcall
local type = type


require("gldecls")

----------

-- The table that will contain our exported functions.
local glow = { gl=gl, glut=glut, GL=GL, GLUT=GLUT }


-- winid = glow.window(opts, callbacks)
-- Creates a new window.
--
-- <opts> valid keys:
--  pos, extent, name, mode
--
-- <callbacks> valid keys:
function glow.window(opts, callbacks)
    assert(type(opts)=="table", "Invalid argument: must be a table")

    local pos = opts.pos or {200, 200}
    local extent = opts.extent or {800, 600}
    local name = opts.name or "MoonGLow window"
    local mode = opts.mode or bit.bor(GLUT.DOUBLE, GLUT.DEPTH, GLUT.RGBA)
        -- +GLUT.MULTISAMPLE  --DEBUG

    if (glut.glutGet(GLUT.INIT_STATE) == 0) then
        -- A single trailing NULL, for consistency w/ what C99 mandates:
        local argvDummy = ffi.new("char *[1]")
        local argcDummyAr = ffi.new("int [1]")

        glut.glutInitErrorFunc(function(fmt) error(ffi.string(fmt)) end)
        glut.glutInit(argcDummyAr, argvDummy)
        glut.glutSetOption(GLUT.ACTION_ON_WINDOW_CLOSE, GLUT.ACTION_CONTINUE_EXECUTION)

        glut.glutInitDisplayMode(mode);
    end

    if (true) then  -- TODO: subwindows?
        glut.glutInitWindowPosition(pos[1], pos[2])
        glut.glutInitWindowSize(extent[1], extent[2])
    end

    local winid = glut.glutCreateWindow(name)
    if (winid <= 0) then
        error("Failed creating window")
    end

    for cbname, cbfunc in pairs(callbacks) do
        -- Uncomment to make e.g. both 'display' and 'Display' valid:
--        local cbname2 = cbname:sub(1,1):upper() .. cbname:sub(2)
        glut["glut"..cbname.."Func"](cbfunc)
    end

    return winid
end


local g_inMainLoop = false

-- glow.mainloop()
-- Enters the FreeGLUT main event loop once.
function glow.mainloop()
    if (not g_inMainLoop) then
        g_inMainLoop = true
        local ok, errmsg = pcall(glut.glutMainLoop)
        g_inMainLoop = false
        if (errmsg) then
            error(errmsg)
        end
    end
end

function glow.clear(tab)
    if (tab.r) then
        gl.glClearColor(tab.r, tab.g, tab.b, 0)
    else
        gl.glClearColor(tab[1], tab[2], tab[3], 0)
    end
    gl.glClear(GL.COLOR_BUFFER_BIT + GL.DEPTH_BUFFER_BIT)
end

local inv_y_mat = ffi.new("double [16]",
{
    1, 0, 0, 0;
    0,-1, 0, 0;
    0, 0, 1, 0;
    0, 7, 0, 1;  -- [13]: height+1
})

-- glow.setup2d(w, h, base, [, invy])
--
-- <base>: (<base>,<base>) is corner pixel
--  (only 0 and 1 tested)
-- Easiest to work with, consistent with mouse coords in FreeGLUT:
-- <base> is 0, <invy> is true
-- TODO: ^make default
function glow.setup2d(w, h, base, invy)
    gl.glViewport(0, 0, w, h)

    gl.glMatrixMode(GL.PROJECTION)
    gl.glLoadIdentity()
    local ofs = base - 0.5
    gl.glOrtho(ofs, w+ofs, ofs, h+ofs, -1, 1)

    gl.glMatrixMode(GL.MODELVIEW)

    if (not invy) then
        -- (<base>, <base>): lower left corner
        gl.glLoadIdentity()
    else
        -- (<base>, <base>): upper left corner
        inv_y_mat[13] = h - 1 + 2*base
        gl.glLoadMatrixd(inv_y_mat)
    end
end


-- verts -> e.g. GL.INT
local verts_gltype = {
    short = GL.SHORT, int16_t = GL.SHORT,
    int = GL.INT, int32_t = GL.INT,
    float = GL.FLOAT,
    double = GL.DOUBLE,
}

local function getVertsType(verts)
    local ts = verts:basetypestr()
    return verts_gltype[ts] or error("invalid base type "..ts, 3)
end

-- glow.draw(primtype, verts [, opts])
--
-- <primtype>: OpenGL primitive type (GL.LINES etc.)
-- <verts>: a garray...
-- <opts>: a table...
function glow.draw(primitivetype, verts, opts)
    assert(garray.is(verts) and verts.ndims==2, "<verts> must be a garray matrix")

    local numdims = verts.size[0]
    assert(numdims>=2 and numdims<=4, "<verts> must have 2, 3 or 4 or columns")
    local numverts = verts.size[1]
    local gltyp = getVertsType(verts)

    opts = opts or {}

    gl.glPolygonMode(GL.FRONT_AND_BACK, opts.line and GL.LINE or GL.FILL)

    local col = opts.colors
    if (col) then
        gl.glColor3d(col[1], col[2], col[3])
    else
        gl.glColor3d(0.5, 0.5, 0.5)
    end

    gl.glVertexPointer(numdims, gltyp, 0, verts.v)
    gl.glEnableClientState(GL.VERTEX_ARRAY)

    gl.glDrawArrays(primitivetype, 0, numverts)
end


-- We're done, return the API table
return glow
