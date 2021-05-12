local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.include_macros = {
  cint = {
    '^POLL'
  },
}

nldecl.prepend_code = [=[
## cinclude '<poll.h>'
]=]
