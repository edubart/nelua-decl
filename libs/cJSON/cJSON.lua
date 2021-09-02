local nldecl = require 'nldecl'

nldecl.include_names = {
  '^CJSON',
  '^cJSON',
}

nldecl.include_macros = {
  cint = {
    ['^cJSON_'] = false,
    ['^CJSON_'] = false,
  },
}

nldecl.prepend_code = [=[
##[[
cinclude 'cJSON.h'
if not CJSON_NO_IMPL then
  cinclude 'cJSON.c'
end
]]
]=]

nldecl.append_code = [=[
global function cJSON_SetIntValue(object: *cJSON, number: cint): float64 <cimport,nodecl> end
global function cJSON_SetNumberValue(object: *cJSON, number: float64): float64 <cimport,nodecl> end
]=]
