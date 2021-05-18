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
if C89THREAD_LINKLIB then
  if type(C89THREAD_LINKLIB) == 'string' then
    linklib(C89THREAD_LINKLIB)
  end
else
  cdefine 'C89THREAD_IMPLEMENTATION'
end
cinclude 'c89thread.h'
if ccinfo.is_linux then
  linklib 'pthread'
end
]]
]=]
