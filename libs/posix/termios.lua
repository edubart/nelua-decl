local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__'
}

nldecl.include_macros = {
  cuint = {
    '^TC[A-Z]+$',
    '^CS[0-9]+$',
    '^ECHO[A-Z]+$',
    '^[A-Z]+DLY$',
    '^I[A-Z]+$',
    '^O[A-Z]+$',
    '^B[0-9]+$',
    '^V[A-Z]+$',
    NOFLSH = true,
    TOSTOP = true,
    BRKINT = true,
    PARMRK = true,
    PARODD = true,
    HUPCL = true,
    CSIZE = true,
    CSTOPB = true,
    CREAD = true,
    PARENB = true,
    CLOCAL = true,
    CRTSCTS = true,
  },
}

nldecl.prepend_code = [=[
## cinclude '<termios.h>'
]=]
