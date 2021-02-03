local nldecl = require 'nldecl'

nldecl.include_names = {
  '^TTF',
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_ttf.h>'
linklib 'SDL2_ttf'
]]
]=]

nldecl.append_code = [[
global SDL_TTF_MAJOR_VERSION: cint <cimport, nodecl, const>
global SDL_TTF_MINOR_VERSION: cint <cimport, nodecl, const>
global SDL_TTF_PATCHLEVEL: cint <cimport, nodecl, const>
global SDL_TTF_COMPILEDVERSION: cint <cimport, nodecl, const>
global function SDL_TTF_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_TTF_VERSION(x: *SDL_version) <cimport, nodecl> end
global function TTF_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function TTF_GetError(): cstring <cimport, nodecl> end
]]
