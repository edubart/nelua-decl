local nldecl = require 'nldecl'

nldecl.include_names = {
  '^ma_',
  '^MA_',
  ma_bool32 = true,
  ma_bool8 = true,
  ma_handle = true,
  ma_result = true,
  ma_channel = true,
}

nldecl.exclude_names = {
  MA_SIZE_MAX = true,
  MA_INLINE = true,
  MA_API = true,
  MA_SIMD_ALIGNMENT = true,
  MA_PRIVATE = true,
  ma_thread = true,
  ma_mutex = true,
  ma_event = true,
  ma_semaphore = true,
}

nldecl.include_macros = {
  cint = {
    '^MA_',
    MA_VERSION_MAJOR = false,
    MA_VERSION_MINOR = false,
    MA_VERSION_REVISION = false,
  },
  uint32 = {
    MA_SOUND_SOURCE_CHANNEL_COUNT = true,
  },
  cstring = {
    MA_VERSION_STRING = false,
  }
}

nldecl.prepend_code = [=[
##[[
if not MINIAUDIO_NO_IMPL then
  cdefine 'MA_API static'
  cdefine 'MINIAUDIO_IMPLEMENTATION'
  cdefine 'MINIAUDIO_IMPLEMENTATION'
end
cinclude 'miniaudio.h'
if ccinfo.is_linux then
  linklib 'dl'
  cflags '-pthread'
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
global ma_pthread_mutex_t: type <cimport,nodecl> = @union{
  __data: [40]cchar,
  __alignment: uint64
}
global ma_pthread_cond_t: type <cimport,nodecl> = @union{
  __data: [48]cchar,
  __alignment: uint64
}
global ma_thread: type = @culong
global ma_mutex: type = @ma_pthread_mutex_t
global ma_event: type <cimport,nodecl> = @record{
  value: uint32,
  lock: ma_pthread_mutex_t,
  cond: ma_pthread_cond_t
}
global ma_semaphore: type <cimport,nodecl> = @record{
  value: cint,
  lock: ma_pthread_mutex_t,
  cond: ma_pthread_cond_t
}
## end
]=]
