GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc
CSTD=-std=gnu11 -D_GNU_SOURCE

default: generate

download:
	# should be in the system

test:
	$(NELUA) linux-test.nelua

generate:
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S errno.c -fplugin-arg-gcclua-script=errno.lua > errno.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S inotify.c -fplugin-arg-gcclua-script=inotify.lua > inotify.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S epoll.c -fplugin-arg-gcclua-script=epoll.lua > epoll.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S iouring.c -fplugin-arg-gcclua-script=iouring.lua > iouring.nelua
