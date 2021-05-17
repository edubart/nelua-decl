local nldecl = require 'nldecl'

nldecl.include_names = {
  '^cj5',
}

nldecl.prepend_code = [=[
##[[
if CJ5_LINKLIB then
  if type(CJ5_LINKLIB) == 'string' then
    linklib(CJ5_LINKLIB)
  end
else
  cdefine 'CJ5_API static'
  cdefine 'CJ5_IMPLEMENT'
end
cinclude 'cj5.h'
]]
]=]
