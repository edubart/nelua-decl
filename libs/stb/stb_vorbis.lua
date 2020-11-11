local nldecl = require 'nldecl'

nldecl.include_names = {
  '^stb_',
  '^STB_'
}

nldecl.prepend_code = [=[
##[[
cinclude '"stb_vorbis.h"'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
]=]
