local nldecl = require 'nldecl'

nldecl.include_names = {
  '^IMG',
  '^SDL_IMAGE',
}

nldecl.include_macros = {
  cint = {
    SDL_IMAGE_MAJOR_VERSION = false,
    SDL_IMAGE_MINOR_VERSION = false,
    SDL_IMAGE_PATCHLEVEL = false,
    SDL_IMAGE_COMPILEDVERSION = false,
  }
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_image.h>'
linklib 'SDL2_image'
]]
]=]

nldecl.append_code = [[
global function SDL_IMAGE_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_IMAGE_VERSION(x: *SDL_version) <cimport, nodecl> end
global function IMG_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function IMG_GetError(): cstring <cimport, nodecl> end
]]
