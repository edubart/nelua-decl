local nldecl = require 'nldecl'

nldecl.exclude_filters = {
  'lua_pushvfstring'
}
nldecl.include_filters = {
  '^lua',
  '^LUA',
}
nldecl.include_names = {
  lua_Integer = true,
  lua_Number = true,
  lua_Unsigned = true,
  lua_KContext = true,
}
nldecl.generalize_pointers = {
  FILE = true,
  CallInfo = true,
}

nldecl.prepend_code = [=[
##[[
linklib 'lua'
cinclude '<lua.h>'
cinclude '<lauxlib.h>'
cinclude '<lualib.h>'
]]
]=]

-- bind some functions manually because
-- they are defined as macros
nldecl.append_code = [[
global function lua_call(L: *lua_State, nargs: cint, nresults: cint) <cimport, nodecl> end
global function lua_pcall(L: *lua_State,nargs: cint, nresults: cint, errfunc: cint): cint <cimport, nodecl> end
global function lua_yield(L: *lua_State, nresults: cint): cint <cimport, nodecl> end
global function lua_getextraspace(L: *lua_State):pointer <cimport, nodecl> end
global function lua_tonumber(L: *lua_State, idx: cint): lua_Number <cimport, nodecl> end
global function lua_tointeger(L: *lua_State, idx: cint): lua_Integer <cimport, nodecl> end
global function lua_pop(L: *lua_State, idx: cint) <cimport, nodecl> end
global function lua_newtable(L: *lua_State) <cimport, nodecl> end
global function lua_register(L: *lua_State, name: cstring, f: lua_CFunction) <cimport, nodecl> end
global function lua_pushcfunction(L: *lua_State, fn: lua_CFunction) <cimport, nodecl> end
global function lua_isfunction(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_istable(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_islightuserdata(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_isnil(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_isboolean(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_isthread(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_isnone(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_isnoneornil(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_pushliteral(L: *lua_State, s: cstring): cstring <cimport, nodecl> end
global function lua_pushglobaltable(L: *lua_State) <cimport, nodecl> end
global function lua_tostring(L: *lua_State, idx: cint): cstring <cimport, nodecl> end
global function lua_insert(L: *lua_State, idx: cint) <cimport, nodecl> end
global function lua_remove(L: *lua_State, idx: cint) <cimport, nodecl> end
global function lua_replace(L: *lua_State, idx: cint) <cimport, nodecl> end
global function lua_newuserdata(L: *lua_State, sz: csize): pointer <cimport, nodecl> end
global function lua_getuservalue(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function lua_setuservalue(L: *lua_State, idx: cint): cint <cimport, nodecl> end
global function luaL_checkversion(L: *lua_State) <cimport, nodecl> end
global function luaL_loadfile(L: *lua_State, filename: cstring): cint <cimport, nodecl> end
global function luaL_newlibtable(L: *lua_State, l: *[0]luaL_Reg) <cimport, nodecl> end
global function luaL_newlib(L: *lua_State, l: *[0]luaL_Reg) <cimport, nodecl> end
global function luaL_argcheck(L: *lua_State, cond: cint, arg: cint, extramsg: cstring) <cimport, nodecl> end
global function luaL_argexpected(L: *lua_State, cond: cint, arg: cint, tname: cstring) <cimport, nodecl> end
global function luaL_checkstring(L: *lua_State, arg: cint): cstring <cimport, nodecl> end
global function luaL_optstring(L: *lua_State, arg: cint, def: cstring): cstring <cimport, nodecl> end
global function luaL_typename(L: *lua_State, idx: cint): cstring <cimport, nodecl> end
global function luaL_dofile(L: *lua_State, fn: cstring): cint <cimport, nodecl> end
global function luaL_dostring(L: *lua_State, s: cstring): cint <cimport, nodecl> end
global function luaL_getmetatable(L: *lua_State, n: cstring): cint <cimport, nodecl> end
global function luaL_opt(L: *lua_State, func: auto, arg: cint, dflt: auto)
  if lua_isnoneornil(L, arg) ~= 0 then return dflt else return func(L, arg) end
end
global function luaL_loadbuffer(L: *lua_State, buff: cstring, sz: csize, name: cstring): cint <cimport, nodecl> end
global function luaL_pushfail(L: *lua_State) <cimport, nodecl> end
global function luaL_bufflen(B: *luaL_Buffer): csize <cimport, nodecl> end
global function luaL_buffaddr(B: *luaL_Buffer): cstring <cimport, nodecl> end
global function luaL_addchar(B: *luaL_Buffer,c: cchar) <cimport, nodecl> end
global function luaL_addsize(B: *luaL_Buffer,s: csize) <cimport, nodecl> end
global function luaL_buffsub(B: *luaL_Buffer,s: cint) <cimport, nodecl> end
global function luaL_prepbuffer(B: *luaL_Buffer): cstring <cimport, nodecl> end
]]
