local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbir_',
  '^STBIR_'
}

nldecl.prepend_code = [=[
##[[
if not STB_IMAGE_RESIZE_NO_IMPL then
  cdefine 'STB_IMAGE_RESIZE_STATIC'
  cdefine 'STB_IMAGE_RESIZE_IMPLEMENTATION'
end
cinclude 'stb_image_resize.h'
]]
]=]
