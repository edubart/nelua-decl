local nldecl = require 'nldecl'

nldecl.include_names = {
  '^c2mir',
  '^mir_',
  '^MIR_',
  '^[A-Z]+_MIR_',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cinclude 'c2mir.h'
linklib 'mir'
]]
]=]

nldecl.append_code = [=[
global function MIR_init(): MIR_context_t <cimport, nodecl> end
]=]
