local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbi_',
  '^STBI_'
}

nldecl.prepend_code = [=[
##[[
if STB_IMAGE_WRITE_LINKLIB then
  if type(STB_IMAGE_WRITE_LINKLIB) == 'string' then
    linklib(STB_IMAGE_WRITE_LINKLIB)
  end
else
  cdefine 'STB_IMAGE_WRITE_STATIC'
  cdefine 'STB_IMAGE_WRITE_IMPLEMENTATION'
end
cinclude 'stb_image_write.h'
]]
]=]
