local nldecl = require 'nldecl'

nldecl.include_names = {
  '^Mix',
  '^MIX',
  '^SDL_MIXER',
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_mixer.h>'
linklib 'SDL2_mixer'
]]
]=]

nldecl.include_macros = {
  cint = {
    MIX_CHANNELS = true,
    MIX_DEFAULT_FREQUENCY = true,
    MIX_DEFAULT_FORMAT = false,
    MIX_DEFAULT_CHANNELS = true,
    MIX_MAX_VOLUME = true,
    MIX_CHANNEL_POST = true,

    SDL_MIXER_MAJOR_VERSION = false,
    SDL_MIXER_MINOR_VERSION = false,
    SDL_MIXER_PATCHLEVEL = false,
    SDL_MIXER_COMPILEDVERSION = false,
  },

  cstring = {
    MIX_EFFECTSMAXSPEED = true,
  }

}

nldecl.append_code = [[
global function SDL_MIXER_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_MIXER_VERSION(x: *SDL_version) <cimport, nodecl> end
global function Mix_PlayChannel(channel: cint, chunk: *Mix_Chunk, loops: cint): cint <cimport, nodecl> end
global function Mix_FadeInChannel(channel: cint, chunk: *Mix_Chunk, loops: cint, ms: cint): cint <cimport, nodecl> end
global function Mix_LoadWAV(file: cstring): *Mix_Chunk <cimport, nodecl> end
global function Mix_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function Mix_GetError(): cstring <cimport, nodecl> end
global function Mix_ClearError(): void <cimport, nodecl> end
]]
