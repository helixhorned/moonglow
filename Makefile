
OS := $(shell uname -s)
MINGW := $(findstring MINGW,$(OS))


########## PATHS ##########

ifeq ($(OS),Linux)
    GL_H := /usr/include/GL/gl.h
    FREEGLUT_H := /usr/local/include/GL/freeglut.h
else
 ifeq ($(MINGW),MINGW)
    GL_H := /c/MinGW/include/GL/gl.h
    FREEGLUT_H := /f/g/mod/freeglut/freeglut/include/GL/freeglut.h
 else
    $(error unknown platform)
 endif
endif

extractdecls := extractdecls -Q

so := .so
WARN := -pedantic -Wall -Werror-implicit-function-declaration
CFLAGS :=

DECLS_LUA = gldecls.lua
CONSTS_LUA = glconsts.lua


########## RULES ##########

.PHONY: bootstrap all

all: bootstrap #moonglow-aux$(so)

# for the TypedefDecl, e.g. -x 'ARB$' doesn't exclude
# for the last FunctionDecl, e.g. -x 'ARB$' gives Bash syntax error (???)
bootstrap:
	@true ## Extract GL decls
	@echo 'require("ffi").cdef[[' > $(DECLS_LUA)
	@$(extractdecls) -w TypedefDecl -p '^GL[a-z]' -x '[*]' -x 64 -x 'ARB' -x 'NV' $(FREEGLUT_H) >> $(DECLS_LUA)
	@$(extractdecls) -w FunctionDecl -p '^glut' -x GLUTproc -x 'ARB$' -x 'NV$' $(FREEGLUT_H) >> $(DECLS_LUA)
	@$(extractdecls) -w FunctionDecl -p 'gl[A-Z]' -x 'ATI' -x 'ARB' -x 'MESA' $(GL_H) >> $(DECLS_LUA)
	@echo ']]' >> $(DECLS_LUA)
	@printf "\033[1mGenerated $(DECLS_LUA)\033[0m\n"
	@true ## Extract GLUT defs
	@echo 'local ffi=require"ffi"; local GLUT = ffi.new([[struct {' > $(CONSTS_LUA)
	@$(extractdecls) -Q -C -w MacroDefinition -p '^GLUT_' -s '^GLUT_' $(FREEGLUT_H) >> $(CONSTS_LUA)
	@echo '}]])' >> $(CONSTS_LUA)
	@echo 'local GL = ffi.new([[struct {' >> $(CONSTS_LUA)
	@$(extractdecls) -Q -C -w MacroDefinition -p '^GL_' -s '^GL_' -x '^GL_[0-9]' -x '^GL_VERSION' -x '_ARB' -x '_EXT' -x '_NV' -x '_ATI' -x '_AMD' -x '_APPLE' -x '_MESA' -x '_SGI' -x '_SUN' -x '_IBM' -x '_INTEL' -x '_KHR' -x '_3DFX' -x '_GREMEDY' -x '_HP' -x '_INGR' -x '_OES' -x '_OML' -x '_PGI' -x '_REND' -x '_S3' -x '_WIN' $(GL_H) >> $(CONSTS_LUA)
	@echo '}]])' >> $(CONSTS_LUA)
	@echo 'return {GL=GL,GLUT=GLUT}' >> $(CONSTS_LUA)
	@printf "\033[1mGenerated $(CONSTS_LUA)\033[0m\n"

moonglow-aux$(so): moonglow-aux.c
	$(CC) $(WARN) $(CFLAGS) -shared -fPIC $< -o $@
