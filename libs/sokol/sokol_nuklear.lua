local nldecl = require 'nldecl'

nldecl.include_names = {
  '^snk_',
}

nldecl.typedefs_names = setmetatable({}, {__index = function(_, name)
  if name:match('^nk_') then
    return 'NK_'..name:sub(4)
  end
end})

nldecl.prepend_code = [=[
##[[
if not SOKOL_NUKLEAR_NO_IMPL then
  cdefine 'SOKOL_NUKLEAR_API_DECL static'
  cdefine 'SOKOL_NUKLEAR_IMPL'
end
cinclude 'sokol_nuklear.h'
]]
]=]
