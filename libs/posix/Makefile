NAME=posix
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc
CSTD=-std=c11 -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700

default: generate

download:
	# should be in the system

test:
	$(NELUA) posix-test.nelua

generate:
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S dirent.c -fplugin-arg-gcclua-script=dirent.lua > dirent.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S errno.c -fplugin-arg-gcclua-script=errno.lua > errno.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S fcntl.c -fplugin-arg-gcclua-script=fcntl.lua > fcntl.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S poll.c -fplugin-arg-gcclua-script=poll.lua > poll.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S signal.c -fplugin-arg-gcclua-script=signal.lua > signal.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S termios.c -fplugin-arg-gcclua-script=termios.lua > termios.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S time.c -fplugin-arg-gcclua-script=time.lua > time.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S utime.c -fplugin-arg-gcclua-script=utime.lua > utime.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S unistd.c -fplugin-arg-gcclua-script=unistd.lua > unistd.nelua

	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S sys/socket.c -fplugin-arg-gcclua-script=sys/socket.lua > sys/socket.nelua
	$(LUA_PATH) $(CC) $(CSTD) $(GCCPLUGIN) -S sys/stat.c -fplugin-arg-gcclua-script=sys/stat.lua > sys/stat.nelua
