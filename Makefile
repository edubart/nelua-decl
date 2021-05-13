MKC=$(MAKE) --no-print-directory -C

generate:
	$(MKC) libs/blend2d generate
	$(MKC) libs/chipmunk generate
	$(MKC) libs/glfw generate
	$(MKC) libs/miniaudio generate
	$(MKC) libs/minicoro generate
	$(MKC) libs/minilua generate
	$(MKC) libs/miniphysfs generate
	$(MKC) libs/raylib generate
	$(MKC) libs/sdl2 generate
	$(MKC) libs/sokol generate
	$(MKC) libs/stb generate
	$(MKC) libs/uv generate
	$(MKC) libs/enet generate
	$(MKC) libs/dmon generate
	$(MKC) libs/znet generate

	$(MKC) libs/c generate
	$(MKC) libs/dl generate
	$(MKC) libs/pthread generate
	$(MKC) libs/posix generate
	$(MKC) libs/linux generate

download:
	$(MKC) libs/blend2d download
	$(MKC) libs/chipmunk download
	$(MKC) libs/glfw download
	$(MKC) libs/miniaudio download
	$(MKC) libs/minicoro download
	$(MKC) libs/minilua download
	$(MKC) libs/miniphysfs download
	$(MKC) libs/raylib download
	$(MKC) libs/sdl2 download
	$(MKC) libs/sokol download
	$(MKC) libs/stb download
	$(MKC) libs/uv download
	$(MKC) libs/enet download
	$(MKC) libs/dmon download
	$(MKC) libs/znet download

	$(MKC) libs/c download
	$(MKC) libs/dl download
	$(MKC) libs/pthread download
	$(MKC) libs/posix download
	$(MKC) libs/linux download

test:
	$(MKC) libs/blend2d test
	$(MKC) libs/chipmunk test
	$(MKC) libs/glfw test
	$(MKC) libs/miniaudio test
	$(MKC) libs/minicoro test
	$(MKC) libs/minilua test
	$(MKC) libs/miniphysfs test
	$(MKC) libs/raylib test
	$(MKC) libs/sdl2 test
	$(MKC) libs/sokol test
	$(MKC) libs/stb test
	$(MKC) libs/uv test
	$(MKC) libs/enet test
	$(MKC) libs/dmon test
	$(MKC) libs/znet test

	$(MKC) libs/c test
	$(MKC) libs/dl test
	$(MKC) libs/pthread test
	$(MKC) libs/posix test
	$(MKC) libs/linux test

	echo "All tests OK!"
