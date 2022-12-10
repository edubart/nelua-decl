package.path = '../../?.lua;'..package.path
local nldecl = require 'nldecl'

nldecl.include_names = {
  '^rpng_',
}

nldecl.prepend_code = [=[
##[[
if not RPNG_NO_IMPL then
  cdefine 'RPNG_IMPLEMENTATION'
end
cinclude 'rpng.h'
]]
]=]
