local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
  '^opt',
}

nldecl.prepend_code = [=[
## cinclude '<unistd.h>'
]=]
