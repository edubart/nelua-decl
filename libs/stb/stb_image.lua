local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbi_',
  '^STBI_',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
if not STB_IMAGE_NO_IMPL then
  cdefine 'STB_IMAGE_STATIC'
  cdefine 'STB_IMAGE_IMPLEMENTATION'
end
if not ccinfo.is_gcc then
  cdefine 'STBI_NO_SIMD'
end
cinclude 'stb_image.h'
]]
]=]
