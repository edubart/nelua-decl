local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbtt_',
  '^stbrp_',
  '^STBTT_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'STBTT_STATIC'
cdefine 'STB_TRUETYPE_IMPLEMENTATION'
cinclude '"stb_truetype.h"'
]]
]=]
