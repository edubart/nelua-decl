GCCPLUGIN=-fplugin=./gcc-lua/gcc/gcclua.so

all: lua sdl2 miniaudio sokol stb
all-extra: all c blend2d raylib

c:
	gcc $(GCCPLUGIN) -S libs/c/c.c -fplugin-arg-gcclua-script=libs/c/c.lua > libs/c/c.nelua
lua:
	gcc $(GCCPLUGIN) -S libs/lua/lua.c -fplugin-arg-gcclua-script=libs/lua/lua.lua > libs/lua/lua.nelua
glfw:
	gcc $(GCCPLUGIN) -S libs/glfw/glfw.c -fplugin-arg-gcclua-script=libs/glfw/glfw.lua > libs/glfw/glfw.nelua
sdl2:
	gcc $(GCCPLUGIN) -S libs/sdl2/sdl2.c -fplugin-arg-gcclua-script=libs/sdl2/sdl2.lua > libs/sdl2/sdl2.nelua
sokol:
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_gfx.c -fplugin-arg-gcclua-script=libs/sokol/sokol_gfx.lua > libs/sokol/sokol_gfx.nelua
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_app.c -fplugin-arg-gcclua-script=libs/sokol/sokol_app.lua > libs/sokol/sokol_app.nelua
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_audio.c -fplugin-arg-gcclua-script=libs/sokol/sokol_audio.lua > libs/sokol/sokol_audio.nelua
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_time.c -fplugin-arg-gcclua-script=libs/sokol/sokol_time.lua > libs/sokol/sokol_time.nelua
	gcc $(GCCPLUGIN) -S libs/sokol/sokol_args.c -fplugin-arg-gcclua-script=libs/sokol/sokol_args.lua > libs/sokol/sokol_args.nelua
miniaudio:
	gcc $(GCCPLUGIN) -S libs/miniaudio/miniaudio.c -fplugin-arg-gcclua-script=libs/miniaudio/miniaudio.lua > libs/miniaudio/miniaudio.nelua
stb:
	gcc $(GCCPLUGIN) -S libs/stb/stb_image.c -fplugin-arg-gcclua-script=libs/stb/stb_image.lua > libs/stb/stb_image.nelua
	gcc $(GCCPLUGIN) -S libs/stb/stb_image_write.c -fplugin-arg-gcclua-script=libs/stb/stb_image_write.lua > libs/stb/stb_image_write.nelua
	gcc $(GCCPLUGIN) -S libs/stb/stb_vorbis.c -fplugin-arg-gcclua-script=libs/stb/stb_vorbis.lua > libs/stb/stb_vorbis.nelua
	gcc $(GCCPLUGIN) -S libs/stb/stb_truetype.c -fplugin-arg-gcclua-script=libs/stb/stb_truetype.lua > libs/stb/stb_truetype.nelua
blend2d:
	gcc $(GCCPLUGIN) -S libs/blend2d/blend2d.c -fplugin-arg-gcclua-script=libs/blend2d/blend2d.lua > libs/blend2d/blend2d.nelua
raylib:
	gcc $(GCCPLUGIN) -S libs/raylib/raylib.c -fplugin-arg-gcclua-script=libs/raylib/raylib.lua > libs/raylib/raylib.nelua

download: download-miniaudio download-sokol download-stb
download-miniaudio:
	wget -O libs/miniaudio/miniaudio.h https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h
download-sokol:
	wget -O libs/sokol/sokol_gfx.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_gfx.h
	wget -O libs/sokol/sokol_app.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_app.h
	wget -O libs/sokol/sokol_audio.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_audio.h
	wget -O libs/sokol/sokol_time.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_time.h
	wget -O libs/sokol/sokol_args.h https://raw.githubusercontent.com/floooh/sokol/master/sokol_args.h
download-stb:
	wget -O libs/stb/stb_image.h https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
	wget -O libs/stb/stb_image_write.h https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h
	wget -O libs/stb/stb_vorbis.h https://raw.githubusercontent.com/nothings/stb/master/stb_vorbis.c
	wget -O libs/stb/stb_truetype.h https://raw.githubusercontent.com/nothings/stb/master/stb_truetype.h

test-all: test-lua test-glfw test-sdl2 test-sokol test-miniaudio test-stb
test-all-extra: test-all test-c test-blend2d test-raylib
test-c: c
	cd libs/c && nelua c-test.nelua
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
test-stb: stb
	cd libs/stb && nelua stb-test.nelua
test-blend2d: blend2d
	cd libs/blend2d && nelua blend2d-test.nelua
test-raylib: raylib
	cd libs/raylib && nelua raylib-test.nelua

test-dev:
	gcc $(GCCPLUGIN) -S test/test.c -fplugin-arg-gcclua-script=test/test.lua > test/test.nelua
