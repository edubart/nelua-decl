local nldecl = require 'nldecl'

nldecl.include_names = {
  '^curl',
  '^CURL',
  sockaddr = true,
  fd_set = true,
}

nldecl.prepend_code = [=[
##[[
linklib 'curl'
cinclude '<curl/curl.h>'
]]
global CURL = @void
]=]
