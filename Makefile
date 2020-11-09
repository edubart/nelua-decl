GCCPLUGIN=-fplugin=./gcc-lua/gcc/gcclua.so

all: c lua sdl2 miniaudio sokol_gfx

c:
	gcc $(GCCPLUGIN) -S libs/c/c.c -fplugin-arg-gcclua-script=libs/c/c.lua > libs/c/c.nelua
lua:
	gcc $(GCCPLUGIN) -S libs/lua/lua.c -fplugin-arg-gcclua-script=libs/lua/lua.lua > libs/lua/lua.nelua
glfw:
	gcc $(GCCPLUGIN) -S libs/glfw/glfw.c -fplugin-arg-gcclua-script=libs/glfw/glfw.lua > libs/glfw/glfw.nelua
sdl2:
	gcc $(GCCPLUGIN) -S libs/sdl2/sdl2.c -fplugin-arg-gcclua-script=libs/sdl2/sdl2.lua > libs/sdl2/sdl2.nelua
sokol: sokol_gfx sokol_app
sokol_gfx:
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_gfx.c -fplugin-arg-gcclua-script=libs/sokol/sokol_gfx.lua > libs/sokol/sokol_gfx.nelua
sokol_app:
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_app.c -fplugin-arg-gcclua-script=libs/sokol/sokol_app.lua > libs/sokol/sokol_app.nelua
miniaudio:
	gcc $(GCCPLUGIN) -S libs/miniaudio/miniaudio.c -fplugin-arg-gcclua-script=libs/miniaudio/miniaudio.lua > libs/miniaudio/miniaudio.nelua

download: download-miniaudio download-sokol_gfx download-sokol_app
download-miniaudio:
	wget -O libs/miniaudio/miniaudio.h https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h
download-sokol_gfx:
	wget -O libs/sokol/sokol_gfx.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_gfx.h
download-sokol_app:
	wget -O libs/sokol/sokol_app.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_app.h

test-all: test-lua test-glfw test-sdl2 test-sokol test-miniaudio
test-lua: lua
	cd libs/lua && nelua lua-test.nelua
test-glfw: glfw
	cd libs/glfw && nelua glfw-test.nelua
test-sdl2: sdl2
	cd libs/sdl2 && nelua sdl2-test.nelua
test-sokol: sokol
	cd libs/sokol && nelua sokol-test.nelua
test-miniaudio: miniaudio
	cd libs/miniaudio && nelua miniaudio-test.nelua pluck.wav
