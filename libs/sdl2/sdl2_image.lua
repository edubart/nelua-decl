local nldecl = require 'nldecl'

nldecl.include_names = {
  '^IMG',
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_image.h>'
linklib 'SDL2_image'
]]
]=]

nldecl.append_code = [[
global SDL_IMAGE_MAJOR_VERSION: cint <cimport, nodecl, const>
global SDL_IMAGE_MINOR_VERSION: cint <cimport, nodecl, const>
global SDL_IMAGE_PATCHLEVEL: cint <cimport, nodecl, const>
global SDL_IMAGE_COMPILEDVERSION: cint <cimport, nodecl, const>
global function SDL_IMAGE_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_IMAGE_VERSION(x: *SDL_version) <cimport, nodecl> end
global function IMG_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function IMG_GetError(): cstring <cimport, nodecl> end
]]
