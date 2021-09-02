local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mjson_',
  '^jsonrpc_',
  '^MJSON_',
  '^JSONRPC_',
}

nldecl.include_macros = {
  cint = {
    '^MJSON_TOK_',
    '^MJSON_ERROR_',
    '^JSONRPC_ERROR_',
    MJSON_MAX_DEPTH = true,
  },
}

nldecl.prepend_code = [=[
##[[
cinclude 'mjson.h'
if not MONGOOSE_NO_IMPL then
  cinclude 'mjson.c'
end
]]
]=]
