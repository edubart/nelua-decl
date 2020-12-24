local nldecl = require 'nldecl'

nldecl.include_names = {
  '^saudio_',
  '^SAUDIO_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_IMPL'
cinclude '"sokol_audio.h"'
if ccinfo.is_windows then
  linklib 'ole32'
elseif ccinfo.is_linux then
  linklib 'asound'
  linklib 'pthread'
end
]]
]=]
