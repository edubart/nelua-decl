local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^saudio_',
  '^SAUDIO_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_IMPL'
cinclude '"sokol_audio.h"'
linklib 'asound'
]]
]=]
