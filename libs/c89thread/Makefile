GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc -Wall -Wextra

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S c89thread.c -fplugin-arg-gcclua-script=c89thread.lua > c89thread.nelua

download:
	wget -O c89thread.h https://raw.githubusercontent.com/mackron/c89thread/master/c89thread.h
	wget -O c89atomic.h https://raw.githubusercontent.com/mackron/c89atomic/master/c89atomic.h

test:
	$(NELUA) c89thread-test.nelua
	$(NELUA) c89atomic-test.nelua
