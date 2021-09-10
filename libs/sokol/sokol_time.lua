local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stm_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_TIME_NO_IMPL then
  cdefine 'SOKOL_TIME_API_DECL static'
  cdefine 'SOKOL_TIME_IMPL'
end
cinclude 'sokol_time.h'
]]
]=]
