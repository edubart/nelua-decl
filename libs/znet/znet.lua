local nldecl = require 'nldecl'

nldecl.include_names = {
  '^zn_',
  '^ZN_',
}

nldecl.include_macros = {
  cint = {
    '^ZN_RUN_'
  }
}

nldecl.prepend_code = [=[
##[[
if ZNET_LINKLIB then
  if type(ZNET_LINKLIB) == 'string' then
    linklib(ZNET_LINKLIB)
  end
else
  cdefine 'ZN_IMPLEMENTATION'
end
cinclude '"znet.h"'
if ccinfo.is_windows then
  linklib 'ws2_32'
end
]]
]=]

nldecl.append_code = [=[
global zn_Time = @cuint
]=]
