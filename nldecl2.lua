tdump()
local parse_c11 = require 'c11'
local lpegrex = require 'lpegrex'
local tabler = require 'nelua.utils.tabler'
local fs = require 'nelua.utils.fs'
local Emitter = require 'nelua.emitter'

-- TODO: handle structs, unions, enums (with typedef!)
-- TODO: handle function declarations
-- TODO: handle function definitions

-------------------------------------------------------------------------------
-- Binding context

local BindingContext = {}
local BindingContext_mt = {__index = BindingContext}

function BindingContext.create()
  return setmetatable({
    bindings_ast = {},
    typedefs_by_name = {},
    typedefs_by_type = {},
    compound_types_by_name = {},
    compound_types_by_type = {},
    visitors = {}
  }, BindingContext_mt)
end

function BindingContext:traverse_node(node, ...)
  self.visitors[node.tag](self, node, ...)
end

function BindingContext:traverse_nodes(node, ...)
  for _,childnode in ipairs(node) do
    self.visitors[childnode.tag](self, childnode, ...)
  end
end

-------------------------------------------------------------------------------
-- Binding pass

local function find_child_node_by_tag(node, tag)
  for _,childnode in ipairs(node) do
    if childnode.tag == tag then
      return childnode
    end
  end
end

local function parse_extensions(node, attr)
  if node.tag == 'extension-specifiers' then
    for _,extnode in ipairs(node) do
      parse_extensions(extnode, attr)
    end
  elseif node.tag == 'extension-specifier' then
    local extnode = node[1]
    if extnode.tag == 'extension' then
      attr.__extension__ = true
    elseif extnode.tag == 'asm' then
      -- TODO: fill asm attribute?
    elseif extnode.tag == 'attribute' then
      for _,attrib in ipairs(extnode) do
        local attrname = attrib[1][1]
        attr[attrname] = true
        -- TODO: parse arguments
      end
    end
  else
    error('unhandled '..node.tag)
  end
end

local function parse_qualifiers(node, attr)
  if node.tag == 'type-qualifier-list' then
    for _,qualifier in ipairs(node) do
      parse_qualifiers(qualifier, attr)
    end
    return
  end
  local qualifier = node[1]
  if type(qualifier) == 'string' then
    attr[qualifier] = true
  elseif qualifier.tag == 'extension-specifier' then
    parse_extensions(qualifier, attr)
  else
    error('unhandled '..qualifier.tag)
  end
end

local function parse_constant_expression(node)
  if node.tag == 'integer-constant' then
    local value = node[1]
    if value:find('^0x[0-9a-fA-F]+$') then -- hexadecimal number
      value = tonumber(value)
    elseif value:find('^-?[0-9]+$') then -- decimal number
      value = tonumber(value)
    else -- cannot calculate
      return nil
    end
    return value
  end
end

local function parse_struct_or_union(context, node, attr)
  local kind = node[1] -- 'struct' or 'union'
  local extensions = find_child_node_by_tag(node, 'extension-specifiers')
  local identifier = find_child_node_by_tag(node, 'identifier')
  local fieldlist = find_child_node_by_tag(node, 'struct-declaration-list')
  if extensions then
    parse_extensions(extensions, attr)
  end
  local name, fullname, type
  if identifier then -- has name (not anonymous)
    name = identifier[1]
    fullname = kind..' '..name
  end
  if fieldlist then -- has fields (not opaque)
    local tag = 'C'..kind:sub(1,1):upper()..kind:sub(2)..'Type' -- 'CStructType' or 'CUnionType'
    type = {tag=tag}
    table.insert(context.bindings_ast, type)
  end
  if fullname and type then
    context.compound_types_by_name[fullname] = type
    context.compound_types_by_type[type] = fullname
  end
  assert(fullname or type, 'struct must have a name or declaration')
  return fullname or type
end

local function parse_enum(context, node, attr)
  local extensions = find_child_node_by_tag(node, 'extension-specifiers')
  local identifier = find_child_node_by_tag(node, 'identifier')
  local enumlist = find_child_node_by_tag(node, 'enumerator-list')
  if extensions then
    parse_extensions(extensions, attr)
  end
  local name, fullname, type
  if identifier then -- has name (not anonymous)
    name = identifier[1]
    fullname = 'enum '..name
  end
  if enumlist then -- has fields (not opaque)
    local fields = {}
    local lastvalue = 0
    for _,enumfield in ipairs(enumlist) do
      local fieldname = enumfield[1][1]
      local fieldexpr = enumfield[2]
      local fieldvalue
      if fieldexpr then
        -- TODO: handle constant expressions
        fieldvalue = parse_constant_expression(fieldexpr)
      elseif lastvalue then
        fieldvalue = lastvalue + 1
      end
      table.insert(fields, {fieldname, fieldvalue})
      lastvalue = fieldvalue
    end
    type = {tag='CEnum', name, fields}
    table.insert(context.bindings_ast, type)
  end
  if fullname and type then
    context.compound_types_by_name[fullname] = type
    context.compound_types_by_type[type] = fullname
  end
  assert(fullname or type, 'struct must have a name or declaration')
  return fullname or type
end

-- Retrieves Nelua type and its attr from declaration specifiers node.
local function parse_type(context, node, attr)
  assert(node.tag == 'declaration-specifiers')
  local ctype
  local widthprefix, signprefix, complexsuffix, long
  for _,specifier in ipairs(node) do
    if specifier.tag == 'type-specifier' then
      local typespecifier = specifier[1]
      if typespecifier == 'long' then
        widthprefix = long and 'long long' or 'long'
        ctype = ctype or 'int'
        long = true
      elseif typespecifier == 'short' then
        widthprefix = 'short'
        ctype = ctype or 'int'
      elseif typespecifier == 'unsigned' then
        signprefix = 'unsigned'
        ctype = ctype or 'int'
      elseif typespecifier == 'signed' then
        signprefix = 'signed'
        ctype = ctype or 'int'
      elseif typespecifier == '_Complex' then
        complexsuffix = '_Complex'
        ctype = ctype or 'double'
      elseif typespecifier == '_Imaginary' then
        complexsuffix = '_Imaginary'
        ctype = ctype or 'double'
      elseif type(typespecifier) == 'string' then
        ctype = typespecifier
      elseif typespecifier.tag == 'struct-or-union-specifier' then
        ctype = parse_struct_or_union(context, typespecifier, attr)
      elseif typespecifier.tag == 'enum-specifier' then
        ctype = parse_enum(context, typespecifier, attr)
      elseif typespecifier.tag == 'typedef-name' then
        ctype = typespecifier[1][1]
      elseif specifier.tag == 'atomic-type-specifier' then
        -- TODO: handle _Atomic(x)
      elseif specifier.tag == 'typeof' then
        -- TODO: handle __typeof__(x)?
      else
        error('unhandled '..typespecifier.tag)
      end
    elseif specifier.tag == 'type-qualifier' or
           specifier.tag == 'storage-class-specifier' or
           specifier.tag == 'function-specifier' then
      parse_qualifiers(specifier, attr)
    elseif specifier.tag == 'alignment-specifier' then
      -- TODO: handle _Alignas
    else
      error('unhandled '..specifier.tag)
    end
  end
  if type(ctype) == 'string' then
    local fullctype = ctype
    if signprefix and not (signprefix == 'signed' and ctype ~= 'char') then
      fullctype = signprefix..' '..fullctype
    end
    if widthprefix then
      fullctype = widthprefix..' '..fullctype
    end
    if complexsuffix then
      fullctype = fullctype..' '..complexsuffix
    end
    return {tag='CType', fullctype}, attr
  else -- unnamed struct/union/enum
    assert(ctype)
    return ctype
  end
end

local function parse_declarator(context, node, firsttype, attr)
  if node.tag == 'identifier' then -- identifier associated with the type
    return firsttype, node[1]
  elseif node.tag == 'typedef-identifier' then -- typedef type
    return firsttype, node[1][1]
  elseif node.tag == 'pointer' then -- pointer type
    local lastnode = node[#node]
    local subnode = lastnode and lastnode.tag ~= 'type-qualifier-list' and lastnode
    local qualifiers = find_child_node_by_tag(node, 'type-qualifier-list')
    if qualifiers then
      parse_qualifiers(qualifiers, attr)
    end
    if subnode then -- pointer with an identifier
      return parse_declarator(context, subnode, {tag='CPointerType', firsttype}, attr)
    else -- pointer without an identifier (used by function pointers without a name)
      return {tag='CPointerType'}, nil
    end
  elseif node.tag == 'declarator-subscript' then -- fixed array type
    local subnode = node[1]
    -- TODO: do we need to parse specifiers?
    local subtype, name = parse_declarator(context, subnode, firsttype, attr)
    assert(subtype and name)
    local lennode = #node > 1 and node[#node]
    local len
    if lennode then -- size is available
      -- TODO: handle other node cases than integer-constant?
      assert(lennode.tag == 'integer-constant', 'unexpected node in fixed array type')
      len = lennode[1]
    end
    local type = {tag='CArrayType', subtype, len}
    -- invert len sizes for multidimensional arrays
    local topsubtype = type
    while subtype.tag == 'CArrayType' do
      subtype[2], topsubtype[2] = topsubtype[2], subtype[2]
      topsubtype, subtype = subtype, subtype[1]
    end
    return type, name
  elseif node.tag == 'declarator-parameters' then -- function type
    local namenode, paramlist = node[1], node[2]
    local placeholdertype, name = parse_declarator(context, namenode, {tag='CPlaceholder'}, attr)
    local params = {}
    if paramlist and paramlist.tag == 'parameter-type-list' then
      for _,paramdecl in ipairs(paramlist) do
        if paramdecl.tag == 'parameter-declaration' then
          local specifiers, declarator = paramdecl[1], paramdecl[2]
          local paramattr = {}
          local firstparamtype = parse_type(context, specifiers, paramattr)
          if declarator then
            local paramtype, paramname = parse_declarator(context, declarator, firstparamtype, paramattr)
            table.insert(params, {tag='CParamDecl', attr=paramattr, paramname, paramtype})
          else -- parameter without a name
            table.insert(params, {tag='CParamDecl', attr=paramattr, nil, firstparamtype})
          end
        elseif paramdecl.tag == 'parameter-varargs' then
          table.insert(params, {tag='CVarargsType'})
        end
      end
    -- elseif paramlist and paramlist.tag == 'identifier-list' then
    elseif paramlist then
      -- TODO: handle identifier-list
      error('unhandled '..paramlist.tag)
    end
    if placeholdertype.tag == 'CPlaceholder' then -- function declaration
      return {tag='CFuncDecl', name, params, firsttype}, name
    elseif placeholdertype.tag == 'CPointerType' and #placeholdertype == 0 then -- function pointer without identifier
      return {tag='CFuncType', params, firsttype}, nil
    elseif placeholdertype.tag == 'CPointerType' and placeholdertype[1].tag == 'CPlaceholder' then -- function pointer
      return {tag='CFuncType', params, firsttype}, name
    else
      error('unhandled '..placeholdertype.tag)
    end
  elseif node.tag == 'declarator' then
    local extensionspecifiers = node[2]
    if extensionspecifiers then
      parse_extensions(extensionspecifiers, attr)
    end
    return parse_declarator(context, node[1], firsttype, attr)
  else
    error('unhandled '..node.tag)
  end
end

local parse_bindings_visitors = {}

parse_bindings_visitors['type-declaration'] = function(context, node)
  local specifiers, initdeclatorlist = node[1], node[2]
  local firstattr = {}
  local firsttype = parse_type(context, specifiers, firstattr)
  if initdeclatorlist then -- variable declaration
    for _,initdeclarator in ipairs(initdeclatorlist) do
      local declarator = initdeclarator[1]
      -- TODO: consider init constants?
      local attr = tabler.copy(firstattr)
      local type, name = parse_declarator(context, declarator, firsttype, attr)
      assert(type and name)
      if type.tag == 'CFuncDecl' then
        table.insert(context.bindings_ast, type)
      else
        table.insert(context.bindings_ast, {tag='CVarDecl', attr=attr, name, type})
      end
    end
  end
end

parse_bindings_visitors['typedef-declaration'] = function(context, node)
  local specifiers = node[1]
  local firstattr = {}
  local firsttype = parse_type(context, specifiers, firstattr)
  for i=2,#node do
    local declarator = node[i]
    local attr = tabler.copy(firstattr)
    local type, name = parse_declarator(context, declarator, firsttype, attr)
    assert(type and name)
    context.typedefs_by_name[name] = type
    context.typedefs_by_type[type] = name
    table.insert(context.bindings_ast, {tag='CTypedef', attr=attr, name, type})
  end
end

parse_bindings_visitors['function-definition'] = function(context, node)
  -- TODO
end

parse_bindings_visitors['declaration'] = function(context, node)
  context:traverse_nodes(node)
end

local function parse_c_bindings(c_ast)
  assert(c_ast.tag == 'translation-unit')
  local context = BindingContext.create()
  context.visitors = parse_bindings_visitors
  context.c_ast = c_ast
  context:traverse_nodes(c_ast)
  return context
end

-------------------------------------------------------------------------------
-- Generator

local ctype_to_nltype = {
  -- primitive C integral types
  ['char'] = 'cchar',
  ['signed char'] = 'cschar',
  ['short int'] = 'cshort',
  ['int'] = 'cint',
  ['long int'] = 'clong',
  ['long long int'] = 'clonglong',
  ['unsigned char'] = 'cuchar',
  ['short unsigned int'] = 'cushort',
  ['unsigned int'] = 'cuint',
  ['long unsigned int'] = 'culong',
  ['long long unsigned int'] = 'culonglong',
  ['long double'] = 'clongdouble',
  ['long double _Complex'] = 'clongcomplex',
  -- fixed integral types
  ['intptr_t'] = 'isize',
  ['int8_t'] = 'int8',
  ['int16_t'] = 'int16',
  ['int32_t'] = 'int32',
  ['int64_t'] = 'int64',
  ['__int128'] = 'int128',
  ['uintptr_t'] = 'usize',
  ['uint8_t'] = 'uint8',
  ['uint16_t'] = 'uint16',
  ['uint32_t'] = 'uint32',
  ['uint64_t'] = 'uint64',
  ['unsigned __int128'] = 'uint128',
  -- float types
  ['float'] = 'float32',
  ['double'] = 'float64',
  ['_Float128'] = 'float128',
  ['_Float64x'] = 'float64',    ['_Float64'] = 'float64',
  ['_Float32x'] = 'float32',    ['_Float32'] = 'float32',
  -- complex types
  ['float _Complex'] = 'complex32',
  ['double _Complex'] = 'complex64',
  ['_Float128 _Complex'] = 'complex128',
  ['_Float64x _Complex'] = 'complex64',    ['_Float64 _Complex'] = 'complex64',
  ['_Float32x _Complex'] = 'complex32',    ['_Float32 _Complex'] = 'complex32',
  -- boolean types
  ['bool'] = 'boolean', ['_Bool'] = 'boolean',
  -- special GCC types
  ['void'] = 'void',
  -- special C types
  ['ptrdiff_t'] = 'cptrdiff',
  ['size_t'] = 'csize',
  ['clock_t'] = 'cclock_t',  ['__clock_t'] = 'cclock_t',
  ['time_t'] = 'ctime_t', ['__time_t'] = 'ctime_t',
  ['wchar_t'] = 'cwchar_t', ['__wchar_t'] = 'cwchar_t',
  -- C valist support
  ['__gnuc_va_list'] = 'cvalist', ['__builtin_va_list'] = 'cvalist',
}

local cattr_to_nlattr = {
  -- type qualifiers
  ['const'] = 'const',
  ['restrict'] = 'restrict',
  ['volatile'] = 'volatile',
  ['_Atomic'] = 'atomic',
  -- storage specifiers
  ['extern'] = 'extern',
  ['static'] = 'static',
  ['_Thread_local'] = 'threadlocal',
  ['__thread'] = 'threadlocal',
  ['register'] = 'register',
  ['auto'] = nil,
  -- function specifiers
  ['inline'] = 'inline',
  ['_Noreturn'] = 'noreturn',
}

local reserved_names = {
  ["and"] = true,
  ["break"] = true,
  ["do"] = true,
  ["else"] = true,
  ["elseif"] = true,
  ["end"] = true,
  ["for"] = true,
  ["false"] = true,
  ["function"] = true,
  ["goto"] = true,
  ["if"] = true,
  ["in"] = true,
  ["local"] = true,
  ["nil"] = true,
  ["not"] = true,
  ["or"] = true,
  ["repeat"] = true,
  ["return"] = true,
  ["then"] = true,
  ["true"] = true,
  ["until"] = true,
  ["while"] = true,
  -- nelua additional keywords
  ["case"] = true,
  ["continue"] = true,
  ["defer"] = true,
  ["global"] = true,
  ["switch"] = true,
  ["nilptr"] = true,
  ["fallthrough"] = true,
}

local function normalize_param_name(name)
  name = name:gsub('^__', '')
  if reserved_names[name] then
    return name:sub(1,1):upper()..name:sub(2)
  end
  return name
end

local generate_bindings_visitors = {}

function generate_bindings_visitors.CType(context, node, emitter)
  local ctypename = node[1]
  local nltypename = ctype_to_nltype[ctypename] or ctypename
  local hasspaces = not not nltypename:find(' ', 1, true)
  if hasspaces then -- must translate to another type
    local type = context.compound_types_by_name[ctypename]
    if type then
      local typedefname = context.typedefs_by_type[type]
      if typedefname then
        nltypename = typedefname
      end
    end
  end
  -- TODO: handle compound types without typedefs
  -- assert(not nltypename:find(' ', 1, true), nltypename)
  emitter:add(nltypename)
end

function generate_bindings_visitors.CPointerType(context, node, emitter)
  local subtypenode = node[1]
  local subcname = subtypenode and subtypenode.tag == 'CType' and subtypenode[1]
  if subcname == 'void' or not subtypenode then
    emitter:add('pointer')
  elseif subcname == 'char' then
    emitter:add('cstring')
  else
    emitter:add('*')
    if subtypenode then
      context:traverse_node(node[1], emitter)
    else
      emitter:add('void')
    end
  end
end

function generate_bindings_visitors.CArrayType(context, node, emitter, argi)
  local subtype, len = node[1], node[2]
  if len then
    if argi then -- function parameter pass by pointer
      emitter:add('*')
    end
    emitter:add('['..len..']')
  else -- actually a pointer to an array
    emitter:add('*[0]')
  end
  context:traverse_node(subtype, emitter)
end

function generate_bindings_visitors.CVarargsType(context, node, emitter)
  emitter:add('...: cvarargs')
end

function generate_bindings_visitors.CParamDecl(context, node, emitter, argi)
  local name, typenode = node[1], node[2]
  if name then
    emitter:add(normalize_param_name(name)..': ')
  elseif argi then
    emitter:add('a'..argi..': ')
  end
  context:traverse_node(typenode, emitter, argi)
end

local function emit_function_type_paren(context, node, emitter, params, retnode)
  emitter:add('(')
  for i,paramnode in ipairs(params) do
    if paramnode.tag == 'CParamDecl' and
       paramnode[2].tag == 'CType' and
       paramnode[2][1] == 'void' then -- stop at first void
      break
    end
    if i > 1 then emitter:add(', ') end
    context:traverse_node(paramnode, emitter, i)
  end
  emitter:add('): ')
  context:traverse_node(retnode, emitter)
end

function generate_bindings_visitors.CFuncType(context, node, emitter)
  local params, retnode = node[1], node[2]
  emitter:add('function')
  emit_function_type_paren(context, node, emitter, params, retnode)
end

function generate_bindings_visitors.CFuncDecl(context, node, emitter)
  local name, params, retnode = node[1], node[2], node[3]
  emitter:add('global function '..name)
  emit_function_type_paren(context, node, emitter, params, retnode)
  emitter:add_ln(' <cimport,nodecl> end')
end

function generate_bindings_visitors.CStructType(context, node, emitter)
end

function generate_bindings_visitors.CUnionType(context, node, emitter)
end

function generate_bindings_visitors.CTypedef(context, node, emitter)
  local name, typenode = node[1], node[2]
  if ctype_to_nltype[name] then -- ignore typedefs for builtin types
    return
  end
  emitter:add('global '..name..': type <cimport,nodecl> = @')
  context:traverse_node(typenode, emitter)
  emitter:add_ln()
end

function generate_bindings_visitors.CEnum(context, node)
end

function generate_bindings_visitors.CVarDecl(context, node, emitter)
  local name, typenode = node[1], node[2]
  emitter:add('global '..name..': ')
  context:traverse_node(typenode, emitter)
  emitter:add(' <cimport,nodecl>')
  emitter:add_ln()
end

local function generate_nelua_bindings(context, node)
  local emitter = Emitter()
  context.emitter = emitter
  context.visitors = generate_bindings_visitors
  context:traverse_nodes(context.bindings_ast, emitter)
  print(emitter:generate())
end

-------------------------------------------------------------------------------
-- Test

tdump('init')

-- Read input file contents
local source = [[
//extern int i;
//struct S s;
//enum E e;
//unsigned long long int ull;
//int a[4];
//int a[0];
//int a[];
//int aa[4][3][2][1];
//typedef int TI, *PI, AI[4];
//int *pi;
//int **ppi;
//int ***pppi;
int (*pf)(void);
////int (*pf2[4][3])();
//void fv();
//void f(void);
//void f(int x);
//void f(x);
//void f(void(*)(void));
//struct f f(void);
//void f(int* restrict x);
//struct S {int x;};
//enum MyEnum {
//  MyEnumA,
//  MyEnumB
//};
//typedef enum MyEnum MyEnum;
//static void f() {}
//struct S {
//  int x;
//};
//int a;

//void* tss_get(unsigned int __tss_id);
//void f(void);
void* (*f)(void*);
extern double erand48 (unsigned short int __xsubi[3])  ;

extern char *__stpcpy (char *restrict __dest, const char *restrict __src)
      ;
]]

-- source = fs.readfile('pt.c')
tdump('load source')

-- Parse C11 source
local ast = parse_c11(source)
dump(lpegrex.prettyast(ast))
-- tdump('parse')

local cbindings = parse_c_bindings(ast)
tdump('list bindings')

dump(lpegrex.prettyast(cbindings.bindings_ast))

generate_nelua_bindings(cbindings)
tdump('generate bindings')

-- traverse_node(ast)

-- dump(lpegrex.prettyast(cbindings.ast))
-- dump(decls)
