NAME=mjson
CFILE=$(NAME)-api.c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc -Wall -Wextra

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S $(CFILE) -fplugin-arg-gcclua-script=$(LFILE) > $(NFILE)

download:
	wget -O mjson.h https://github.com/cesanta/mjson/raw/master/src/mjson.h
	wget -O mjson.c https://github.com/cesanta/mjson/raw/master/src/mjson.c

test:
	$(NELUA) $(TFILE)
