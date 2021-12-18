local nldecl = require 'nldecl'

nldecl.include_names = {
  '^msf_gif',
  '^MsfGif',
}

-- nldecl.include_macros = {
--   cint = {
--     ['^MJSON_TOK_'] = false,
--     ['^MJSON_ERROR_'] = false,
--     ['^JSONRPC_ERROR_'] = false,
--     MJSON_MAX_DEPTH = false,
--   },
-- }

nldecl.prepend_code = [=[
##[[
if not MSF_GIF_NO_IMPL then
  cdefine 'MSF_GIF_IMPL'
end
cinclude 'msf_gif.h'
]]
]=]
