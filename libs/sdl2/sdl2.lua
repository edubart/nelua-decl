local nldecl = require 'nldecl'

nldecl.include_names = {
  '^SDL',
  WindowShapeMode = true,
  _SDL_iconv_t = true,
}

nldecl.exclude_names = {
  SDL_DUMMY_ENUM = true,
  SDL_HAPTIC_LINUX = true,
}

nldecl.include_macros = {
  cint = {
    '^SDL_JOYSTICK_AXIS_',
    SDL_MUTEX_TIMEDOUT = true,

    SDL_LIL_ENDIAN = true,
    SDL_BIG_ENDIAN = true,
    SDL_BYTEORDER = true,

    SDL_TEXTEDITINGEVENT_TEXT_SIZE = true,
    SDL_TEXTINPUTEVENT_TEXT_SIZE = true,

    SDL_QUERY = true,
    SDL_IGNORE = true,
    SDL_DISABLE = true,
    SDL_ENABLE = true,

    SDL_NONSHAPEABLE_WINDOW = true,
    SDL_INVALID_SHAPE_ARGUMENT = true,
    SDL_WINDOW_LACKS_SHAPE = true,

    SDL_AUDIOCVT_MAX_FILTERS = true,
    SDL_MIX_MAXVOLUME = true,
    SDL_CACHELINE_SIZE = true,
    SDL_MAX_LOG_MESSAGE = true,

    SDL_MAJOR_VERSION = false,
    SDL_MINOR_VERSION = false,
    SDL_PATCHLEVEL = false,
    SDL_COMPILEDVERSION = false,
  },
  uint32 = {
    '^SDL_RWOPS_',
    '^SDL_WINDOWPOS_',
    '^SDL_INIT_',
    '^SDL_HAPTIC_',
    SDL_SWSURFACE = true,
    SDL_PREALLOC = true,
    SDL_RLEACCEL = true,
    SDL_DONTFREE = true,
    SDL_SIMD_ALIGNED = true,

    SDL_MUTEX_MAXWAIT = true,
    SDL_TOUCH_MOUSEID = true,
  },
  uint16 = {
    '^SDL_AUDIO_ALLOW_',
    '^SDL_AUDIO_MASK_',
  },
  int64 = {
    SDL_MOUSE_TOUCHID = true,
  },
  uint8 = {
    '^SDL_ALPHA_',
    '^SDL_BUTTON_',
    '^SDL_HAT_',
  },
  int8 = {
    SDL_RELEASED = true,
    SDL_PRESSED = true,
  },
  float32= {
    SDL_STANDARD_GRAVITY = true,
  },
  csize = {
    '^SDL_ICONV_'
  },
  cstring = {
    '^SDL_HINT_'
  },
}

nldecl.prepend_code = [=[
##[[
linklib 'SDL2'
cdefine 'SDL_MAIN_HANDLED'
cinclude '<SDL2/SDL.h>'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
local va_list <cimport, nodecl> = @record{}
]=]

nldecl.append_code = [[
-- Defined in C macros
global function SDL_BlitSurface(src: *SDL_Surface, srcrect: *SDL_Rect, dst: *SDL_Surface, dstrect: *SDL_Rect): cint <cimport, nodecl> end
global function SDL_BlitScaled(src: *SDL_Surface, srcrect: *SDL_Rect, dst: *SDL_Surface, dstrect: *SDL_Rect): cint <cimport, nodecl> end
global function SDL_TriggerBreakpoint() <cimport, nodecl> end
global function SDL_CompilerBarrier() <cimport, nodecl> end
global function SDL_MemoryBarrierRelease() <cimport, nodecl> end
global function SDL_MemoryBarrierAcquire() <cimport, nodecl> end
global function SDL_AtomicIncRef(a: *SDL_atomic_t): cint <cimport, nodecl> end
global function SDL_AtomicDecRef(a: *SDL_atomic_t): cint <cimport, nodecl> end
global function SDL_OutOfMemory(): cint <cimport, nodecl> end
global function SDL_Unsupported(): cint <cimport, nodecl> end
global function SDL_InvalidParamError(param: cstring): cint <cimport, nodecl> end
global function SDL_SwapLE16(x: int16): int16 <cimport, nodecl> end
global function SDL_SwapLE32(x: int32): int32 <cimport, nodecl> end
global function SDL_SwapLE64(x: int64): int64 <cimport, nodecl> end
global function SDL_SwapFloatLE(x: float32): float32 <cimport, nodecl> end
global function SDL_SwapBE16(x: int16): int16 <cimport, nodecl> end
global function SDL_SwapBE32(x: int32): int32 <cimport, nodecl> end
global function SDL_SwapBE64(x: int64): int64 <cimport, nodecl> end
global function SDL_SwapFloatBE(x: float32): float32 <cimport, nodecl> end
global function SDL_LoadWAV(file: cstring, spec: *SDL_AudioSpec, audio_buf: **uint8, audio_len: *uint32): *SDL_AudioSpec <cimport, nodecl> end
global function SDL_LoadBMPW(file: cstring): *SDL_Surface <cimport, nodecl> end
global function SDL_SaveBMP(surface: *SDL_Surface, file: cstring): cint <cimport, nodecl> end
global function SDL_GameControllerAddMappingsFromFile(file: cstring): cint <cimport, nodecl> end
global function SDL_QuitRequested(): cint <cimport, nodecl> end
global function SDL_GetEventState(type: uint32): uint8 <cimport, nodecl> end
global function SDL_AUDIO_BITSIZE(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISFLOAT(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISBIGENDIAN(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISSIGNED(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISINT(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISLITTLEENDIAN(x: uint16): uint16 <cimport, nodecl> end
global function SDL_AUDIO_ISUNSIGNED(x: uint16): uint16 <cimport, nodecl> end
global function SDL_PIXELFLAG(x: cint): cint <cimport, nodecl> end
global function SDL_PIXELTYPE(x: cint): cint <cimport, nodecl> end
global function SDL_PIXELORDER(x: cint): cint <cimport, nodecl> end
global function SDL_PIXELLAYOUT(x: cint): cint <cimport, nodecl> end
global function SDL_BITSPERPIXEL(x: cint): cint <cimport, nodecl> end
global function SDL_BYTESPERPIXEL(x: cint): cint <cimport, nodecl> end
global function SDL_ISPIXELFORMAT_INDEXED(format: SDL_PixelFormatEnum): SDL_bool <cimport, nodecl> end
global function SDL_ISPIXELFORMAT_PACKED(format: SDL_PixelFormatEnum): SDL_bool <cimport, nodecl> end
global function SDL_ISPIXELFORMAT_ARRAY(format: SDL_PixelFormatEnum): SDL_bool <cimport, nodecl> end
global function SDL_ISPIXELFORMAT_ALPHA(format: SDL_PixelFormatEnum): SDL_bool <cimport, nodecl> end
global function SDL_ISPIXELFORMAT_FOURCC(format: SDL_PixelFormatEnum): SDL_bool <cimport, nodecl> end
global function SDL_WINDOWPOS_ISUNDEFINED(x: uint32): SDL_bool <cimport, nodecl> end
global function SDL_WINDOWPOS_ISCENTERED(x: uint32): SDL_bool <cimport, nodecl> end
global function SDL_MUSTLOCK(s: *SDL_Surface): SDL_bool <cimport, nodecl> end
global function SDL_SCANCODE_TO_KEYCODE(x: SDL_Scancode): SDL_KeyCode <cimport, nodecl> end
global function SDL_SHAPEMODEALPHA(mode: WindowShapeMode): SDL_bool <cimport, nodecl> end
global function SDL_VERSION(x: *SDL_version) <cimport, nodecl> end
global function SDL_VERSION_ATLEAST(x: cint, y: cint, z: cint): SDL_bool <cimport, nodecl> end
]]

-- TODO
--[[
#define SDL_stack_alloc(type,count) (type*)SDL_malloc(sizeof(type)*(count))
#define SDL_stack_free(data) SDL_free(data)
#define SDL_min(x,y) (((x) < (y)) ? (x) : (y))
#define SDL_max(x,y) (((x) > (y)) ? (x) : (y))
#define SDL_zero(x) SDL_memset(&(x), 0, sizeof((x)))
#define SDL_zerop(x) SDL_memset((x), 0, sizeof(*(x)))
#define SDL_zeroa(x) SDL_memset((x), 0, sizeof((x)))
#define SDL_iconv_utf8_locale(S) SDL_iconv_string("", "UTF-8", S, SDL_strlen(S)+1)
#define SDL_iconv_utf8_ucs2(S) (Uint16 *)SDL_iconv_string("UCS-2-INTERNAL", "UTF-8", S, SDL_strlen(S)+1)
#define SDL_iconv_utf8_ucs4(S) (Uint32 *)SDL_iconv_string("UCS-4-INTERNAL", "UTF-8", S, SDL_strlen(S)+1)
#define SDL_disabled_assert(condition) do { (void) sizeof ((condition)); } while (SDL_NULL_WHILE_LOOP_CONDITION)
#define SDL_enabled_assert(condition) do { while ( !(condition) ) { static struct SDL_AssertData sdl_assert_data = { 0, 0, #condition, 0, 0, 0, 0 }; const SDL_AssertState sdl_assert_state = SDL_ReportAssertion(&sdl_assert_data, SDL_FUNCTION, SDL_FILE, SDL_LINE); if (sdl_assert_state == SDL_ASSERTION_RETRY) { continue; } else if (sdl_assert_state == SDL_ASSERTION_BREAK) { SDL_TriggerBreakpoint(); } break; } } while (SDL_NULL_WHILE_LOOP_CONDITION)
#define SDL_assert(condition) SDL_enabled_assert(condition)
#define SDL_assert_release(condition) SDL_enabled_assert(condition)
#define SDL_assert_paranoid(condition) SDL_disabled_assert(condition)
#define SDL_assert_always(condition) SDL_enabled_assert(condition)
]]
