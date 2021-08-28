local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbi_',
  '^STBI_'
}

nldecl.prepend_code = [=[
##[[
if not STB_IMAGE_WRITE_NO_IMPL then
  cdefine 'STB_IMAGE_WRITE_STATIC'
  cdefine 'STB_IMAGE_WRITE_IMPLEMENTATION'
end
cinclude 'stb_image_write.h'
]]
]=]
