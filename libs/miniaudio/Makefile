GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S miniaudio.c -fplugin-arg-gcclua-script=miniaudio.lua > miniaudio.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S miniaudio_engine.c -fplugin-arg-gcclua-script=miniaudio_engine.lua > miniaudio_engine.nelua

download:
	wget -O miniaudio.h https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h
	wget -O miniaudio_engine.h https://raw.githubusercontent.com/mackron/miniaudio/master/research/miniaudio_engine.h

test:
	$(NELUA) miniaudio-test.nelua pluck.wav
	$(NELUA) miniaudio_engine-test.nelua pluck.wav
