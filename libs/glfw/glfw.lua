local nldecl = require 'nldecl'

nldecl.include_names = {
  '^gl',
  '^GL',
  '^glfw',
  '^GLFW',
}

nldecl.exclude_names = {
  '^GL_VERSION_',
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

nldecl.include_macros = {
  cint = {
    '^GLFW_',
    '^GL_[A-Z_]+$',
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
