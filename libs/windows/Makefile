NAME=windows
CFILE=$(NAME).c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc

generate:
	x86_64-w64-mingw32-gcc -E -dD windows.c > windows-preprocessed.h
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S windows-preprocessed.c -fplugin-arg-gcclua-script=$(LFILE) > windows.nelua

download:

test:
	$(NELUA) --cc=x86_64-w64-mingw32-gcc $(TFILE)
