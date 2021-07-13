local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MG_',
  '^mg_',
  FILE = true,
  timeval = true,
  dns_data = true,
}

nldecl.typedefs_names = {
  mg_str = 'mg_string'
}

nldecl.include_macros = {
  cint = {
    '^MG_',
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
  cfile 'mongoose.c'
  linklib 'ssl'
  linklib 'crypto'
end
]]
]=]
