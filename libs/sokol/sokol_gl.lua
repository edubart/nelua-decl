local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sgl_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_GL_NO_IMPL then
  cdefine 'SOKOL_GL_API_DECL static'
  cdefine 'SOKOL_GL_IMPL'
end
cinclude 'sokol_gl.h'
]]
]=]
