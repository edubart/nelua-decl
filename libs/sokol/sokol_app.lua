local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sapp_',
  '^SAPP_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_NO_ENTRY'
cdefine 'SOKOL_GLCORE33'
cdefine 'SOKOL_IMPL'
cinclude '"sokol_app.h"'
if ccinfo.is_linux then
  linklib 'X11'
  linklib 'Xi'
  linklib 'Xcursor'
  linklib 'dl'
elseif ccinfo.is_windows then
  linklib 'kernel32'
  linklib 'user32'
  linklib 'shell32'
end
]]
]=]
