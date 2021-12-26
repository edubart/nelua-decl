local nldecl = require 'nldecl'

nldecl.include_names = {
  '^c89',
  '^C89',
  timespec = true,
}

nldecl.opaque_names = {
  c89mtx_t = true,
  c89cnd_t = true,
  c89sem_t = true,
  c89evnt_t = true,
  c89thrd_t = true,
}

nldecl.prepend_code = [=[
##[[
if not C89THREAD_NO_IMPL then
  cdefine 'C89THREAD_IMPLEMENTATION'
end
cdefine 'C89THREAD_NO_PTHREAD_IN_HEADER'
cinclude 'c89thread.h'
if ccinfo.is_linux then
  cflags '-pthread'
end
]]
]=]
