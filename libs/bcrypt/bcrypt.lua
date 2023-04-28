local nldecl = require('nldecl')

nldecl.prepend_code = [=[
##[[
cinclude "bcrypt.h"
cfile "bcrypt.c"
cfile "crypt_blowfish/crypt_gensalt.c"
cfile "crypt_blowfish/wrapper.c"
cfile "crypt_blowfish/crypt_blowfish.c"
]]
]=]
