local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^sg_',
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_GLCORE33'
cdefine 'SOKOL_IMPL'
cinclude '"sokol_gfx.h"'
]]
]=]
