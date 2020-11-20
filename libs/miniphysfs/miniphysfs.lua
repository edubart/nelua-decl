local nldecl = require 'nldecl'

nldecl.include_names = {
  '^PHYSFS_',
}

nldecl.exclude_names = {
}

nldecl.include_macros = {
}

nldecl.prepend_code = [=[
##[[
cdefine 'PHYSFS_IMPL'
cdefine 'PHYSFS_PLATFORM_IMPL'
cinclude '"miniphysfs.h"'
]]
]=]
