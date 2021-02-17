local nldecl = require 'nldecl'

nldecl.include_names = {
  '^__pthread',
  '^pthread',
  __cancel_jmp_buf_tag = true,
  sched_param = true,
  timespec = true,
  pthread_t = true,
}

nldecl.prepend_code = [=[
## cinclude '<pthread.h>'
## linklib 'pthread'
]=]
