local nldecl = require 'nldecl'

nldecl.include_names = {
  '^PHYSFS_',
}

nldecl.prepend_code = [=[
##[[
if not MINIPHYSFS_NO_IMPL then
  cdefine 'PHYSFS_DECL static'
  cdefine 'PHYSFS_IMPL'
  cdefine 'PHYSFS_PLATFORM_IMPL'
end
cinclude 'miniphysfs.h'
]]
]=]
