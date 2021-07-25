local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mbedtls_',
}

nldecl.prepend_code = [=[
##[[
cinclude '<mbedtls/sha256.h>'
linklib 'mbedcrypto'
]]
]=]
