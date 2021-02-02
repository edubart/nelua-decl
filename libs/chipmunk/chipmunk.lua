local nldecl = require 'nldecl'

nldecl.include_names = {
  '^cp[A-Z]',
  '^CP_',
}

nldecl.prepend_code = [=[
##[[
cinclude '<chipmunk/chipmunk.h>'
linklib 'chipmunk'
if ccinfo.is_linux then
  linklib 'pthread'
end
]]
]=]
