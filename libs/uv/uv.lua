local nldecl = require 'nldecl'

nldecl.include_names = {
  '^uv_[a-z]',
  '^UV_[A-Z]',
  FILE = true,
  DIR = true,
  addrinfo = true,
  sockaddr = true,
  sockaddr_in = true,
  sockaddr_in6 = true,
  in_addr = true,
  in6_addr = true,
}

nldecl.opaque_names = {
  uv_file = true,
  uv_os_sock_t = true,
  uv_os_fd_t = true,
  uv_pid_t = true,
  uv_lib_t = true,
  uv_once_t = true,
  uv_thread_t = true,
  uv_mutex_t = true,
  uv_rwlock_t = true,
  uv_sem_t = true,
  uv_cond_t = true,
  uv_key_t = true,
  uv_barrier_t = true,
  uv_gid_t = true,
  uv_uid_t = true,
  uv__io_t = true,
}

nldecl.prepend_code = [=[
##[[
cinclude '<uv.h>'
linklib 'uv'
cflags '-fno-strict-aliasing'
]]
]=]
