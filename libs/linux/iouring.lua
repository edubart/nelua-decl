local nldecl = require 'nldecl'

nldecl.include_names = {
  '^io_uring',
  '^IO_URING',
  __kernel_timespec = true,
  sigset_t = true,
  iovec = true,
  msghdr = true,
  sockaddr = true,
  statx = true,
  open_how = true,
  cpu_set_t = true,
}

nldecl.include_macros = {
}

nldecl.prepend_code = [=[
##[[
cinclude '<liburing.h>'
linklib 'uring'
]]
]=]
