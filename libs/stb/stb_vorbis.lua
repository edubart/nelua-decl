local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stb_',
  '^STB_',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
if STB_VORBIS_NO_IMPL then
  cdefine 'STB_VORBIS_HEADER_ONLY'
end
cinclude 'stb_vorbis.h'
]]
]=]
