local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MFS_',
  '^mfs_',
  FILE = true,
}

nldecl.include_macros = {
  cint = {
    '^MFS_'
  }
}

nldecl.prepend_code = [=[
##[[
if not MINIFS_NO_IMPL then
  cdefine 'MINIFS_IMPLEMENTATION'
end
cinclude 'minifs.h'
]]
]=]
