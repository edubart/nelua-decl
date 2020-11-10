local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^stbi_',
  '^STBI_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'STB_IMAGE_WRITE_STATIC'
cdefine 'STB_IMAGE_WRITE_IMPLEMENTATION'
cinclude '"stb_image_write.h"'
]]
]=]
