local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MCO_',
  '^mco_',
}

nldecl.prepend_code = [=[
##[[
if not MINICORO_NO_IMPL then
  cdefine 'MCO_API static'
  cdefine 'MINICORO_IMPL'
end
cinclude 'minicoro.h'
]]
]=]
