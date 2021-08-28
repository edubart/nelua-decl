local nldecl = require 'nldecl'

nldecl.include_names = {
  '^dmon',
  '^DMON',
}

nldecl.prepend_code = [=[
##[[
if not DMON_NO_IMPL then
  cdefine 'DMON_API_DECL static'
  cdefine 'DMON_IMPL'
end
cinclude 'dmon.h'
if ccinfo.is_linux then
  cflags '-pthread'
end
]]
]=]
