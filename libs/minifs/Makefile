NAME=minifs
CFILE=$(NAME).c
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
	wget -O minifs.h https://raw.githubusercontent.com/mackron/minifs/master/minifs.h

test:
	$(NELUA) $(TFILE)
