local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sgp_',
  '^SGP_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_GP_NO_IMPL then
  cdefine 'SOKOL_GP_API_DECL static'
  cdefine 'SOKOL_GP_IMPL'
end
cinclude 'sokol_gp.h'
]]
]=]
