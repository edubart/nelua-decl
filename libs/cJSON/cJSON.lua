local nldecl = require 'nldecl'

nldecl.include_names = {
  '^CJSON',
  '^cJSON',
}

nldecl.include_macros = {
  cint = {
    '^cJSON_',
    '^CJSON_',
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
