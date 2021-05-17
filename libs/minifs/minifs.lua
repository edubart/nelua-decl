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
if MINIFS_LINKLIB then
  if type(MINIFS_LINKLIB) == 'string' then
    linklib(MINIFS_LINKLIB)
  end
else
  cdefine 'MINIFS_IMPLEMENTATION'
end
cinclude 'minifs.h'
]]
]=]
