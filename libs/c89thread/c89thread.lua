local nldecl = require 'nldecl'

nldecl.include_names = {
  '^c89',
  '^C89',
  timespec = true,
  c89thrd_t = true,
}

nldecl.platform_names = {
  c89mtx_t = nldecl.OMIT_ALL_FIELDS,
  c89cnd_t = nldecl.OMIT_ALL_FIELDS,
  c89sem_t = nldecl.OMIT_ALL_FIELDS,
  c89evnt_t = nldecl.OMIT_ALL_FIELDS,
  c89thrd_t = nldecl.OMIT_ALL_FIELDS,
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
cinclude '"c89thread.h"'
if ccinfo.is_linux then
  linklib 'pthread'
end
]]
]=]
