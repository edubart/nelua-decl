local nldecl = require 'nldecl'

nldecl.include_filters = {
  '^bl',
  '^BL'
}
nldecl.exclude_names = {
  blRuntimeMessageVFmt = true,
  blStringApplyOpFormatV = true,
}
nldecl.include_names = {
  BLResult = true
}
nldecl.prepend_code = [=[
##[[
cinclude '<blend2d.h>'
linklib 'blend2d'
]]
]=]
