NAME=webview
CFILE=$(NAME)-api.c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc -Wall -Wextra `pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S $(CFILE) -fplugin-arg-gcclua-script=$(LFILE) > $(NFILE)

download:
	wget -O webview.h https://raw.githubusercontent.com/edubart/webview-c/master/webview.h
	wget -O webview-cocoa.c https://raw.githubusercontent.com/edubart/webview-c/master/webview-cocoa.c
	wget -O webview-gtk.c https://raw.githubusercontent.com/edubart/webview-c/master/webview-gtk.c
	wget -O webview-win32.c https://raw.githubusercontent.com/edubart/webview-c/master/webview-win32.c
	wget -O webview-ms-webview2.h https://raw.githubusercontent.com/edubart/webview-c/master/webview-ms-webview2.h

test:
	$(NELUA) $(TFILE)
