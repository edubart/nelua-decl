local nldecl = require 'nldecl'

nldecl.include_names = {
  '^saudio_',
  '^SAUDIO_'
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_AUDIO_NO_IMPL then
  cdefine 'SOKOL_AUDIO_API_DECL static'
  cdefine 'SOKOL_AUDIO_IMPL'
end
cinclude 'sokol_audio.h'
if ccinfo.is_windows then
  linklib 'ole32'
elseif ccinfo.is_linux then
  linklib 'asound'
  cflags '-pthread'
end
]]
]=]
