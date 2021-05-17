local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MCO_',
  '^mco_',
}

nldecl.prepend_code = [=[
##[[
if MINICORO_LINKLIB then
  if type(MINICORO_LINKLIB) == 'string' then
    linklib(MINICORO_LINKLIB)
  end
else
  cdefine 'MCO_API static'
  cdefine 'MINICORO_IMPL'
end
cinclude 'minicoro.h'
]]
]=]

nldecl.append_code = [[
]]
