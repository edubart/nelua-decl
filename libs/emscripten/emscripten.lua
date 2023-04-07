local nldecl = require 'nldecl'

nldecl.include_names = {
  '^emscripten',
  '^em_',
  FILE = true,
  _em_promise = true
}

nldecl.prepend_code = [=[
##[[
cinclude '<emscripten.h>'
]]
]=]
