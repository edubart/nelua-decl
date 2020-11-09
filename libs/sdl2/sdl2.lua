local nldecl = require 'nldecl'

nldecl.prepend_code = [=[
##[[
linklib 'SDL2'
cdefine 'SDL_MAIN_HANDLED'
cinclude '<SDL2/SDL.h>'
]]
]=]

nldecl.include_filters = {
  '^SDL',
}
nldecl.include_names = {
  WindowShapeMode = true,
}
nldecl.exclude_names = {
  -- C va_list is not supported yet
  SDL_vsscanf = true,
  SDL_vsnprintf = true,
  SDL_LogMessageV = true,
}
nldecl.generalize_pointers = {
  _SDL_iconv_t = true,
  FILE = true,
}
