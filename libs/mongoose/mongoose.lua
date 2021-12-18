local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MG_',
  '^WEBSOCKET_',
  '^mg_',
  FILE = true,
  timeval = true,
  dns_data = true,
}

nldecl.include_macros = {
  cint = {
    '^MG_',
    '^WEBSOCKET_',
  },
  cstring = {
    MG_VERSION = true,
    MG_HTTP_INDEX = true,
  },
}

nldecl.prepend_code = [=[
##[[
if MONGOOSE_MBEDTLS then
  cdefine 'MG_ENABLE_MBEDTLS 1'
  linklib 'mbedtls'
  linklib 'mbedcrypto'
  linklib 'mbedx509'
elseif MONGOOSE_OPENSSL then
  cdefine 'MG_ENABLE_OPENSSL 1'
  linklib 'ssl'
  linklib 'crypto'
end
cinclude 'mongoose.h'
if not MONGOOSE_NO_IMPL then
  cinclude 'mongoose.c'
end
if ccinfo.is_windows then
  linklib 'ws2_32'
end
]]
]=]
