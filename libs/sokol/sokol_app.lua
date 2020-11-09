local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^sapp_',
  '^SAPP_'
}

nldecl.prepend_code = [=[
##[[
cdefine 'SOKOL_NO_ENTRY'
cdefine 'SOKOL_GLCORE33'
cdefine 'SOKOL_IMPL'
cinclude '"sokol_app.h"'
linklib 'X11'
linklib 'Xi'
linklib 'Xcursor'
linklib 'dl'
linklib 'pthread'
linklib 'GL'
]]
]=]
