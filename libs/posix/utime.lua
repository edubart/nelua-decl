local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.prepend_code = [=[
## cinclude '<utime.h>'
]=]
