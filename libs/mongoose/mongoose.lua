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
  },
}

nldecl.prepend_code = [=[
##[[
if MONGOOSE_LINKLIB then
  cinclude 'mongoose.h'
  linklib(MONGOOSE_LINKLIB)
else
  cdefine 'MG_ENABLE_OPENSSL 1'
  cinclude 'mongoose.h'
  cinclude 'mongoose.c'
  linklib 'ssl'
  linklib 'crypto'
end
if ccinfo.is_windows then
  linklib 'ws2_32'
end
]]
]=]
