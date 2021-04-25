GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sdl2.c -fplugin-arg-gcclua-script=sdl2.lua > sdl2.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sdl2_image.c -fplugin-arg-gcclua-script=sdl2_image.lua > sdl2_image.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sdl2_mixer.c -fplugin-arg-gcclua-script=sdl2_mixer.lua > sdl2_mixer.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S sdl2_ttf.c -fplugin-arg-gcclua-script=sdl2_ttf.lua > sdl2_ttf.nelua

download:
	# should be installed by the user

test:
	$(NELUA) sdl2-test.nelua
	$(NELUA) sdl2-extras-test.nelua
