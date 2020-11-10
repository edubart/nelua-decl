local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^stm_',
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_IMPL'
cinclude '"sokol_time.h"'
]]
]=]
