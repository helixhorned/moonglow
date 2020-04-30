
OS := $(shell uname -s)
MINGW := $(findstring MINGW,$(OS))


########## PATHS ##########

ifeq ($(OS),Linux)
    GL_H := /usr/include/GL/gl.h
    FREEGLUT_H := /usr/include/GL/freeglut.h
else
 ifeq ($(MINGW),MINGW)
    GL_H := /c/MinGW/include/GL/gl.h
    FREEGLUT_H := /f/g/mod/freeglut/freeglut/include/GL/freeglut.h
 else
    $(error unknown platform)
 endif
endif

extractdecls := extractdecls -Q

DECLS_LUA = gldecls.lua
CONSTS_LUA = glconsts.lua


########## RULES ##########

.PHONY: all clean

all: $(DECLS_LUA) $(CONSTS_LUA)

clean:
	$(RM) $(DECLS_LUA) $(CONSTS_LUA)

$(DECLS_LUA): Makefile $(FREEGLUT_H) $(GL_H)
	@echo 'require("ffi").cdef[[' > $@
	@$(extractdecls) -w TypedefDecl -p '^GL[a-z]' -x '^khronos_.*_t$$' -x '[*]' -x 64 -x 'ARB' -x 'NV' $(FREEGLUT_H) >> $@
	@$(extractdecls) -w FunctionDecl -p '^glut' -x GLUTproc -x 'ARB$$' -x 'NV$$' $(FREEGLUT_H) >> $@
	@$(extractdecls) -w FunctionDecl -p 'gl[A-Z]' -x 'ATI' -x 'ARB' -x 'MESA' $(GL_H) >> $@
	@echo ']]' >> $@
	@printf "\033[1mGenerated $@\033[0m\n"

$(CONSTS_LUA): Makefile $(FREEGLUT_H) $(GL_H)
	@echo 'local ffi=require"ffi"; local GLUT = ffi.new([[struct {' > $@
	@$(extractdecls) -Q -C -w MacroDefinition -p '^GLUT_' -s '^GLUT_' $(FREEGLUT_H) >> $@
	@echo '}]])' >> $@
	@echo 'local GL = ffi.new([[struct {' >> $@
	@$(extractdecls) -Q -C -w MacroDefinition -p '^GL_' -s '^GL_' -x '^GL_[0-9]' -x '^GL_VERSION' -x '_ARB' -x '_EXT' -x '_NV' -x '_ATI' -x '_AMD' -x '_APPLE' -x '_MESA' -x '_SGI' -x '_SUN' -x '_IBM' -x '_INTEL' -x '_KHR' -x '_3DFX' -x '_GREMEDY' -x '_HP' -x '_INGR' -x '_OES' -x '_OML' -x '_PGI' -x '_REND' -x '_S3' -x '_WIN' $(GL_H) >> $@
	@echo '}]])' >> $@
	@echo 'return {GL=GL,GLUT=GLUT}' >> $@
	@printf "\033[1mGenerated $@\033[0m\n"
