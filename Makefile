GCCPLUGIN=-fplugin=./gcc-lua/gcc/gcclua.so
CC=gcc
NELUA=nelua

all: lua sdl2 miniaudio sokol stb miniphysfs
all-extra: all c blend2d raylib

c:
	$(CC) $(GCCPLUGIN) -S libs/c/c.c -fplugin-arg-gcclua-script=libs/c/c.lua > libs/c/c.nelua
lua:
	$(CC) $(GCCPLUGIN) -S libs/lua/lua.c -fplugin-arg-gcclua-script=libs/lua/lua.lua > libs/lua/lua.nelua
glfw:
	$(CC) $(GCCPLUGIN) -S libs/glfw/glfw.c -fplugin-arg-gcclua-script=libs/glfw/glfw.lua > libs/glfw/glfw.nelua
sdl2:
	$(CC) $(GCCPLUGIN) -S libs/sdl2/sdl2.c -fplugin-arg-gcclua-script=libs/sdl2/sdl2.lua > libs/sdl2/sdl2.nelua
sokol:
	$(CC) $(GCCPLUGIN) -S libs/sokol/sokol_gfx.c -fplugin-arg-gcclua-script=libs/sokol/sokol_gfx.lua > libs/sokol/sokol_gfx.nelua
	$(CC) $(GCCPLUGIN) -S libs/sokol/sokol_app.c -fplugin-arg-gcclua-script=libs/sokol/sokol_app.lua > libs/sokol/sokol_app.nelua
	$(CC) $(GCCPLUGIN) -S libs/sokol/sokol_audio.c -fplugin-arg-gcclua-script=libs/sokol/sokol_audio.lua > libs/sokol/sokol_audio.nelua
	$(CC) $(GCCPLUGIN) -S libs/sokol/sokol_time.c -fplugin-arg-gcclua-script=libs/sokol/sokol_time.lua > libs/sokol/sokol_time.nelua
	$(CC) $(GCCPLUGIN) -S libs/sokol/sokol_args.c -fplugin-arg-gcclua-script=libs/sokol/sokol_args.lua > libs/sokol/sokol_args.nelua
miniaudio:
	$(CC) $(GCCPLUGIN) -S libs/miniaudio/miniaudio.c -fplugin-arg-gcclua-script=libs/miniaudio/miniaudio.lua > libs/miniaudio/miniaudio.nelua
	$(CC) $(GCCPLUGIN) -S libs/miniaudio/miniaudio_engine.c -fplugin-arg-gcclua-script=libs/miniaudio/miniaudio_engine.lua > libs/miniaudio/miniaudio_engine.nelua
miniphysfs:
	$(CC) $(GCCPLUGIN) -S libs/miniphysfs/miniphysfs.c -fplugin-arg-gcclua-script=libs/miniphysfs/miniphysfs.lua > libs/miniphysfs/miniphysfs.nelua
stb:
	$(CC) $(GCCPLUGIN) -S libs/stb/stb_image.c -fplugin-arg-gcclua-script=libs/stb/stb_image.lua > libs/stb/stb_image.nelua
	$(CC) $(GCCPLUGIN) -S libs/stb/stb_image_write.c -fplugin-arg-gcclua-script=libs/stb/stb_image_write.lua > libs/stb/stb_image_write.nelua
	$(CC) $(GCCPLUGIN) -S libs/stb/stb_vorbis.c -fplugin-arg-gcclua-script=libs/stb/stb_vorbis.lua > libs/stb/stb_vorbis.nelua
	$(CC) $(GCCPLUGIN) -S libs/stb/stb_truetype.c -fplugin-arg-gcclua-script=libs/stb/stb_truetype.lua > libs/stb/stb_truetype.nelua
blend2d:
	$(CC) $(GCCPLUGIN) -S libs/blend2d/blend2d.c -fplugin-arg-gcclua-script=libs/blend2d/blend2d.lua > libs/blend2d/blend2d.nelua
raylib:
	$(CC) $(GCCPLUGIN) -S libs/raylib/raylib.c -fplugin-arg-gcclua-script=libs/raylib/raylib.lua > libs/raylib/raylib.nelua

download: download-sokol download-stb download-miniaudio download-miniphysfs
download-miniaudio:
	wget -O libs/miniaudio/miniaudio.h https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h
	wget -O libs/miniaudio/miniaudio_engine.h https://raw.githubusercontent.com/mackron/miniaudio/master/research/miniaudio_engine.h
download-miniphysfs:
	wget -O libs/miniphysfs/miniphysfs.h https://raw.githubusercontent.com/edubart/miniphysfs/main/miniphysfs.h
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

test-all: test-lua test-glfw test-sdl2 test-sokol test-miniaudio test-miniphysfs test-stb
test-all-extra: test-all test-c test-blend2d test-raylib
test-c: c
	cd libs/c && $(NELUA) c-test.nelua
test-lua: lua
	cd libs/lua && $(NELUA) lua-test.nelua
test-glfw: glfw
	cd libs/glfw && $(NELUA) glfw-test.nelua
test-sdl2: sdl2
	cd libs/sdl2 && $(NELUA) sdl2-test.nelua
test-sokol: sokol
	cd libs/sokol && $(NELUA) sokol-test.nelua
test-miniaudio: miniaudio
	cd libs/miniaudio && $(NELUA) miniaudio-test.nelua pluck.wav
# 	cd libs/miniaudio && $(NELUA) miniaudio-engine-test.nelua pluck.wav
test-miniphysfs: miniphysfs
	cd libs/miniphysfs && $(NELUA) miniphysfs-test.nelua
test-stb: stb
	cd libs/stb && $(NELUA) stb-test.nelua
test-blend2d: blend2d
	cd libs/blend2d && $(NELUA) blend2d-test.nelua
test-raylib: raylib
	cd libs/raylib && $(NELUA) raylib-test.nelua

test-dev:
	gcc $(GCCPLUGIN) -S test/test.c -fplugin-arg-gcclua-script=test/test.lua > test/test.nelua
