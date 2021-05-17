local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sapp_',
  '^SAPP_'
}

nldecl.prepend_code = [=[
##[[
if SOKOL_APP_LINKLIB then
  if type(SOKOL_APP_LINKLIB) == 'string' then
    linklib(SOKOL_APP_LINKLIB)
  end
else
  cdefine 'SOKOL_APP_API_DECL static'
  cdefine 'SOKOL_APP_IMPL'
end
cdefine 'SOKOL_NO_ENTRY'
if ccinfo.is_emscripten then
  cdefine 'SOKOL_GLES2'
else
  cdefine 'SOKOL_GLCORE33'
end
cinclude 'sokol_app.h'
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
