local nldecl = require 'nldecl'

nldecl.include_names = {
  '^pthread',
  sched_param = true,
  timespec = true,
  pthread_t = true,
  pthread_key_t = true,
}

nldecl.opaque_names = {
  pthread_mutexattr_t = true,
  pthread_condattr_t = true,
  pthread_attr_t = true,
  pthread_mutex_t = true,
  pthread_cond_t = true,
  pthread_rwlock_t = true,
  pthread_rwlockattr_t = true,
  pthread_barrier_t = true,
  pthread_barrierattr_t = true,
  pthread_key_t = true,
  pthread_t = true,
}

nldecl.prepend_code = [=[
## cinclude '<pthread.h>'
## cflags '-pthread'
]=]
