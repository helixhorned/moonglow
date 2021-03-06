-- MoonGLow, a LuaJIT-based interface to FreeGLUT and a subset of OpenGL.

local ffi = require("ffi")
local jit = require("jit")

local glLibName = (ffi.os=="Windows") and "opengl32" or (ffi.os=="OSX" and "OpenGL.framework/OpenGL" or "GL")
-- we always need FreeGLUT, but on Linux, it installs as 'libglut.so':
local glutLibName = (ffi.os=="Windows") and "freeglutd" or "glut"

local gl =  ffi.load(glLibName)
local glut = ffi.load(glutLibName)

local glconsts = require("glconsts")
local GL = glconsts.GL
local GLUT = glconsts.GLUT

local garray = require("garray")


local bit = require("bit")
local string = require("string")

local assert = assert
local error = error
local pairs = pairs
local pcall = pcall
local type = type


require("gldecls")

-- Get font constants.
local FONT_ROMAN
local FONT_MONO

if (jit.os == "Windows") then
    FONT_ROMAN = ffi.cast("void *", 0)
    FONT_MONO = ffi.cast("void *", 1)
else
--[[
    In freeglut.h, we have:

      /* I don't really know if it's a good idea... But here it goes: */
      extern void* glutStrokeRoman;
      #define  GLUT_STROKE_ROMAN ((void *)&glutStrokeRoman)

    Now, we *misdeclare* it so we can get its address.
--]]
    ffi.cdef[[
extern void* glutStrokeRoman[1];
extern void* glutStrokeMonoRoman[1];
]]
    FONT_ROMAN = ffi.cast("void *", glut.glutStrokeRoman)
    FONT_MONO = ffi.cast("void *", glut.glutStrokeMonoRoman)
end

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
    gl.glHint(GL.POINT_SMOOTH_HINT, GL.NICEST)
    gl.glHint(GL.LINE_SMOOTH_HINT, GL.NICEST)

    for cbname, cbfunc in pairs(callbacks) do
        if (cbname == "MotionBoth") then
            -- A single callback for passive and active motion.
            local function onPassiveMotion(x, y)
                return cbfunc(false, x, y)
            end

            local function onActiveMotion(x, y)
                return cbfunc(true, x, y)
            end

            glut.glutPassiveMotionFunc(onPassiveMotion)
            glut.glutMotionFunc(onActiveMotion)
        elseif (cbname == "KeyBoth") then
            -- A single callback for ASCII and special keys.
            local function onKeyboard(asc, x, y)
                -- Key will be a string of length one!
                return cbfunc(string.char(asc), x, y, glut.glutGetModifiers())
            end

            local function onSpecial(key, x, y)
                return cbfunc(key, x, y, glut.glutGetModifiers())
            end

            glut.glutKeyboardFunc(onKeyboard)
            glut.glutSpecialFunc(onSpecial)
        else
            -- Uncomment to make e.g. both 'display' and 'Display' valid:
--            local cbname2 = cbname:sub(1,1):upper() .. cbname:sub(2)
            glut["glut"..cbname.."Func"](cbfunc)
        end
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

-- glow.redisplay()
-- Issues a redisplay request.
function glow.redisplay()
    glut.glutPostRedisplay()
end

-- glow.clear(r [, g [, b]])
--
-- defaults:
--  for g, value of r
--  for b, value of g
function glow.clear(r, g, b)
    g = g or r
    gl.glClearColor(r, g, b or g, 0)
    gl.glClear(GL.COLOR_BUFFER_BIT + GL.DEPTH_BUFFER_BIT)
end

local inv_y_mat = ffi.new("double [16]",
{
    1, 0, 0, 0;
    0,-1, 0, 0;
    0, 0, 1, 0;
    0, 7, 0, 1;  -- [13]: height +/- 1
})

local g_last_invy = false

-- glow.setup2d(w, h, [base, [, dontinvy]])
--
-- <base>: (<base>,<base>) is corner pixel
--  (only 0 and 1 tested)
-- Easiest to work with, consistent with mouse coords in FreeGLUT:
-- <base> is 0, <dontinvy> is false
function glow.setup2d(w, h, base, dontinvy)
    if (base == nil) then
        base = 0
    end

    g_last_invy = not dontinvy

    gl.glViewport(0, 0, w, h)

    gl.glMatrixMode(GL.PROJECTION)
    gl.glLoadIdentity()
    local ofs = base - 0.5
    gl.glOrtho(ofs, w+ofs, ofs, h+ofs, -1, 1)

    gl.glMatrixMode(GL.MODELVIEW)

    if (dontinvy) then
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
    local colistab = (type(col) == "table")

    if (col) then
        -- <opts>.colors provided
        if (not colistab) then
            -- <opts>.colors is a garray
            assert(garray.is(col, 2), "<opts>.colors must be a garray matrix or a table")
            assert(col:basetypestr() == "double",
                   "<opts>.colors must have base type 'double'")  -- Other types: NYI
            assert(col.size[0]==3 and col.size[1]==numverts,
                   "<opts>.colors must have as many (R,G,B) triples as there are vertices")

            gl.glEnableClientState(GL.COLOR_ARRAY);
            gl.glColorPointer(3, GL.DOUBLE, 0, col.v);
        else
            -- <opts>.colors is a table
            gl.glDisableClientState(GL.COLOR_ARRAY);
            if (#col >= 4) then
                gl.glColor4d(col[1], col[2], col[3], col[4])
            else
                gl.glColor3d(col[1], col[2], col[3])
            end
        end
    else
        gl.glDisableClientState(GL.COLOR_ARRAY);
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

    -- Convenience functionality: col is [r g b a]: enable blending
    local enabledBlend = (colistab and (#col >= 4) and gl.glIsEnabled(GL.BLEND)==0)
    if (enabledBlend) then
        gl.glEnable(GL.BLEND)
    end

    gl.glDrawArrays(primitivetype, 0, numverts)

    if (enabledBlend) then
        gl.glDisable(GL.BLEND)
    end
end

local single_GLuint = ffi.typeof("GLuint [1]")

-- gltexname = glow.texture(pic [, opts [, texname]])
--
-- <pic>: a garray, currently only (numrows, numcols)
-- TODO: a means of specifying that uint32_t is to be interpreted as RGBA
--       uint8_t (as it is currently).
-- Valid opts keys:
--  wrap (e.g. GL.CLAMP)
--  filter (e.g. GL.LINEAR)
function glow.texture(pic, opts, texname, internal_use_HACK)
    assert(garray.is(pic, 2), "<pic> must be a garray matrix")
    assert(texname == nil or type(texname) == "number",
           "<texname> must be a number if passed")

    local ts = pic:basetypestr()
    assert(ts=="uint8_t" or ts=="uint32_t", "Texture types other than uint8_t or uint32_t: NYI")

    local numrows, numcols = pic:dims()
    local gltyp = GL.UNSIGNED_BYTE  -- getTexType(pic)

    local isNewTexture = (texname == nil)

    if (isNewTexture) then
        local texnamear = single_GLuint()
        gl.glGenTextures(1, texnamear)
        texname = texnamear[0]

        gl.glBindTexture(GL.TEXTURE_2D, texname)
    end

    local opts = opts or {}

    local wrap = opts.wrap or GL.CLAMP_TO_EDGE
    local filters =
        opts.filter and { opts.filter, opts.filter } or
        opts.filters and { opts.filters.min, opts.filters.mag } or
        { GL.LINEAR, GL.LINEAR }

    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, wrap)
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, wrap)
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters[1])
    gl.glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters[2])

    local glformat = (ts=="uint32_t") and GL.RGBA or GL.LUMINANCE
    gl.glPixelStorei(GL.UNPACK_ALIGNMENT, glformat==GL.RGB and 1 or ffi.alignof(ts))

    -- Proxy check first
    gl.glTexImage2D(GL.PROXY_TEXTURE_2D, 0, glformat, numcols, numrows,
                    0, glformat, gltyp, nil)
    local tmpwidthar = ffi.new("GLint [1]")
    gl.glGetTexLevelParameteriv(GL.PROXY_TEXTURE_2D, 0, GL.TEXTURE_WIDTH, tmpwidthar)

    if (tmpwidthar[0] == 0) then
        if (isNewTexture) then
            local texnamear = single_GLuint(texname)
            gl.glDeleteTextures(1, texnamear)
        end
        error("cannot accomodate texture")
    end

    -- NOTE:
    --  numcols corresponds to width
    --  numrows corresponds to height
    local dims = (internal_use_HACK == nil) and { numcols, numrows } or
        { numrows, numcols }

    gl.glTexImage2D(GL.TEXTURE_2D, 0, glformat, dims[1], dims[2],
                    0, glformat, gltyp, pic.v)
    return texname
end


-- FreeGLUT's Roman font characteristics --
-- The width of the space and all characters for the monospaced font:
local SPCWIDTH = 104.762
local FONTHEIGHT = 119.05

local map_xyalign = { [-1]=0.0, [0]=0.5, [1]=1.0 }
local SPACE_REPL_CHAR = string.byte('t')

-- glow.text(pos, height, str [, xyalign_or_opts [, opts]])
-- [ That is, one of
--    glow.text(pos, height, str)
--    glow.text(pos, height, str, xyalign)
--    glow.text(pos, height, str, opts)
--    glow.text(pos, height, str, xyalign, opts)
-- ]
--
-- Valid opts keys:
--  color (sequence containing 3 numbers (0.0--1.0))
--  xgap (in monofont letter widths)
--  mono (monospaced?)
--  getw (only get width, don't draw?)
function glow.text(pos, height, str, xyalign, opts)
    local have_xyalign = (xyalign ~= nil and xyalign[1] ~= nil)

    if (opts == nil) then
        opts = (not have_xyalign and xyalign) or {}
    end

    if (not have_xyalign) then
        xyalign = { 0, 0 }  -- corresponds to passed {-1, -1}
    else
        xyalign[1] = map_xyalign[xyalign[1]]
        xyalign[2] = map_xyalign[xyalign[2]]
    end
    local xalign, yalign = xyalign[1], xyalign[2]

    local color = opts.color or { 0.2, 0.2, 0.2 }

    -- xspacing default was determined to look good by trial/error:
    local xspacing = opts.xgap and opts.xgap*SPCWIDTH or FONTHEIGHT/10.0
    local font = opts.mono and FONT_MONO or FONT_ROMAN

    assert(type(pos) == "table", "<pos> must be a table")
    assert(#pos == 2 or #pos == 3, "<pos> must have length 2 or 3")

    local cstr = ffi.new("char [?]", #str+1, str)
    local isspace = ffi.new("bool [?]", #str)

    for i=0,#str-1 do
        if (cstr[i] == 32) then
            cstr[i] = SPACE_REPL_CHAR
            isspace[i] = true
        end
    end

    local textlen

    if (xalign ~= 0 or opts.getw) then
        -- XXX: if the string contains a newline, this will be wrong.
        local strokeslen = glut.glutStrokeLength(font, cstr)
        textlen = (strokeslen + (#str-1)*xspacing)

        if (opts.getw) then
            return textlen
        end
    end

    -- Prepare drawing the text...

    gl.glMatrixMode(GL.MODELVIEW)
    gl.glPushMatrix()
    gl.glPushAttrib(bit.bor(GL.CURRENT_BIT, GL.ENABLE_BIT, GL.COLOR_BUFFER_BIT))

    gl.glColor4d(color[1], color[2], color[3], 1)
    gl.glDisable(GL.TEXTURE_2D)

    gl.glEnable(GL.LINE_SMOOTH)
    gl.glEnable(GL.BLEND)
--[[
    if (ffi.os ~= "Windows") then  -- XXX
        gl.glBlendEquation(GL.FUNC_ADD)
    end
]]
    gl.glTranslated(pos[1], pos[2], #pos==2 and 0.0 or pos[3])

    gl.glScaled(height/FONTHEIGHT, height/FONTHEIGHT, height/FONTHEIGHT)

    if (g_last_invy) then
        inv_y_mat[13] = 0
        gl.glMultMatrixd(inv_y_mat)
    end

    if (yalign ~= 0.0) then  -- y-align
        gl.glTranslated(0, -yalign*FONTHEIGHT, 0)
    end

    if (xalign ~= 0.0) then
        -- TODO: proper newline handling (see above)?
        gl.glTranslated(-xalign*textlen, 0, 0)
    end

    -- Draw it at last!
    for i=0,#str-1 do
        local ch = cstr[i]

        if (isspace[i]) then
            gl.glColor4d(0, 0, 0, 0)
            glut.glutStrokeCharacter(font, SPACE_REPL_CHAR)
            gl.glColor4d(color[1], color[2], color[3], 1)
        else
            glut.glutStrokeCharacter(font, ch)
        end

        -- Add a bit of spacing, since by default, GLUT's stroke text
        -- looks too cramped...
        gl.glTranslated(xspacing, 0, 0)
    end

    gl.glPopMatrix()
    gl.glPopAttrib()
end


-- We're done, return the API table
return glow
