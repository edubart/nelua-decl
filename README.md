C binding generator for [Nelua](https://nelua.io/)
using [GCC Lua plugin](https://peter.colberg.org/gcc-lua).

This tool assists creating C bindings for any C library
for Nelua in a few steps, also enables the possibility to customize
each library bindings via Lua scripts. Requires GCC to run.

**Note: You need GCC plugin mechanism to use this (only available in Linux systems).**

## Bindings example

The following cross-platform libraries bindings are ready and generated as example:

* [SDL2](https://www.libsdl.org/)
    - [sdl2.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sdl2/sdl2.nelua)
    - [sdl2_image.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sdl2/sdl2_image.nelua)
    - [sdl2_mixer.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sdl2/sdl2_mixer.nelua)
    - [sdl2_ttf.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sdl2/sdl2_ttf.nelua)
* [GLFW](https://www.glfw.org/)
    - [glfw.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/glfw/glfw.nelua) (Cross platform OpenGL/Vullkan framework)
* [minilua](https://github.com/edubart/minilua) (Lua)
    - [lua.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/minilua/minilua.nelua) (Lua scripting language)
* [minicoro](https://github.com/edubart/minicoro)
    - [minicoro.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/minicoro/minicoro.nelua) (Cross platform coroutine library)
* [miniaudio](https://miniaud.io/)
    - [miniaudio.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/miniaudio/miniaudio.nelua) (Cross platform low level audio API)
    - [miniaudio_engine.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/miniaudio/miniaudio_engine.nelua) (Cross platform high level audio API)
* [miniphysfs](https://github.com/edubart/miniphysfs) (PhysFS)
    - [miniphysfs.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/miniphysfs/miniphysfs.nelua) (Cross platform archive filesystem)
* [STB](https://github.com/nothings/stb)
    - [stb_image.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/stb/stb_image.nelua) (Read images)
    - [stb_image_write.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/stb/stb_image_write.nelua) (Write images)
    - [stb_truetype.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/stb/stb_truetype.nelua) (Read TTF font files)
    - [stb_vorbis.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/stb/stb_vorbis.nelua) (Read OGG sound files)
* [Sokol](https://floooh.github.io/sokol-html5/index.html)
    - [sokol_app.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_app.nelua) (Cross platform window application)
    - [sokol_args.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_args.nelua) (Cross platform command line arguments parser)
    - [sokol_audio.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_audio.nelua) (Cross platform low level audio)
    - [sokol_gfx.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_gfx.nelua) (Cross platform graphics API)
    - [sokol_glue.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_glue.nelua)
    - [sokol_time.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/sokol/sokol_time.nelua) (Cross platform time utilities)
* [Blend2D](https://blend2d.com/)
    - [blend2d.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/blend2d/blend2d.nelua) (2D vector graphics engine)
* [Chipmunk](https://chipmunk-physics.net/)
    - [chipmunk.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/chipmunk/chipmunk.nelua) (2D physics library)
* [Raylib](https://www.raylib.com/)
    - [raylib.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/raylib/raylib.nelua) (Simple library for creating games)
* [libuv](https://libuv.org/)
    - [uv.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/uv/uv.nelua) (Cross-platform asynchronous I/O)
* [enet](https://github.com/zpl-c/enet)
    - [enet.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/enet/enet.nelua) (Reliable UDP networking library)

Plus the following platform specific libraries:
* dl
    - [dl.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/dl/dl.nelua) (Unix dynamic library loader)
* [pthread](https://computing.llnl.gov/tutorials/pthreads/)
    - [pthread.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/pthread/pthread.nelua) (POSIX threads)
* [POSIX](https://en.wikipedia.org/wiki/POSIX)
    - [unistd.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/unistd.nelua) (Essential POSIX functions)
    - [dirent.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/dirent.nelua) (Directory control options)
    - [errno.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/errno.nelua) (Error handling)
    - [fcntl.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/fcntl.nelua) (File control options)
    - [signal.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/signal.nelua) (Signal handling)
    - [termios.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/termios.nelua) (Manipulate terminal I/O)
    - [time.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/time.nelua) (Date and time)
    - [sys/stat.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/posix/sys/stat.nelua) (File attributes)
    - And some other POSIX APIs, check [the directory](https://github.com/edubart/nelua-decl/blob/main/libs/posix/)
* linux
    - [inotify.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/linux/inotify.nelua) (Linux filesystem watcher)
    - [epoll.nelua](https://github.com/edubart/nelua-decl/blob/main/libs/linux/epoll.nelua) (Linux I/O event notification facility)


## How to generate bindings

Make sure you are using Lua 5.3+, GCC 9+ and have GCC plugin installed.

First clone and compile the `gcc-lua` plugin and compile it:

```bash
git clone --recurse-submodules https://github.com/edubart/nelua-decl.git
make -C gcc-lua
```

Some libraries such as SDL2, GLFW must be installed on your system.

To generate bindings for a library simply do `make generate` in its folder.
For example, the following will generate `libs/sdl2/sdl2.nelua` and
then run a test to check if it's working:

```sh
cd libs/sdl2
make generate
make test
```

Some single header libraries you must be downloaded with `make download`, for example:

```sh
cd libs/minilua
make download
make generate
make test
```

## How to generate bindings for a new library

Suppose you want generate bindings for `mylib`, create a new folder `mylib` in `libs/`,
then you must create the following files:

* mylib.c - A C file including all C headers that have the functions we want to bind.
* mylib.lua - A lua file with binding generator rules.
* Makefile - A Makefile script to assist generating the bindings.

For a quick start, see the `Makefile`, `.lua` and `.c` files of the current
bundled libraries as an example.

## How it works

The bindings are generated using the following command:

```bash
gcc -S libs/lua/lua.c \
    -fplugin=./gcc-lua/gcc/gcclua.so \
    -fplugin-arg-gcclua-script=libs/lua/lua.lua \
    > libs/lua/lua.nelua
```

Command explanation:

* `-S libs/lua/lua.c` tells GCC to compile only the assembly instructions for the file, this is sufficient for parsing.
* `-fplugin=./gcc-lua/gcc/gcclua.so` tells GCC to load the gcc-lua plugin before compiling.
* `-fplugin-arg-gcclua-script=libs/lua/lua.lua` is the lua script loaded with configurations to generate the bindings.
* `libs/lua/lua.nelua` is the output file.


## Caveats

Some limitations:

* C bit fields are not supported.
* C unnamed fields are not supported.
* C math complex type is not supported.
* C macros are hidden and requires some manual work to expose them.
* Currently GCC plugin does not work on Windows, thus you have to generate bindings from a Linux machine.

Usually to create bindings for a new library requires little manual work for C libraries
that are binding friendly to other languages.
A binding friendly C libraries have the following characteristics:

* No use of platform dependent function declarations, constants and structs in its API.
* Constants are declared as enums instead of macros.
* Functions are declared as C functions and not macros.
* It doesn't use unnamed fields.
* It doesn't use bit fields.
