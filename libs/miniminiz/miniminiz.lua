local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mz_',
  '^MZ_',
  '^tdefl_',
  '^TDEFL_',
  '^tinfl_',
  '^TINFL_',
}

nldecl.prepend_code = [=[
##[[
if MINIZ_LINKLIB then
  if type(MINIZ_LINKLIB) == 'string' then
    linklib(MINIZ_LINKLIB)
  end
else
  cdefine 'MINIZ_EXPORT static'
  cdefine 'MINIZ_IMPL'
end
cdefine 'MINIZ_NO_ZLIB_COMPATIBLE_NAMES'
cinclude 'miniminiz.h'
]]
local FILE <cimport, nodecl, forwarddecl> = @record{}
]=]
