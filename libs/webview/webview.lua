local nldecl = require 'nldecl'

nldecl.include_names = {
  '^webview',
  '^WEBVIEW',
}

nldecl.prepend_code = [=[
##[[
if not WEBVIEW_NO_IMPL then
  cdefine 'WEBVIEW_STATIC'
  cdefine 'WEBVIEW_IMPLEMENTATION'
end
if ccinfo.is_apple then
  cflags '-framework WebKit'
elseif ccinfo.is_windows then
  cflags '-Ims.webview2/include -lole32 -lcomctl32 -loleaut32 -luuid -lgdi32'
else
  cflags(executor.eval'pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0')
end
cinclude 'webview.h'
]]
]=]
