local nldecl = require 'nldecl'

nldecl.include_names = {
  '^subprocess',
  FILE = true,
}

nldecl.prepend_code = [=[
## cinclude '"subprocess.h"'
]=]
