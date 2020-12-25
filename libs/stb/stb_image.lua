local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbi_',
  '^STBI_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'STB_IMAGE_STATIC'
cdefine 'STB_IMAGE_IMPLEMENTATION'
cinclude '"stb_image.h"'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
]=]
