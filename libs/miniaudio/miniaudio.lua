local nldecl = require 'nldecl'

nldecl.prepend_code = [[
## cdefine 'MINIAUDIO_IMPLEMENTATION'
## cinclude '"miniaudio.h"'
## linklib 'dl'
## linklib 'pthread'
]]

nldecl.include_filters = {
  '^ma_',
  '^MA_',
}

nldecl.include_names = {
  ma_result = true,

  pthread_mutex_t = true,
  pthread_cond_t = true,
  pthread_list_t = true,
  __pthread_mutex_s = true,
  __pthread_cond_s = true,
  __pthread_list_t = true,
}

nldecl.generalize_pointers = {
  __pthread_internal_list = true,
}