local nldecl = require 'nldecl'

nldecl.include_names = {
  '^uv_[a-z]',
  '^UV_[A-Z]',
  uv__io_t = true,
  uv__io_s = true,
  uv__io_cb = true,
  uv__work = true,
  addrinfo = true,
  sockaddr = true,
  sockaddr_storage = true,
  FILE = true,
  DIR = true,
  termios = true,
  sockaddr_in = true,
  sockaddr_in6 = true,
  in_addr = true,
  in6_addr = true,
}

nldecl.include_macros = {
}

nldecl.prepend_code = [=[
##[[
cinclude '<uv.h>'
linklib 'uv'
]]
## if ccinfo.is_windows then
--TODO
## else
global __pthread_internal_list: type <cimport, nodecl, ctypedef> = @record{
  __prev: *__pthread_internal_list,
  __next: *__pthread_internal_list
}
global __pthread_list_t: type = @__pthread_internal_list
global __pthread_mutex_s: type <cimport, nodecl, ctypedef> = @record{
  __lock: cint,
  __count: cuint,
  __owner: cint,
  __nusers: cuint,
  __kind: cint,
  __spins: cshort,
  __elision: cshort,
  __list: __pthread_list_t
}
global __pthread_cond_s: type <cimport, nodecl, ctypedef> = @record{
  __unnamed1: union{
    __wseq: culonglong,
    __wseq32: record{
      __low: cuint,
      __high: cuint
    }
  },
  __unnamed2: union{
    __g1_start: culonglong,
    __g1_start32: record{
      __low: cuint,
      __high: cuint
    }
  },
  __g_refs: [2]cuint,
  __g_size: [2]cuint,
  __g1_orig_size: cuint,
  __wrefs: cuint,
  __g_signals: [2]cuint
}
global pthread_mutex_t: type <cimport, nodecl> = @union{
  __data: __pthread_mutex_s,
  __size: [40]cchar,
  __align: clong
}
global pthread_cond_t: type <cimport, nodecl> = @union{
  __data: __pthread_cond_s,
  __size: [48]cchar,
  __align: clonglong
}
global __pthread_rwlock_arch_t: type <cimport, nodecl> = @record{
  __readers: cuint,
  __writers: cuint,
  __wrphase_futex: cuint,
  __writers_futex: cuint,
  __pad3: cuint,
  __pad4: cuint,
  __cur_writer: cint,
  __shared: cint,
  __rwelision: cschar,
  __pad1: [7]cuchar,
  __pad2: culong,
  __flags: cuint
}
global pthread_rwlock_t: type <cimport, nodecl> = @union{
  __data: __pthread_rwlock_arch_t,
  __size: [56]cchar,
  __align: clong
}
## end
]=]
