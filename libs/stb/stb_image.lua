local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^stbi_',
  '^STBI_'
}

nldecl.generalize_pointers = {
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cdefine 'STB_IMAGE_STATIC'
cdefine 'STB_IMAGE_IMPLEMENTATION'
cinclude '"stb_image.h"'
]]
]=]
