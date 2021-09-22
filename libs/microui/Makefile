NAME=microui
CFILE=$(NAME)-api.c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S $(CFILE) -fplugin-arg-gcclua-script=$(LFILE) > $(NFILE)

download:
	wget -O microui.c https://raw.githubusercontent.com/rxi/microui/master/src/microui.c
	wget -O microui.h https://raw.githubusercontent.com/rxi/microui/master/src/microui.h

test:
	$(NELUA) microui-test.nelua
