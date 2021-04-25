GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S stb_image.c -fplugin-arg-gcclua-script=stb_image.lua > stb_image.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S stb_image_write.c -fplugin-arg-gcclua-script=stb_image_write.lua > stb_image_write.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S stb_truetype.c -fplugin-arg-gcclua-script=stb_truetype.lua > stb_truetype.nelua
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S stb_vorbis.c -fplugin-arg-gcclua-script=stb_vorbis.lua > stb_vorbis.nelua

download:
	wget -O stb_image.h https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
	wget -O stb_image_write.h https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h
	wget -O stb_vorbis.h https://raw.githubusercontent.com/nothings/stb/master/stb_vorbis.c
	wget -O stb_truetype.h https://raw.githubusercontent.com/nothings/stb/master/stb_truetype.h

test:
	$(NELUA) stb-test.nelua
