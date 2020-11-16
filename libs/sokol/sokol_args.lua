local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sargs_',
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_IMPL'
cinclude '"sokol_args.h"'
]]
]=]
