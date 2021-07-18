local nldecl = require 'nldecl'

nldecl.include_names = {
  '^pthread',
  sched_param = true,
  timespec = true,
  pthread_t = true,
}

nldecl.prepend_code = [=[
## cinclude '<pthread.h>'
## cflags '-pthread'
]=]
