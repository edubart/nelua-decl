local nldecl = require 'nldecl'

nldecl.include_names = {
  '^TTF',
  '^SDL_TTF',

  UNICODE_BOM_NATIVE = true,
  UNICODE_BOM_SWAPPED = true,
}

nldecl.include_macros = {
  cint = {
    SDL_TTF_MAJOR_VERSION = false,
    SDL_TTF_MINOR_VERSION = false,
    SDL_TTF_PATCHLEVEL = false,
    SDL_TTF_COMPILEDVERSION = false,

    UNICODE_BOM_NATIVE = true,
    UNICODE_BOM_SWAPPED = true,

    TTF_STYLE_NORMAL = true,
    TTF_STYLE_BOLD = true,
    TTF_STYLE_ITALIC = true,
    TTF_STYLE_UNDERLINE = true,
    TTF_STYLE_STRIKETHROUGH = true,

    TTF_HINTING_NORMAL = true,
    TTF_HINTING_LIGHT = true,
    TTF_HINTING_MONO = true,
    TTF_HINTING_NONE = true,
  }
}

nldecl.prepend_code = [=[
##[[
cinclude '<SDL2/SDL_ttf.h>'
linklib 'SDL2_ttf'
]]
]=]

nldecl.append_code = [[
global function SDL_TTF_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
global function SDL_TTF_VERSION(x: *SDL_version) <cimport, nodecl> end
global function TTF_SetError(fmt: cstring, ...: cvarargs): cint <cimport, nodecl> end
global function TTF_GetError(): cstring <cimport, nodecl> end
]]
