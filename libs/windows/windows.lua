local nldecl = require 'nldecl'

nldecl.include_names = {
  '[A-Z]',
  val_context = true,
  BOOL = true,
  BOOLEAN = true,
}

nldecl.exclude_names = {
  '^__'
}

nldecl.prepend_code = [=[
##[[
cinclude '<windows.h>'
]]
]=]


