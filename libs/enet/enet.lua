local nldecl = require 'nldecl'

nldecl.include_names = {
  '^ENET',
  '^ENet',
  '^enet',
  _ENetHost = true,
  in6_addr = true,
}

nldecl.include_macros = {
  in6_addr = {
    ENET_HOST_ANY = true,
  },
  uint32 = {
    ENET_HOST_BROADCAST = true,
  },
  uint16 = {
    ENET_PORT_ANY = true,
  },
}

nldecl.prepend_code = [=[
##[[
if not ENET_NO_IMPL then
  cdefine 'ENET_IMPLEMENTATION'
end
cinclude 'enet.h'
if ccinfo.is_windows then
  linklib 'ws2_32'
  linklib 'winmm'
end
]]
]=]

nldecl.append_code = [=[
global enet_v4_anyaddr: in6_addr <cimport, nodecl, const>
global enet_v4_noaddr: in6_addr <cimport, nodecl, const>
global enet_v4_localhost: in6_addr <cimport, nodecl, const>
global enet_v6_anyaddr: in6_addr <cimport, nodecl, const>
global enet_v6_noaddr: in6_addr <cimport, nodecl, const>
global enet_v6_localhost: in6_addr <cimport, nodecl, const>
]=]
