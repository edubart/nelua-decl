local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stm_',
}

nldecl.prepend_code = [=[
##[[
if not SOKOL_TIME_NO_IMPL then
  cdefine 'SOKOL_TIME_API_DECL static'
  cdefine 'SOKOL_TIME_IMPL'
end
cinclude 'sokol_time.h'
cemitdecl [==[
#ifdef WIN32
#include <windows.h>
#elif _POSIX_C_SOURCE >= 199309L
#include <time.h>
#else
#include <unistd.h>
#endif
SOKOL_TIME_API_DECL void stm_sleep(uint64_t ms){
#ifdef WIN32
  Sleep(ms);
#elif _POSIX_C_SOURCE >= 199309L
  struct timespec ts;
  ts.tv_sec = ms / 1000;
  ts.tv_nsec = (ms % 1000) * 1000000;
  nanosleep(&ts, NULL);
#else
  if(ms >= 1000) {
    sleep(ms / 1000);
  }
  usleep((ms % 1000) * 1000);
#endif
}
]==]
]]
global function stm_sleep(ms: uint64): float64 <cimport, nodecl> end
]=]
