local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbi_',
  '^STBI_'
}

nldecl.prepend_code = [=[
##[[
if STB_IMAGE_LINKLIB then
  if type(STB_IMAGE_LINKLIB) == 'string' then
    linklib(STB_IMAGE_LINKLIB)
  end
else
  cdefine 'STB_IMAGE_STATIC'
  cdefine 'STB_IMAGE_IMPLEMENTATION'
end
if not ccinfo.is_gcc then
  cdefine 'STBI_NO_SIMD'
end
cinclude 'stb_image.h'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
]=]
