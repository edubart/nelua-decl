local nldecl = require 'nldecl'

nldecl.include_names = {
  '^glfw',
  '^GLFW',
}

nldecl.exclude_names = {
  GLFWvkproc = true,
}

nldecl.include_macros = {
  cint = {
    '^GLFW_',
    GLFW_VERSION_MAJOR = false,
    GLFW_VERSION_MINOR = false,
    GLFW_VERSION_REVISION = false,
  },
}

nldecl.prepend_code = [=[
##[[
cinclude '<GLFW/glfw3.h>'
if ccinfo.is_windows then
  linklib 'glfw3'
  linklib 'opengl32'
  linklib 'gdi32'
  linklib 'user32'
  linklib 'kernel32'
else
  linklib 'glfw'
  linklib 'GL'
end
]]
]=]
