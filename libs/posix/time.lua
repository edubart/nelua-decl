local nldecl = require 'nldecl'

nldecl.exclude_names = {
  __timer_t = true,
  __caddr_t = true,
  __fsid_t = true,
  __locale_t = true,
  __timezone = true,
  __daylight = true,
  __tzname = true,
}

nldecl.include_macros = {
  cint = {
    '^CLOCK_',
  },
  clong = {
    CLOCKS_PER_SEC = true,
  }
}

nldecl.prepend_code = [=[
## cinclude '<time.h>'
]=]
