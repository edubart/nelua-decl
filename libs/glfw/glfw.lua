local nldecl = require 'nldecl'

nldecl.prepend_code = [=[
##[[
linklib 'glfw'
linklib 'GL'
cinclude '<GLFW/glfw3.h>'
]]
]=]

nldecl.include_filters = {
  '^gl',
  '^GL',
  '^glfw',
  '^GLFW',
}
nldecl.exclude_names = {
  GLFWvkproc = true,
  GLsync = true,
  GLDEBUGPROC = true,
  GLDEBUGPROCARB = true,
  GLDEBUGPROCAMD = true,
  GLeglImageOES = true,
  GLeglClientBufferEXT = true,
  GLVULKANPROCNV = true,
}
