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

        -- NOTE: omitting vararg part in Lua callback function (LuaJIT NYI)
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

    -- Post-window-creation setup

    gl.glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

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
local gltype_verts = {
    short = GL.SHORT, int16_t = GL.SHORT,
    int = GL.INT, int32_t = GL.INT,
    float = GL.FLOAT,
    double = GL.DOUBLE,
}

-- Additional valid types for textures
local gltype_tex = {
    int8_t = GL.BYTE,
    uint8_t = GL.UNSIGNED_BYTE,
    uint16_t = GL.UNSIGNED_SHORT,
    uint32_t = GL.UNSIGNED_INT,
}

local function getVertsType(verts)
    local ts = verts:basetypestr()
    return gltype_verts[ts] or error("invalid vertex base type "..ts, 3)
end

local function getTexType(pic)
    local ts = pic:basetypestr()
    return gltype_verts[ts] or gltype_tex[ts] or error("invalid texture base type "..ts, 3)
end

-- glow.draw(primtype, verts [, opts])
--
-- <primtype>: OpenGL primitive type (GL.LINES etc.)
-- <verts>: a garray...
-- <opts>: a table...
function glow.draw(primitivetype, verts, opts)
    assert(garray.is(verts, 2), "<verts> must be a garray matrix")

    local numdims = verts.size[0]
    assert(numdims>=2 and numdims<=4, "<verts> must have 2, 3 or 4 or columns")
    local numverts = verts.size[1]
    local gltyp = getVertsType(verts)

    opts = opts or {}

    local col = opts.colors
    if (col) then
        gl.glColor3d(col[1], col[2], col[3])
    else
        gl.glColor3d(0.5, 0.5, 0.5)
    end

    local tex, texcoords = opts.tex, opts.texcoords
    if (tex) then
        if (texcoords == nil) then
            error("When passing texture, must also pass texture coordinates (<texcoords>)", 2)
        end

        assert(garray.is(texcoords, 2), "<texcoords> must be a garray matrix")
        assert(texcoords:basetypestr() == "double",
               "<texcoords> must have base type 'double'")  -- Other types: NYI
        assert(texcoords.size[0]==2 and texcoords.size[1]==numverts,
               "<texcoords> must have as many coordinate pairs as there are vertices")

        -- Sanity checking OK, specify the texture and coords to the GL.
        gl.glEnable(GL.TEXTURE_2D)
        gl.glBindTexture(GL.TEXTURE_2D, tex)

        gl.glEnableClientState(GL.TEXTURE_COORD_ARRAY)
        gl.glTexCoordPointer(2, GL.DOUBLE, 0, texcoords.v)
    else
        gl.glDisable(GL.TEXTURE_2D)
        gl.glDisableClientState(GL.TEXTURE_COORD_ARRAY)
    end

    gl.glPolygonMode(GL.FRONT_AND_BACK, opts.line and GL.LINE or GL.FILL)

    gl.glEnableClientState(GL.VERTEX_ARRAY)
    gl.glVertexPointer(numdims, gltyp, 0, verts.v)

    gl.glDrawArrays(primitivetype, 0, numverts)
end

-- gltexname = glow.texture(pic [, opts])
--
-- <pic>: a garray, currently only (numrows, numcols)
function glow.texture(pic, opts)
    assert(garray.is(pic, 2), "<pic> must be a garray matrix")

    local ts = pic:basetypestr()
    assert(ts=="uint8_t" or ts=="uint32_t", "Texture types other than uint8_t or uint32_t: NYI")

    local numrows, numcols = pic:dims()
    local gltyp = GL.UNSIGNED_BYTE  -- getTexType(pic)

    local texnamear = ffi.new("GLuint [1]")
    gl.glGenTextures(1, texnamear)
    local texname = texnamear[0]

    gl.glBindTexture(GL.TEXTURE_2D, texname)

    local opts = opts or {}

    local wrap = opts.wrap or GL.CLAMP_TO_EDGE
    local filter = opts.filter or GL.LINEAR

    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, wrap)
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, wrap)
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filter)
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filter)

    local glformat = (ts=="uint32_t") and GL.RGBA or GL.LUMINANCE
    gl.glPixelStorei(GL.UNPACK_ALIGNMENT, glformat==GL.RGB and 1 or ffi.alignof(ts))

    -- Proxy check first
    gl.glTexImage2D(GL.PROXY_TEXTURE_2D, 0, glformat, numcols, numrows,
                    0, glformat, gltyp, nil)
    local tmpwidthar = ffi.new("GLint [1]")
    gl.glGetTexLevelParameteriv(GL.PROXY_TEXTURE_2D, 0, GL.TEXTURE_WIDTH, tmpwidthar)

    if (tmpwidthar[0] == 0) then
        gl.glDeleteTextures(1, texnamear)
        error("cannot accomodate texture")
    end

    -- NOTE:
    --  numcols corresponds to width
    --  numrows corresponds to height
    gl.glTexImage2D(GL.TEXTURE_2D, 0, glformat, numcols, numrows,
                    0, glformat, gltyp, pic.v)
    return texname
end


-- We're done, return the API table
return glow
