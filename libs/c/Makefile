NAME=c
CFILE=$(NAME).c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc
CSTD=-std=c2x

generate:
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S $(CFILE) -fplugin-arg-gcclua-script=$(LFILE) > $(NFILE)

download:
	# should be in the system

test:
	$(NELUA) $(TFILE)
