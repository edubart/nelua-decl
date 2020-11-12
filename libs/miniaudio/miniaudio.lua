local nldecl = require 'nldecl'

nldecl.include_names = {
  '^ma_',
  '^MA_',
  ma_bool32 = true,
  ma_bool8 = true,
  ma_handle = true,
  ma_result = true,

  -- threading variables
  ma_spinlock = true,
  ma_thread = true,
  ma_mutex = true,
  ma_event = true,
  ma_semaphore = true,
  pthread_mutex_t = true,
  pthread_cond_t = true,
  pthread_list_t = true,
  __pthread_mutex_s = true,
  __pthread_cond_s = true,
  __pthread_list_t = true,
  __pthread_internal_list = true,
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
cdefine 'MINIAUDIO_IMPLEMENTATION'
cinclude '"miniaudio.h"'
linklib 'dl'
linklib 'pthread'
]]
]=]
