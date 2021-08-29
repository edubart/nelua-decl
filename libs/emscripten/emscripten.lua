local nldecl = require 'nldecl'

nldecl.include_names = {
  '^emscripten',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cinclude '<emscripten.h>'
]]
]=]
