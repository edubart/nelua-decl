local nldecl = require 'nldecl'

nldecl.include_names = {
  '^uv_[a-z]',
  '^UV_[A-Z]',
  FILE = true,
  addrinfo = true,
  sockaddr = true,
  sockaddr_in = true,
  sockaddr_in6 = true,
  in_addr = true,
  in6_addr = true,
}

nldecl.platform_names = {
  addrinfo = nldecl.USE_KNOWN_FIELDS,
  sockaddr = nldecl.USE_KNOWN_FIELDS,
  sockaddr_in = nldecl.USE_KNOWN_FIELDS,
  sockaddr_in6 = nldecl.USE_KNOWN_FIELDS,
  in_addr = nldecl.USE_KNOWN_FIELDS,
  in6_addr = nldecl.USE_KNOWN_FIELDS,

  uv_buf_t = nldecl.USE_KNOWN_FIELDS,

  uv_file = nldecl.OMIT_ALL_FIELDS,
  uv_os_sock_t = nldecl.OMIT_ALL_FIELDS,
  uv_os_fd_t = nldecl.OMIT_ALL_FIELDS,
  uv_pid_t = nldecl.OMIT_ALL_FIELDS,
  uv_lib_t = nldecl.OMIT_ALL_FIELDS,

  uv_once_t = nldecl.OMIT_ALL_FIELDS,
  uv_thread_t = nldecl.OMIT_ALL_FIELDS,
  uv_mutex_t = nldecl.OMIT_ALL_FIELDS,
  uv_rwlock_t = nldecl.OMIT_ALL_FIELDS,
  uv_sem_t = nldecl.OMIT_ALL_FIELDS,
  uv_cond_t = nldecl.OMIT_ALL_FIELDS,
  uv_key_t = nldecl.OMIT_ALL_FIELDS,
  uv_barrier_t = nldecl.OMIT_ALL_FIELDS,
  uv_gid_t = nldecl.OMIT_ALL_FIELDS,
  uv_uid_t = nldecl.OMIT_ALL_FIELDS,

  uv_req_s = nldecl.USE_KNOWN_FIELDS,
  uv_shutdown_s = nldecl.USE_KNOWN_FIELDS,
  uv_handle_s = nldecl.USE_KNOWN_FIELDS,
  uv_stream_s = nldecl.USE_KNOWN_FIELDS,
  uv_write_s = nldecl.USE_KNOWN_FIELDS,
  uv_tcp_s = nldecl.USE_KNOWN_FIELDS,
  uv_connect_s = nldecl.USE_KNOWN_FIELDS,
  uv_udp_s = nldecl.USE_KNOWN_FIELDS,
  uv_udp_send_s = nldecl.USE_KNOWN_FIELDS,
  uv_tty_s = nldecl.USE_KNOWN_FIELDS,
  uv_pipe_s = nldecl.USE_KNOWN_FIELDS,
  uv_poll_s = nldecl.USE_KNOWN_FIELDS,
  uv_prepare_s = nldecl.USE_KNOWN_FIELDS,
  uv_check_s = nldecl.USE_KNOWN_FIELDS,
  uv_idle_s = nldecl.USE_KNOWN_FIELDS,
  uv_async_s = nldecl.USE_KNOWN_FIELDS,
  uv_timer_s = nldecl.USE_KNOWN_FIELDS,
  uv_getaddrinfo_s = nldecl.USE_KNOWN_FIELDS,
  uv_getnameinfo_s = nldecl.USE_KNOWN_FIELDS,
  uv_process_s = nldecl.USE_KNOWN_FIELDS,
  uv_work_s = nldecl.USE_KNOWN_FIELDS,
  uv_dir_s = nldecl.USE_KNOWN_FIELDS,
  uv_fs_s = nldecl.USE_KNOWN_FIELDS,
  uv_fs_event_s = nldecl.USE_KNOWN_FIELDS,
  uv_signal_s = nldecl.USE_KNOWN_FIELDS,
  uv_loop_s = nldecl.USE_KNOWN_FIELDS,
  uv_random_s = nldecl.USE_KNOWN_FIELDS,
}

nldecl.prepend_code = [=[
##[[
cinclude '<uv.h>'
linklib 'uv'
cflags '-fno-strict-aliasing'
]]
]=]
