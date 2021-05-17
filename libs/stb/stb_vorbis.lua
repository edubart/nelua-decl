local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stb_',
  '^STB_'
}

nldecl.prepend_code = [=[
##[[
if STB_VORBIS_LINKLIB then
  if type(STB_VORBIS_LINKLIB) == 'string' then
    linklib(STB_VORBIS_LINKLIB)
  end
  cdefine 'STB_VORBIS_HEADER_ONLY'
end
cinclude 'stb_vorbis.h'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
]=]
