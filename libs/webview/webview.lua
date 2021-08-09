local nldecl = require 'nldecl'

nldecl.include_names = {
  '^webview',
  '^WEBVIEW',
}

nldecl.prepend_code = [=[
##[[
if WEBVIEW_LINKLIB then
  linklib(WEBVIEW_LINKLIB)
else
  cdefine 'WEBVIEW_STATIC'
  cdefine 'WEBVIEW_IMPLEMENTATION'
  if ccinfo.is_apple then
    cflags '-framework WebKit'
  elseif ccinfo.is_windows then
    cflags '-Ims.webview2/include -lole32 -lcomctl32 -loleaut32 -luuid -lgdi32'
  else
    cflags(executor.eval'pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0')
  end
end
cinclude 'webview.h'
]]
]=]
