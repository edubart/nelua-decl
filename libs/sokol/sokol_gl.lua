local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sgl_',
}

nldecl.prepend_code = [=[
##[[
if SOKOL_GL_LINKLIB then
  if type(SOKOL_GL_LINKLIB) == 'string' then
    linklib(SOKOL_GL_LINKLIB)
  end
else
  cdefine 'SOKOL_GL_API_DECL static'
  cdefine 'SOKOL_GL_IMPL'
end
cinclude 'sokol_gl.h'
]]
]=]
