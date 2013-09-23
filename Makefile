
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
luajit := luajit

GL_H := /usr/include/GL/gl.h
FREEGLUT_H := /usr/local/include/GL/freeglut.h

LJCLANG_DIR := $(THIS_DIR)/../ljclang
extractdecls := LD_LIBRARY_PATH=$(LJCLANG_DIR) LUA_PATH=";;$(LJCLANG_DIR)/?.lua" $(luajit) $(LJCLANG_DIR)/extractdecls.lua -Q


DECLS_LUA = gldecls.lua
CONSTS_LUA = glconsts.lua

.PHONY: bootstrap

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
	@$(extractdecls) -Q -w MacroDefinition -p '^GLUT_' -s '^GLUT_' -f "return f('static const int %s = %s%s;', k, (k:find('^KEY_') and not k:find('^KEY_REPEAT')) and '65536+' or '', v)" $(FREEGLUT_H) >> $(CONSTS_LUA)
	@echo '}]])' >> $(CONSTS_LUA)
	@echo 'local GL = ffi.new([[struct {' >> $(CONSTS_LUA)
	@$(extractdecls) -Q -C -w MacroDefinition -p '^GL_' -s '^GL_' -x '^GL_[0-9]' -x '^GL_VERSION' -x '_ARB' -x '_EXT' -x '_NV' -x '_ATI' -x '_AMD' -x '_APPLE' -x '_MESA' -x '_SGI' -x '_SUN' -x '_IBM' -x '_INTEL' -x '_KHR' -x '_3DFX' -x '_GREMEDY' -x '_HP' -x '_INGR' -x '_OES' -x '_OML' -x '_PGI' -x '_REND' -x '_S3' -x '_WIN' $(GL_H) >> $(CONSTS_LUA)
	@echo '}]])' >> $(CONSTS_LUA)
	@echo 'return {GL=GL,GLUT=GLUT}' >> $(CONSTS_LUA)
	@printf "\033[1mGenerated $(CONSTS_LUA)\033[0m\n"
