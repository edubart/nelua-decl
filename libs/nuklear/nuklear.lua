local nldecl = require 'nldecl'

nldecl.include_names = {
  '^NK_',
  '^nk_',
  sdlsurface_context = true,
}

nldecl.exclude_names = {
  nk_style_push_style_item = true,
}

nldecl.typedefs_names = setmetatable({}, {__index = function(_, name)
  if name:match('nk_') then
    return 'NK_'..name:sub(4)
  end
end})

nldecl.prepend_code = [=[
##[[
cdefine 'NK_INCLUDE_FIXED_TYPES'
cdefine 'NK_INCLUDE_STANDARD_IO'
cdefine 'NK_INCLUDE_DEFAULT_ALLOCATOR'
cdefine 'NK_INCLUDE_VERTEX_BUFFER_OUTPUT'
cdefine 'NK_INCLUDE_FONT_BAKING'
cdefine 'NK_INCLUDE_DEFAULT_FONT'
cdefine 'NK_INCLUDE_SOFTWARE_FONT'
cdefine 'NK_INCLUDE_STANDARD_VARARGS'
if NUKLEAR_LINKLIB then
  linklib(NUKLEAR_LINKLIB)
else
  cdefine 'NK_IMPLEMENTATION'
  cdefine 'NK_SDLSURFACE_IMPLEMENTATION'
end
cinclude 'nuklear.h'
cinclude 'nuklear-sdl2surface_rawfb.h'
]]
]=]
