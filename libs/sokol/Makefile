GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_app.c -fplugin-arg-gcclua-script=sokol_app.lua > sokol_app.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_args.c -fplugin-arg-gcclua-script=sokol_args.lua > sokol_args.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_audio.c -fplugin-arg-gcclua-script=sokol_audio.lua > sokol_audio.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_gfx.c -fplugin-arg-gcclua-script=sokol_gfx.lua > sokol_gfx.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_time.c -fplugin-arg-gcclua-script=sokol_time.lua > sokol_time.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_nuklear.c -fplugin-arg-gcclua-script=sokol_nuklear.lua > sokol_nuklear.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_gl.c -fplugin-arg-gcclua-script=sokol_gl.lua > sokol_gl.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sokol_gp.c -fplugin-arg-gcclua-script=sokol_gp.lua > sokol_gp.nelua

download:
	wget -O sokol_app.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_app.h
	wget -O sokol_args.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_args.h
	wget -O sokol_audio.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_audio.h
	wget -O sokol_gfx.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_gfx.h
	wget -O sokol_time.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_time.h
	wget -O sokol_nuklear.h https://raw.githubusercontent.com/floooh/sokol/master/util/sokol_nuklear.h
	wget -O sokol_gl.h https://raw.githubusercontent.com/floooh/sokol/master/util/sokol_gl.h
	wget -O sokol_gp.h https://raw.githubusercontent.com/edubart/sokol_gp/master/sokol_gp.h

test:
	$(NELUA) sokol-test.nelua test
	$(NELUA) sokol_gl-test.nelua test
	$(NELUA) sokol_gp-test.nelua test
