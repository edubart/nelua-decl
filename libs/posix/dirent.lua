local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.prepend_code = [=[
## cinclude '<dirent.h>'
]=]
