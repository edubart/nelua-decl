local nldecl = require 'nldecl'

nldecl.include_names = {
  '^dl',
  '^Dl',
  '^RTLD',
  link_map = true,
}

nldecl.include_macros = {
  cint = {
    RTLD_LAZY = true,
    RTLD_NOW = true,
    RTLD_BINDING_MASK = true,
    RTLD_NOLOAD = true,
    RTLD_DEEPBIND = true,
    RTLD_GLOBAL = true,
    RTLD_LOCAL = true,
    RTLD_NODELETE = true,
  },
  pointer = {
    RTLD_NEXT = true,
    RTLD_DEFAULT = true,
  }
}

nldecl.prepend_code = [=[
##[[
cdefine '_GNU_SOURCE'
cinclude '<dlfcn.h>'
if ccinfo.is_linux then
  linklib 'dl'
end
]]
]=]
