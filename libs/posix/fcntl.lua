local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
  stat = true,
  timespec = true,
}

nldecl.include_macros = {
  cint = {
    '^AT_',
    '^FD_',
    '^F_',
    '^O_',
    '^POSIX_',
  },
}

nldecl.prepend_code = [=[
## cinclude '<fcntl.h>'
]=]
