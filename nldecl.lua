local gcc = require 'gcc'
local Emitter = require 'emitter'
local gccutils = require 'gccutils'
local chain = gccutils.chain

local nldecl = {}
local emitter = Emitter()
nldecl.emitter = emitter
nldecl.include_names = {}
nldecl.exclude_names = {}
nldecl.platform_names = {}
nldecl.include_macros = {}

nldecl.predeclared_names = {}
nldecl.declared_names = {}
nldecl.type_names = {}
nldecl.typedefs_names = {}

nldecl.USE_KNOWN_FIELDS = 1
nldecl.OMIT_ALL_FIELDS = 2

function nldecl.is_name_included(name)
  if nldecl.exclude_names[name] then
    -- ignored
    return false
  end
  if nldecl.include_names[name] then
    -- accept declaration
    return true
  end
  if #nldecl.exclude_names > 0 then
    for _,patt in ipairs(nldecl.exclude_names) do
      if name:match(patt) then
        return false
      end
    end
  end
  if #nldecl.include_names > 0 then
    for _,patt in ipairs(nldecl.include_names) do
      if name:match(patt) then
        return true
      end
    end
    return false
  else
    return true
  end
end

function nldecl.can_decl(declname, forwarddecl)
  if not declname or #declname == 0 then
    -- invalid declname
    return false
  end
  if not forwarddecl and nldecl.declared_names[declname] then
    -- already declared
    return false
  end
  if forwarddecl and nldecl.predeclared_names[declname] then
    -- already declared
    return false
  end
  return nldecl.is_name_included(declname)
end

local function visit(node, ...)
  -- try hooks first
  local kind = node:code()
  local visitor = nldecl[kind .. '_hook']
  if visitor and visitor(node, ...) then
    -- hooked
    return
  end
  visitor = nldecl[kind]
  if not visitor then
    error('cannot visit node ' .. kind)
  end
  visitor(node, ...)
end

local function scalar_type(node, decl)
  local typename = gccutils.get_id(node)
  if not decl and typename and nldecl.include_names[typename] then
    emitter:add(typename)
  else
    local nltype = gccutils.node_ctype2nltype(node)
    if not nltype then error('unknown ctype ' .. tostring(gccutils.get_id(node))) end
    emitter:add(nltype)
  end
end

nldecl.integer_type = scalar_type
nldecl.real_type = scalar_type

function nldecl.pointer_type(node, decl)
  local subnode = node:type()
  local typename = gccutils.get_id(node)
  if not decl and typename then
    emitter:add(typename)
  else
    local subnodeid = gccutils.get_id(subnode)
    if subnodeid == '__va_list_tag' then
      emitter:add('cvalist')
    elseif subnode:code() == 'integer_type' and gccutils.get_id(subnode:canonical()) == 'char' then
      emitter:add('cstring')
    elseif subnode:code() == 'void_type' then
      emitter:add('pointer')
    elseif subnode:code() == 'function_type' then
      visit(subnode)
    else
      emitter:add('*')
      visit(subnode)
    end
  end
end

function nldecl.boolean_type()
  emitter:add('boolean')
end

function nldecl.void_type()
  emitter:add('void')
end

local function visit_fields(node, canskipfields)
  local unnamedcount = 1
  for fieldnode in chain(node:fields()) do
    local fieldname = fieldnode:name() and fieldnode:name():value()
    local fieldtype = fieldnode:type()
    local fieldtypename = gccutils.get_inner_id(fieldtype)
    if canskipfields and fieldtypename and
      not gccutils.is_primitive_name(fieldtypename) and
      not nldecl.is_name_included(fieldtypename) then
      -- ignore
    else
      local annotations = {}
      if fieldnode:bit_field() then
        fieldtype = fieldnode:bit_field_type()
        --local bitfieldsize = fieldnode:size():value()
        --table.insert(annotations, string.format('bitsize(%d)', bitfieldsize))
      end
      if fieldname then
        fieldname = gccutils.normalize_name(fieldname)
        emitter:add_indent(fieldname .. ': ')
      else
        emitter:add_indent('__unnamed' .. unnamedcount .. ': ')
        unnamedcount = unnamedcount + 1
        --table.insert(annotations, 'cunnamed')
      end
      visit(fieldtype)
      if #annotations > 0 then
        emitter:add(' <'..table.concat(annotations, ', ')..'>')
      end
      if not fieldnode:chain() then -- last field
        emitter:add_ln()
      else
        emitter:add_ln(',')
      end
    end
  end
end

function nldecl.record_type(node, decl, canskipfields)
  local typename = gccutils.get_id(node)
  if not decl and typename then
    assert(not node:anonymous())
    emitter:add(typename)
    return
  elseif not node:fields() then
    emitter:add('record{}')
    return
  end
  emitter:add_ln('record{')
  emitter:inc_indent()
  visit_fields(node, canskipfields)
  emitter:dec_indent()
  emitter:add_indent('}')
end

function nldecl.union_type(node, decl, canskipfields)
  local typename = gccutils.get_id(node)
  if not decl and typename then
    assert(not node:anonymous())
    emitter:add(typename)
    return
  elseif not node:fields() then
    emitter:add('union{}')
    return
  end
  emitter:add_ln('union{')
  emitter:inc_indent()
  visit_fields(node, canskipfields)
  emitter:dec_indent()
  emitter:add_indent('}')
end

function nldecl.enumeral_type(node, decl)
  local typename = gccutils.get_id(node)
  if not decl then
    if typename then
      emitter:add(typename)
    else
      local nltype = gccutils.get_enum_nltype(node)
      emitter:add(nltype)
    end
    return
  end
  local nltype = gccutils.get_enum_nltype(node)
  emitter:add_ln('enum('..nltype..'){')
  emitter:inc_indent()
  for fieldnode in chain(node:values()) do
    local fieldname = fieldnode:purpose():value()
    local fieldvalue = fieldnode:value():value()
    emitter:add_indent(fieldname..' = '..fieldvalue)
    if not fieldnode:chain() then -- last node
      emitter:add_ln()
    else
      emitter:add_ln(',')
    end
  end
  emitter:dec_indent()
  emitter:add_indent('}')
end

function nldecl.vector_type(node)
  local subtype = node:type()
  local len = node:size():value() // subtype:size():value()
  emitter:add(string.format('[%d]',len))
  visit(subtype)
end

function nldecl.array_type(node)
  local len = 0
  local domain = node:domain()
  if domain then
    len = node:domain():max():value() + 1
  end
  emitter:add(string.format('[%d]', len))
  visit(node:type())
end

function nldecl.function_type(node)
  emitter:add('function(')
  local i = 1
  for argnode in chain(node:args()) do
    local argtype = argnode:value()
    if argtype:code() == 'void_type' then
      break
    end
    if i > 1 then emitter:add(', ') end
    visit(argnode:value())
    i = i + 1
  end
  if gccutils.has_cvarargs(node) then
    emitter:add(', ...: cvarargs')
  end
  emitter:add(')')
  local retnode = node:type()
  if retnode:code() ~= 'void_type' then
    emitter:add(': ')
    visit(retnode)
  end
end

function nldecl.function_decl(node)
  local funcname = node:name():value()
  if not nldecl.can_decl(funcname) then return end
  nldecl.declared_names[funcname] = true
  emitter:add('global function '..funcname..'(')
  local i = 1
  for argnode in chain(node:args()) do
    local argtype = argnode:type()
    if argtype:code() == 'void_type' then
      break
    end
    if i > 1 then emitter:add(', ') end
    local argname = gccutils.get_id(argnode)
    if not argname then
      argname = 'a'..i
    end
    argname = gccutils.normalize_name(argname)
    emitter:add(argname..': ')
    visit(argtype)
    i = i + 1
  end
  if gccutils.has_cvarargs(node:type()) then
    emitter:add(', ...: cvarargs')
  end
  emitter:add(')')
  local retnode = node:type():type()
  if retnode:code() ~= 'void_type' then
    emitter:add(': ')
    visit(retnode)
  end
  emitter:add_ln(' <cimport, nodecl> end')
end

function nldecl.var_decl(node)
  if not node:external() then return end
  local varname = gccutils.get_id(node)
  if not nldecl.can_decl(varname) then return end
  nldecl.declared_names[varname] = true
  local vartype = node:type()
  emitter:add('global '..varname..': ')
  visit(vartype)
  emitter:add_ln(' <cimport, nodecl>')
end

local function visit_type_def(typename, type, is_typedef)
  local is_record = type:code() == 'record_type'
  local is_union = type:code() == 'union_type'
  local is_enum = type:code() == 'enumeral_type'
  local is_pointer = type:code() == 'pointer_type'
  local is_function = is_pointer and type:type():code() == 'function_type'
  local is_scalar = type:code() == 'integer_type' or type:code() == 'real_type'
  local is_prefixed = (is_enum or is_record or is_union)
  local forwarddecl = (is_record or is_union) and not type:fields()
  if not nldecl.can_decl(typename, forwarddecl) then return end
  if nldecl.predeclared_names[typename] then
    emitter:add(typename..' ')
    nldecl.declared_names[typename] = true
  else
    emitter:add('global '..typename..': type ')

    if (not is_pointer or is_function) and not is_scalar then
      -- not a pointer to a function
      local annotations = {'cimport'}
      table.insert(annotations, 'nodecl')
      if forwarddecl then -- declaration without definition
        table.insert(annotations, 'forwarddecl')
        nldecl.predeclared_names[typename] = true
      else
        nldecl.declared_names[typename] = true
      end
      if is_record or is_union or is_enum then
        nldecl.type_names[type:main_variant()] = typename
      end
      if nldecl.platform_names[typename] then
        table.insert(annotations, 'cincomplete')
      end
      if is_enum then
        table.insert(annotations, 'using')
      end
      emitter:add(function()
        if is_prefixed and not is_typedef and not nldecl.typedefs_names[typename] then
          table.insert(annotations, 'ctypedef')
        end
        return '<'..table.concat(annotations,', ')..'> '
      end)
    end
  end
  emitter:add('= @')
  local decl = true
  if nldecl.platform_names[typename] == nldecl.OMIT_ALL_FIELDS then
    emitter:add('record{}')
  elseif nldecl.platform_names[typename] == nldecl.USE_KNOWN_FIELDS then
    local canskipfields = true
    visit(type, decl, canskipfields)
  else
    visit(type, decl)
  end
  emitter:add_ln()
end

local function visit_unnamed_enum_decl(node)
  local nltype = gccutils.get_enum_nltype(node)
  for fieldnode in chain(node:values()) do
    local fieldname = fieldnode:purpose():value()
    if nldecl.can_decl(fieldname) then
      local fieldvalue = fieldnode:value():value()
      emitter:add_indent('global '..fieldname..': '..nltype..' <comptime> = ')
      emitter:add_ln(fieldvalue)
    end
  end
end

-- typedefs
function nldecl.type_decl(node)
  local typename = node:name():value()
  nldecl.typedefs_names[typename] = true
  if not nldecl.can_decl(typename) then return end
  local type = node:type():main_variant()
  local name = gccutils.get_id(type) or nldecl.type_names[type]
  if typename == name then
    -- ignore
    return
  end
  local kind = type:code()
  if (kind == 'void_type' or
      kind == 'integer_type' or
      kind == 'real_type' or
      kind == 'array_type') and
     (not nldecl.include_names[typename]) then
    -- ignore aliases for these types
    return
  end

  if name and (nldecl.declared_names[name] or nldecl.predeclared_names[name]) then
    -- alias type name
    assert(typename and #typename > 0)
    emitter:add_indent_ln('global '..typename..': type = @'..name)
  else
    -- define the type
    visit_type_def(typename, type, true)
  end
end

function nldecl.parm_decl()
  -- ignored, already processed in function_decl
end

function nldecl.field_decl()
  -- ignored, already processed in record_type/union_type
end

local pending_type
local function finish_pending_type(node)
  local ret = false
  if not pending_type then return ret end
  if node and node:code() == 'type_decl' and pending_type:main_variant() == node:type():main_variant() then
    -- should be a typedef on an unnamed type
    local typename = gccutils.get_id(node)
    visit_type_def(typename, node:type(), true)
    ret = true
  elseif pending_type:code() == 'enumeral_type' then
    -- declare anonymous enum enum as comptime variables
    visit_unnamed_enum_decl(pending_type)
  end
  pending_type = nil
  return ret
end

local function eval_macro_value(value)
  if not value then return end
  value = value:gsub('%s+$','') -- right trim
  value = value:gsub('^%(',''):gsub('%)$','') -- trim parenthesis
  local intvalue = value:lower():gsub('u?l?l?$', '')
  local floatvalue = value:lower():gsub('f$', '')
  if intvalue:match('^-?%d+$') then
    return intvalue
  elseif intvalue:match('^-?0x%x+$') then
    return intvalue
  elseif floatvalue:match('^-?%d+%.%d+$') then
    return floatvalue
  elseif value:match('^"[^"\\]+"$') then
    return value
  end
end

local function process_macros()
  local cppcmd = 'gcc -E -P -dD ' .. gcc.get_main_input_filename()
  local file = assert(io.popen(cppcmd))
  for line in file:lines() do
    local name, value = line:match('^#define ([A-Za-z0-9_]+)%s+([^%s]+.*)')
    local foundnltype
    if name then -- is a macro constant
      -- find in customized macros
      for nltype,patts in pairs(nldecl.include_macros) do
        for patt,forcevalue in pairs(patts) do
          if name == patt and nldecl.can_decl(name) then
            foundnltype = nltype
            if forcevalue == false then
              value = nil
            elseif forcevalue ~= true then
              value = tostring(forcevalue)
            end
            goto just_found
          end
        end
      end
      -- find in macro patterns
      for nltype,patts in pairs(nldecl.include_macros) do
        for _,patt in ipairs(patts) do
          if name:match(patt) and nldecl.can_decl(name) then
            foundnltype = nltype
            goto just_found
          end
        end
      end
    end
::just_found::
    if foundnltype then
      local parsedvalue = eval_macro_value(value)
      if parsedvalue then
        emitter:add_ln('global '..name..': '..foundnltype..' <comptime> = '..parsedvalue)
      else
        emitter:add_ln('global '..name..': '..foundnltype..' <cimport, nodecl, const>')
      end
    end
  end
  file:close()
end

function nldecl.install()
  gcc.set_asm_file_name(gcc.HOST_BIT_BUCKET)
  gcc.register_callback(gcc.PLUGIN_FINISH_DECL, function(node)
    if finish_pending_type(node) then return end
    visit(node)
  end)
  gcc.register_callback(gcc.PLUGIN_FINISH_TYPE, function(node)
    finish_pending_type()
    local typename = gccutils.get_id(node)
    if typename then

      visit_type_def(typename, node)
    else
      -- schedule to be declared on next PLUGIN_FINISH_DECL,
      -- because maybe the name is there
      pending_type = node
    end
  end)
  gcc.register_callback(gcc.PLUGIN_PRE_GENERICIZE, function(node)
    if finish_pending_type(node) then return end
    visit(node)
  end)
  gcc.register_callback(gcc.PLUGIN_START_UNIT, function()
    if nldecl.prepend_code then
      emitter:add(nldecl.prepend_code)
    end
  end)
  gcc.register_callback(gcc.PLUGIN_FINISH_UNIT, function()
    finish_pending_type()
    process_macros()
    if nldecl.append_code then
      emitter:add(nldecl.append_code)
    end
    if nldecl.on_finish then
      nldecl.on_finish()
    else
      io.stdout:write(emitter:generate())
      io.stdout:flush()
    end
  end)
end

nldecl.install()


return nldecl
