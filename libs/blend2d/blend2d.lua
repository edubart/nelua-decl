local nldecl = require 'nldecl'

nldecl.include_names = {
  '^bl',
  '^BL',
  BLResult = true
}

nldecl.prepend_code = [=[
##[[
cinclude '<blend2d.h>'
linklib 'blend2d'
]]
]=]
