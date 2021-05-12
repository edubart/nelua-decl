local nldecl = require 'nldecl'

nldecl.include_names = {
  '^epoll',
  '^EPOLL',
  __sigset_t = true,
}

nldecl.include_macros = {
  cint = {
    '^EPOLL_CTL_'
  },
}

nldecl.prepend_code = [=[
## cinclude '<sys/epoll.h>'
]=]
