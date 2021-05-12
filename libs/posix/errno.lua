local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.include_macros = {
  cint = {
    '^E',
  },
}

nldecl.prepend_code = [=[
## cinclude '<errno.h>'
global errno: cint <cimport, nodecl>
]=]
