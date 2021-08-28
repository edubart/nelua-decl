local nldecl = require 'nldecl'

nldecl.include_names = {
  '^MPC_',
  '^MPCA_',
  '^mpc_',
  '^mpca_',
  FILE = true,
}

nldecl.include_macros = {
  cint = {
    '^MPC_',
  },
}

nldecl.prepend_code = [=[
##[[
cinclude 'mpc.h'
if not MPC_NO_IMPL then
  cinclude 'mpc.c'
end
]]
]=]
