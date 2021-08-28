local nldecl = require 'nldecl'

nldecl.include_names = {
  '^cj5',
}

nldecl.prepend_code = [=[
##[[
if not CJ5_NO_IMPL then
  cdefine 'CJ5_API static'
  cdefine 'CJ5_IMPLEMENT'
end
cinclude 'cj5.h'
]]
]=]
