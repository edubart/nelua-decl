local nldecl = require 'nldecl'

nldecl.include_names = {
  '^wait',
  idtype_t = true,
  siginfo_t = true,
  __sigval_t = true,
}

nldecl.prepend_code = [=[
## cinclude '<sys/wait.h>'
]=]
