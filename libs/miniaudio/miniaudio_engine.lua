local nldecl = require 'nldecl'

nldecl.include_names = {
  '^ma_',
  '^MA_',
  ma_bool32 = true,
  ma_bool8 = true,
  ma_handle = true,
  ma_result = true,

  ma_effect = true,
  ma_async_notification = true,
}

nldecl.opaque_names = {
  ma_spinlock = true,
  ma_thread = true,
  ma_mutex = true,
  ma_event = true,
  ma_semaphore = true,
}

nldecl.exclude_names = {
  MA_SIZE_MAX = true,
  MA_INLINE = true,
  MA_API = true,
  MA_SIMD_ALIGNMENT = true,
  MA_PRIVATE = true,
}

nldecl.include_macros = {
  cint = {
    '^MA_',
    MA_VERSION_MAJOR = false,
    MA_VERSION_MINOR = false,
    MA_VERSION_REVISION = false,
  },
  cstring = {
    MA_VERSION_STRING = false,
  }
}

nldecl.prepend_code = [=[
##[[
if MINIAUDIO_LINKLIB then
  if type(MINIAUDIO_LINKLIB) == 'string' then
    linklib(MINIAUDIO_LINKLIB)
  end
else
  cdefine 'MA_API static'
  cdefine 'MINIAUDIO_IMPLEMENTATION'
end
cinclude 'miniaudio.h'
cinclude 'miniaudio_engine.h'
if ccinfo.is_linux then
  linklib 'dl'
  linklib 'pthread'
elseif ccinfo.is_windows then
  linklib 'ole32'
end
]]
## if ccinfo.is_windows then
global ma_thread: type = @pointer
global ma_mutex: type = @pointer
global ma_event: type = @pointer
global ma_semaphore: type = @pointer
## else
global __pthread_internal_list: type <cimport, forwarddecl> = @record{}
global __pthread_internal_list: type <cimport, nodecl> = @record{
  __prev: *__pthread_internal_list,
  __next: *__pthread_internal_list
}
global __pthread_list_t: type = @__pthread_internal_list
global __pthread_mutex_s: type <cimport, nodecl> = @record{
  __lock: cint,
  __count: cuint,
  __owner: cint,
  __nusers: cuint,
  __kind: cint,
  __spins: cshort,
  __elision: cshort,
  __list: __pthread_list_t
}
global __pthread_cond_s: type <cimport, nodecl> = @record{
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
global ma_thread: type = @culong
global ma_mutex: type = @pthread_mutex_t
global ma_event: type <cimport, nodecl> = @record{
  value: uint32,
  lock: pthread_mutex_t,
  cond: pthread_cond_t
}
global ma_semaphore: type <cimport, nodecl> = @record{
  value: cint,
  lock: pthread_mutex_t,
  cond: pthread_cond_t
}
## end
]=]
