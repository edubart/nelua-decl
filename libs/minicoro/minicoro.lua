local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MCO_',
  '^mco_',
}

nldecl.prepend_code = [=[
##[[
cdefine 'MINICORO_IMPL'
cinclude '"minicoro.h"'
]]
]=]

nldecl.append_code = [[
]]
