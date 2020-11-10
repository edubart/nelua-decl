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
nldecl.exclude_filters = {
  '^GL_VERSION_',
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

  -- TODO: handle better these constants
  GL_TIMEOUT_IGNORED = true,
  GL_INVALID_INDEX = true,
  GL_ALL_ATTRIB_BITS = true,
  GL_ALL_CLIENT_ATTRIB_BITS = true,
  GL_CLIENT_ALL_ATTRIB_BITS = true,
  GL_QUERY_ALL_EVENT_BITS_AMD = true,
  GL_ALL_BARRIER_BITS_EXT = true,
  GL_ALL_SHADER_BITS = true,
  GL_ALL_BARRIER_BITS = true,
  GL_ALL_PIXELS_AMD = true,
}
nldecl.macro_filters = {
  cint = {
    '^GLFW_',
    '^GL_[A-Z_]+$'
  },
}
nldecl.include_macros = {
  cint = {
    GLFW_VERSION_MAJOR = false,
    GLFW_VERSION_MINOR = false,
    GLFW_VERSION_REVISION = false,
  },
}
