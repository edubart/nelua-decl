local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sargs_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_ARGS_NO_IMPL then
  cdefine 'SOKOL_ARGS_API_DECL static'
  cdefine 'SOKOL_ARGS_IMPL'
end
cinclude 'sokol_args.h'
]]
]=]
