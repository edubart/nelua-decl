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
if not ZNET_NO_IMPL then
  cdefine 'ZN_STATIC_API'
  cdefine 'ZN_IMPLEMENTATION'
end
cinclude 'znet.h'
if ccinfo.is_windows then
  linklib 'ws2_32'
elseif ccinfo.is_linux then
  cflags '-pthread'
end
]]
]=]

nldecl.append_code = [=[
global zn_Time = @cuint
]=]
