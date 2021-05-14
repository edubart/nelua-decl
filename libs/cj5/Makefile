NAME=cj5
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
	wget -O cj5.h https://raw.githubusercontent.com/septag/cj5/master/cj5.h
	# patch some incompatibilities
	sed -i '/sx_unused/d' cj5.h
	sed -i 's/\bend\b/ending/g' cj5.h

test:
	$(NELUA) $(TFILE)
