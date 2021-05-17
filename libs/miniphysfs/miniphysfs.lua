local nldecl = require 'nldecl'

nldecl.include_names = {
  '^PHYSFS_',
}

nldecl.prepend_code = [=[
##[[
if MINIPHYSFS_LINKLIB then
  if type(MINIPHYSFS_LINKLIB) == 'string' then
    linklib(MINIPHYSFS_LINKLIB)
  end
else
  cdefine 'PHYSFS_DECL static'
  cdefine 'PHYSFS_IMPL'
  cdefine 'PHYSFS_PLATFORM_IMPL'
end
cinclude 'miniphysfs.h'
]]
]=]
