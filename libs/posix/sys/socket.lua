local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^pthread',
}

nldecl.include_macros = {
  cint = {
    '^AF_',
    '^AI_',
    '^NI_',
    '^EAI_',
    '^IP_',
    '^IPV6_',
    '^NETLINK_',
    '^SOCK_',
    '^SO_',
    '^INET_',
    '^INET6_',
  },
}

nldecl.prepend_code = [=[
##[[
cinclude '<sys/socket.h>'
cinclude '<netinet/in.h>'
cinclude '<netinet/tcp.h>'
cinclude '<net/if.h>'
cinclude '<netdb.h>'
]]
]=]
