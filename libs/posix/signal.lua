local nldecl = require 'nldecl'

nldecl.force_include_names = {
  pthread_attr_t = true,
  '^__sig',
}

nldecl.exclude_names = {
  '^__',
  "^_",
  '^pthread',
  sigaction = true,
  fpregset_t = true,
}

nldecl.platform_names = {
  sigcontext = nldecl.OMIT_ALL_FIELDS,
  mcontext_t = nldecl.USE_KNOWN_FIELDS,
  ucontext_t = nldecl.USE_KNOWN_FIELDS,
}

nldecl.include_macros = {
  cint = {
    '^SIG[A-Z0-9]+$',
  },
  cuint = {
    '^SA',
  }
}

nldecl.prepend_code = [=[
## cinclude '<signal.h>'
]=]


nldecl.append_code = [=[
global sigaction_t: type <nodecl, cimport, ctypedef 'sigaction', cincomplete> = @record{
  sa_handler: function(cint),
  sa_sigaction: function(cint, *siginfo_t, pointer),
  sa_mask: sigset_t,
  sa_flags: cint,
  sa_restorer: function()
}
global function sigaction(sig: cint, act: *sigaction_t, oact: *sigaction_t): cint <cimport, nodecl> end
global SIG_ERR: function(cint) <cimport, nodecl>
global SIG_DFL: function(cint) <cimport, nodecl>
global SIG_IGN: function(cint) <cimport, nodecl>
]=]