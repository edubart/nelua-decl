local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mbedtls_',
  '^MBEDTLS_',
  tm = true,
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cinclude '<mbedtls/aes.h>'
cinclude '<mbedtls/aesni.h>'
cinclude '<mbedtls/arc4.h>'
cinclude '<mbedtls/aria.h>'
cinclude '<mbedtls/asn1.h>'
cinclude '<mbedtls/asn1write.h>'
cinclude '<mbedtls/base64.h>'
cinclude '<mbedtls/bignum.h>'
cinclude '<mbedtls/blowfish.h>'
cinclude '<mbedtls/bn_mul.h>'
cinclude '<mbedtls/camellia.h>'
cinclude '<mbedtls/ccm.h>'
cinclude '<mbedtls/ccm.h>'
cinclude '<mbedtls/certs.h>'
cinclude '<mbedtls/chacha20.h>'
cinclude '<mbedtls/chachapoly.h>'
cinclude '<mbedtls/cipher.h>'
cinclude '<mbedtls/cmac.h>'
cinclude '<mbedtls/ctr_drbg.h>'
cinclude '<mbedtls/debug.h>'
cinclude '<mbedtls/des.h>'
cinclude '<mbedtls/dhm.h>'
cinclude '<mbedtls/ecdh.h>'
cinclude '<mbedtls/ecdsa.h>'
cinclude '<mbedtls/ecjpake.h>'
cinclude '<mbedtls/ecp.h>'
cinclude '<mbedtls/entropy.h>'
cinclude '<mbedtls/entropy_poll.h>'
cinclude '<mbedtls/error.h>'
cinclude '<mbedtls/gcm.h>'
cinclude '<mbedtls/havege.h>'
cinclude '<mbedtls/hkdf.h>'
cinclude '<mbedtls/hmac_drbg.h>'
cinclude '<mbedtls/md2.h>'
cinclude '<mbedtls/md4.h>'
cinclude '<mbedtls/md5.h>'
cinclude '<mbedtls/md.h>'
cinclude '<mbedtls/net.h>'
cinclude '<mbedtls/net_sockets.h>'
cinclude '<mbedtls/nist_kw.h>'
cinclude '<mbedtls/oid.h>'
cinclude '<mbedtls/padlock.h>'
cinclude '<mbedtls/pem.h>'
cinclude '<mbedtls/pkcs11.h>'
cinclude '<mbedtls/pkcs12.h>'
cinclude '<mbedtls/pkcs5.h>'
cinclude '<mbedtls/pk.h>'
cinclude '<mbedtls/platform.h>'
cinclude '<mbedtls/platform_time.h>'
cinclude '<mbedtls/platform_util.h>'
cinclude '<mbedtls/poly1305.h>'
cinclude '<mbedtls/psa_util.h>'
cinclude '<mbedtls/ripemd160.h>'
cinclude '<mbedtls/rsa.h>'
cinclude '<mbedtls/sha1.h>'
cinclude '<mbedtls/sha256.h>'
cinclude '<mbedtls/sha512.h>'
cinclude '<mbedtls/ssl_cache.h>'
cinclude '<mbedtls/ssl_ciphersuites.h>'
cinclude '<mbedtls/ssl_cookie.h>'
cinclude '<mbedtls/ssl.h>'
cinclude '<mbedtls/ssl_ticket.h>'
cinclude '<mbedtls/threading.h>'
cinclude '<mbedtls/timing.h>'
cinclude '<mbedtls/version.h>'
cinclude '<mbedtls/x509_crl.h>'
cinclude '<mbedtls/x509_crt.h>'
cinclude '<mbedtls/x509_csr.h>'
cinclude '<mbedtls/x509.h>'
cinclude '<mbedtls/xtea.h>'
linklib 'mbedcrypto'
linklib 'mbedtls'
linklib 'mbedx509'
]]
]=]

nldecl.include_macros = {
  cint = {
    ['^MBEDTLS_'] = false,
    ['^MBEDTLS_ERR_CIPHER_'] = false,
    MBEDTLS_VERSION_MAJOR = false,
    MBEDTLS_VERSION_MINOR = false,
    MBEDTLS_VERSION_PATCH = false,
  },
  string = {
    MBEDTLS_VERSION_STRING = false,
    MBEDTLS_VERSION_STRING_FULL = false,
    MBEDTLS_PLATFORM_STD_NV_SEED_FILE = false,
    MBEDTLS_PRINTF_SIZET = false,
    MBEDTLS_PRINTF_LONGLONG = false,
  }
}
