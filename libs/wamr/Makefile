NAME=wamr
CFILE=$(NAME)-api.c
LFILE=$(NAME).lua
NFILE=$(NAME).nelua
TFILE=$(NAME)-test.nelua
GCCPLUGIN=-fplugin=../../gcc-lua/gcc/gcclua.so
LUA_PATH=LUA_PATH_5_4="../../?.lua;;" LUA_PATH_5_3="../../?.lua;;" LUA_PATH="../../?.lua;;"
NELUA=nelua
CC=gcc -Wall -Wextra -I"$(WAMR_SDK_PATH)/runtime-sdk/include"
WASI_CC=$(WASI_SDK_PATH)/bin/clang

generate:
	$(LUA_PATH) $(CC) $(GCCPLUGIN) -S $(CFILE) -fplugin-arg-gcclua-script=$(LFILE) > $(NFILE)

download:
	wget -O wasm_export.h https://raw.githubusercontent.com/bytecodealliance/wasm-micro-runtime/main/core/iwasm/include/wasm_export.h
	wget -O wasm_c_api.h https://raw.githubusercontent.com/bytecodealliance/wasm-micro-runtime/main/core/iwasm/include/wasm_c_api.h
	wget -O lib_export.h https://raw.githubusercontent.com/bytecodealliance/wasm-micro-runtime/main/core/iwasm/include/lib_export.h

test:
	$(NELUA) --cc="$(WASI_CC)" hello.nelua -o hello.wasm
	$(NELUA) $(TFILE)
