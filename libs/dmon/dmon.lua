local nldecl = require 'nldecl'

nldecl.include_names = {
  '^dmon',
  '^DMON',
}

nldecl.prepend_code = [=[
##[[
if DMON_LINKLIB then
  if type(DMON_LINKLIB) == 'string' then
    linklib(DMON_LINKLIB)
  end
else
  cdefine 'DMON_API_DECL static'
  cdefine 'DMON_IMPL'
end
cinclude '"dmon.h"'
if ccinfo.is_linux then
  linklib 'pthread'
end
]]
]=]
