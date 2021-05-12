local nldecl = require 'nldecl'

nldecl.include_names = {
  '^inotify',
  '^IN_',
}

nldecl.exclude_names = {
  -- being declared twice? lets declare manually
  IN_CLOEXEC = true,
  IN_NONBLOCK = true,
}

nldecl.include_macros = {
  cint = {
    ['^IN_'] = false
  },
}

nldecl.prepend_code = [=[
## cinclude '<sys/inotify.h>'
]=]

nldecl.append_code = [=[
global IN_CLOEXEC: cint <cimport, nodecl, const>
global IN_NONBLOCK: cint <cimport, nodecl, const>
]=]
