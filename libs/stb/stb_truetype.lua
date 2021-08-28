local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbtt_',
  '^stbrp_',
  '^STBTT_'
}

nldecl.prepend_code = [=[
##[[
if not STB_TRUETYPE_NO_IMPL then
  cdefine 'STBTT_STATIC'
  cdefine 'STB_TRUETYPE_IMPLEMENTATION'
end
cinclude 'stb_truetype.h'
]]
]=]
