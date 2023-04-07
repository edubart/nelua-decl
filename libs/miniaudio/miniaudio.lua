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
  cdefine 'MA_NO_PTHREAD_IN_HEADER'
  cdefine 'MINIAUDIO_IMPLEMENTATION'
end
cinclude 'miniaudio.h'
if ccinfo.is_linux then
  linklib 'dl'
  linklib 'm'
  cflags '-pthread'
elseif ccinfo.is_windows then
  linklib 'ole32'
end
]]
]=]
