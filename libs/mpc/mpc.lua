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
if MPC_LINKLIB then
  cfile 'mpc.h'
  linklib(MPC_LINKLIB)
else
  cinclude 'mpc.h'
  cinclude 'mpc.c'
end
]]
]=]
