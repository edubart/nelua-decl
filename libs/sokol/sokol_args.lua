local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sargs_',
}

nldecl.prepend_code = [=[
##[[
if SOKOL_ARGS_LINKLIB then
  if type(SOKOL_ARGS_LINKLIB) == 'string' then
    linklib(SOKOL_ARGS_LINKLIB)
  end
else
  cdefine 'SOKOL_ARGS_API_DECL static'
  cdefine 'SOKOL_ARGS_IMPL'
end
cinclude '"sokol_args.h"'
]]
]=]
