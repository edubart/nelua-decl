local nldecl = require 'nldecl'

nldecl.include_names = {
  '^Mix',
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_mixer.h>'
linklib 'SDL2_mixer'
]]
]=]

nldecl.append_code = [[
global SDL_MIXER_MAJOR_VERSION: cint <cimport, nodecl, const>
global SDL_MIXER_MINOR_VERSION: cint <cimport, nodecl, const>
global SDL_MIXER_PATCHLEVEL: cint <cimport, nodecl, const>
global SDL_MIXER_COMPILEDVERSION: cint <cimport, nodecl, const>
global function SDL_MIXER_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_MIXER_VERSION(x: *SDL_version) <cimport, nodecl> end
global function Mix_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function Mix_GetError(): cstring <cimport, nodecl> end
global function Mix_ClearError(): void <cimport, nodecl> end
]]
