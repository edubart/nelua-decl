GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S glad-api.c -fplugin-arg-gcclua-script=glad.lua > glad.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S glfw-api.c -fplugin-arg-gcclua-script=glfw.lua > glfw.nelua

download:
	# goto https://glad.dav1d.de/ and download manually

test:
	$(NELUA) glfw-test.nelua
