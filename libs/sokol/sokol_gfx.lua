local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sg_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_GFX_NO_IMPL then
  cdefine 'SOKOL_GFX_API_DECL static'
  cdefine 'SOKOL_GFX_IMPL'
end
if ccinfo.is_emscripten then
  cdefine 'SOKOL_GLES2'
else
  cdefine 'SOKOL_GLCORE33'
end
cinclude 'sokol_gfx.h'
if ccinfo.is_windows then
  linklib 'gdi32'
  linklib 'opengl32'
else
  linklib 'GL'
end
]]
]=]
