local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.typedefs_names = {
  stat = 'stat_t'
}

nldecl.include_macros = {
  cuint = {
    '^S_',
  },
}

nldecl.prepend_code = [=[
## cinclude '<sys/stat.h>'
]=]

nldecl.append_code = [=[
global function S_ISFIFO(mode: cuint): boolean <cimport, nodecl> end
global function S_ISCHR(mode: cuint): boolean <cimport, nodecl> end
global function S_ISDIR(mode: cuint): boolean <cimport, nodecl> end
global function S_ISLNK(mode: cuint): boolean <cimport, nodecl> end
global function S_ISFIFO(mode: cuint): boolean <cimport, nodecl> end
global function S_ISBLK(mode: cuint): boolean <cimport, nodecl> end
global function S_ISREG(mode: cuint): boolean <cimport, nodecl> end
global function S_ISSOCK(mode: cuint): boolean <cimport, nodecl> end
]=]
