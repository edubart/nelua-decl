local nldecl = require 'nldecl'

nldecl.include_names = {
  '^[A-Z]',
  '^[A-Z]',
}

nldecl.prepend_code = [=[
##[[
linklib 'binaryen'
cinclude '<binaryen-c.h>'
if ccinfo.is_linux then
  linklib 'pthread'
end
]]
]=]
