local nldecl = require 'nldecl'

nldecl.include_names = {
  '^timerfd',
  '^TFD',
--  ipc_perm = true,
}

nldecl.prepend_code = [=[
## cinclude '<sys/timerfd.h>'
]=]
