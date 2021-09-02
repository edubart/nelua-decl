local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mjson_',
  '^jsonrpc_',
  '^MJSON_',
  '^JSONRPC_',
}

nldecl.include_macros = {
  cint = {
    ['^MJSON_TOK_'] = false,
    ['^MJSON_ERROR_'] = false,
    ['^JSONRPC_ERROR_'] = false,
    MJSON_MAX_DEPTH = false,
  },
}

nldecl.prepend_code = [=[
##[[
cinclude 'mjson.h'
if not MJSON_NO_IMPL then
  cinclude 'mjson.c'
end
]]
]=]

nldecl.append_code = [=[
global function jsonrpc_ctx_export(ctx: *jsonrpc_ctx, req: cstring, fn: function(*jsonrpc_request): void): void <cimport,nodecl> end
global function jsonrpc_export(req: cstring, fn: function(*jsonrpc_request): void): void <cimport,nodecl> end
global function jsonrpc_process(req: cstring, req_sz: cint, fn: mjson_print_fn_t, fndata: pointer, userdata: pointer): void <cimport,nodecl> end
]=]