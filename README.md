C binding generator for Nelua using [GCC Lua plugin](https://peter.colberg.org/gcc-lua).

This tool assists creating C bindings for any C library
for Nelua in a quick steps, possibility customizing
each library via Lua scripts. Requires GCC to run.

**Note: This is under development, thus it does not work on some corner cases yet.**

## Usage

Make sure you are using Lua 5.3+ and GCC 9+.
First clone and compile the `gcc-lua` plugin and compile it:

```bash
git clone --recurse-submodules https://github.com/edubart/nelua-decl.git
make -C gcc-lua
```

Now you can compile bindings with the following command:

```bash
gcc -S libs/lua/lua.c \
    -fplugin=./gcc-lua/gcc/gcclua.so \
    -fplugin-arg-gcclua-script=libs/lua/lua.lua \
    > libs/lua/lua.nelua
```

Command explanation:
* `-S libs/lua/lua.c` tells GCC to compile only the assembly instructions for the file, this is sufficient for parsing
* `-fplugin=./gcc-lua/gcc/gcclua.so` tells GCC to load the gcc-lua plugin before compiling
* `-fplugin-arg-gcclua-script=libs/lua/lua.lua` is the lua script loaded with configurations to generate the bindings
* `libs/lua/lua.nelua` is the output file

## Bindings example

The following libraries bindings are generated as example:

* [Lua 5.4](https://www.lua.org/) - [lua.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/lua/lua.nelua)
* [SDL2](https://www.libsdl.org/) - [sdl2.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sdl2/sdl2.nelua)
* [GLFW](https://www.glfw.org/) - [glfw.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/glfw/glfw.nelua)
* [Sokol](https://floooh.github.io/sokol-html5/index.html) - [sokol_gfx.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_gfx.nelua) - [sokol_app.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_app.nelua) - [sokol_glue.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_glue.nelua)
* [miniaudio](https://github.com/mackron/miniaudio) - [miniaudio.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/miniaudio/miniaudio.nelua)

## How to generate bindings

Some libraries such as SDL2, GLFW and Lua
must be installed on your system.
Other libraries like Sokol and miniaudio must be
downloaded with `make download`.

To generate bindings for them simply do `make sdl2`
and `libs/sdl2/sdl2.nelua` will be generated for example.

## Tests

Some tests are present as examples on how to use
the libraries, you can run the as long you
have the library headers on your system. Look
for example the `libs/sdl2/sdl2-test.nelua` file.

## Todo

* Import macro constants
* Support unions
* Support bitfields
* Support unnamed fields
* Support C va_list