local nldecl = require 'nldecl'

nldecl.include_names = {
  '^sqlite',
  '^SQLITE',
}

nldecl.exclude_names = {
  SQLITE_DEPRECATED = true,
  SQLITE_EXPERIMENTAL = true,
  SQLITE_EXTERN = true,
  SQLITE_STDCALL = true,
}

nldecl.include_macros = {
  cint = {
    '^SQLITE_',
  },
  cstring = {
    SQLITE_SOURCE_ID = true,
    SQLITE_VERSION = true,
  }
}

nldecl.prepend_code = [=[
##[[
cinclude '<sqlite3.h>'
linklib 'sqlite3'
]]
]=]
