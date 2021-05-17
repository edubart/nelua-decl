local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stbtt_',
  '^stbrp_',
  '^STBTT_'
}

nldecl.prepend_code = [=[
##[[
if STB_TRUETYPE_LINKLIB then
  if type(STB_TRUETYPE_LINKLIB) == 'string' then
    linklib(STB_TRUETYPE_LINKLIB)
  end
else
  cdefine 'STBTT_STATIC'
  cdefine 'STB_TRUETYPE_IMPLEMENTATION'
end
cinclude 'stb_truetype.h'
]]
]=]
