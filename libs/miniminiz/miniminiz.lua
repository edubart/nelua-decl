local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mz_',
  '^MZ_',
  '^tdefl_',
  '^TDEFL_',
  '^tinfl_',
  '^TINFL_',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
if not MINIZ_NO_IMPL then
  cdefine 'MINIZ_EXPORT static'
  cdefine 'MINIZ_IMPL'
end
cdefine 'MINIZ_NO_ZLIB_COMPATIBLE_NAMES'
cinclude 'miniminiz.h'
]]
]=]
