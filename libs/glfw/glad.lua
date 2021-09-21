local nldecl = require 'nldecl'

nldecl.include_names = {
  '^GL_',
  '^GLAD_',
  '^glad',
  GLsync = true,
  __GLsync = true,
}

nldecl.include_macros = {
  uint64 = {
    GL_TIMEOUT_IGNORED = true,
  },
  cuint = {
    '^GL_',
  },
}

nldecl.prepend_code = [=[
##[[
cinclude 'glad.h'
cfile 'glad.c'
if ccinfo.is_linux then
  linklib 'dl'
end
]]
]=]

function nldecl.on_finish()
  local code = nldecl.emitter:generate()
  code = code:gsub('global glad_', 'global ')
  io.stdout:write(code)
  io.stdout:flush()
end
