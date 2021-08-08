local nldecl = require 'nldecl'

nldecl.include_names = {
  '^shm',
  ipc_perm = true,
}

nldecl.prepend_code = [=[
## cinclude '<sys/shm.h>'
]=]
