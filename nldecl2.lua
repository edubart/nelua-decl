local lpegrex = require 'nelua.thirdparty.lpegrex'
local tabler = require 'nelua.utils.tabler'
local fs = require 'nelua.utils.fs'
local Emitter = require 'nelua.emitter'

-- TODO: handle structs, unions fields
-- TODO: handle function definitions
-- TODO: force include used names

--[[
This grammar is based on the C11 specification.
As seen in https://port70.net/~nsz/c/c11/n1570.html#A.1
Some extensions to use with GCC/Clang were also added.
]]
local Grammar = [==[
chunk <- SHEBANG? SKIP translation-unit (!.)^UnexpectedSyntax

SHEBANG       <-- '#!' (!LINEBREAK .)* LINEBREAK?

COMMENT       <-- LONG_COMMENT / SHRT_COMMENT
LONG_COMMENT  <-- '/*' (!'*/' .)* '*/'
SHRT_COMMENT  <-- '//' (!LINEBREAK .)* LINEBREAK?
DIRECTIVE     <-- '#' ('\' LINEBREAK / !LINEBREAK .)*

SKIP          <-- (%s+ / COMMENT / DIRECTIVE / `__extension__`)*
LINEBREAK     <-- %nl %cr / %cr %nl / %nl / %cr

NAME_SUFFIX   <-- identifier-suffix

--------------------------------------------------------------------------------
-- Identifiers

identifier <== !KEYWORD
  {identifier-nondigit identifier-suffix?} SKIP

identifier-suffix <- (identifier-nondigit / digit)+
identifier-nondigit <- [a-zA-Z_] / universal-character-name

digit <- [0-9]

--------------------------------------------------------------------------------
-- Universal character names

universal-character-name <--
 '\u' hex-quad /
 '\U' hex-quad^2
hex-quad <-- hexadecimal-digit^4

--------------------------------------------------------------------------------
-- Constants

constant <-- (
    floating-constant /
    integer-constant /
    enumeration-constant /
    character-constant
  ) SKIP

integer-constant <==
  {octal-constant integer-suffix?} /
  {hexadecimal-constant integer-suffix?} /
  {decimal-constant integer-suffix?}

decimal-constant <-- digit+
octal-constant <-- '0' octal-digit+
hexadecimal-constant <-- hexadecimal-prefix hexadecimal-digit+
hexadecimal-prefix <-- '0' [xX]
octal-digit <--  [0-7]
hexadecimal-digit <-- [0-9a-fA-F]

integer-suffix <--
  unsigned-suffix (long-long-suffix / long-suffix)? /
  (long-long-suffix / long-suffix) unsigned-suffix?

unsigned-suffix <-- [uU]
long-suffix <-- [lL]
long-long-suffix <-- 'll' / 'LL'

floating-constant <==
  {decimal-floating-constant} /
  {hexadecimal-floating-constant}

decimal-floating-constant <--
  (
    fractional-constant exponent-part? /
    digit-sequence exponent-part
  ) floating-suffix?

hexadecimal-floating-constant <--
 hexadecimal-prefix
 (hexadecimal-fractional-constant / hexadecimal-digit-sequence)
 binary-exponent-part floating-suffix?

fractional-constant <--
  digit-sequence? '.' digit-sequence /
  digit-sequence '.'

exponent-part <--[eE] sign? digit-sequence
sign <-- [+-]
digit-sequence <-- digit+

hexadecimal-fractional-constant <--
 hexadecimal-digit-sequence? '.' hexadecimal-digit-sequence /
 hexadecimal-digit-sequence '.'

binary-exponent-part <-- [pP] sign? digit-sequence
hexadecimal-digit-sequence <-- hexadecimal-digit+
floating-suffix <-- [flFL]

enumeration-constant <--
  identifier

character-constant <==
 "'" {c-char-sequence} "'" /
 "L'" {c-char-sequence} "'" /
 "u'" {c-char-sequence} "'" /
 "U'" {c-char-sequence} "'"

c-char-sequence <-- c-char+
c-char <--
  [^'\%cn%cr] /
  escape-sequence

escape-sequence <--
 simple-escape-sequence /
 octal-escape-sequence /
 hexadecimal-escape-sequence /
 universal-character-name

simple-escape-sequence <--
 "\'" / '\"' / "\?" / "\\" /
 "\a" / "\b" / "\f" / "\n" / "\r" / "\t" / "\v"

octal-escape-sequence <-- '\' octal-digit^-3
hexadecimal-escape-sequence <-- '\x' hexadecimal-digit+

--------------------------------------------------------------------------------
-- String literals

string-literal <==
  encoding-prefix? string-suffix+
string-suffix <-- '"' {s-char-sequence?} '"' SKIP
encoding-prefix <-- 'u8' / 'u' / 'U' / 'L'
s-char-sequence <-- s-char+
s-char <- [^"\%cn%cr] / escape-sequence

--------------------------------------------------------------------------------
-- Expressions

primary-expression <--
  type-name /
  identifier /
  constant /
  string-literal /
  statement-expression /
  `(` expression `)` /
  generic-selection

statement-expression <==
  '({'SKIP (declaration / statement)* '})'SKIP

generic-selection <==
  `_Generic` @`(` @assignment-expression @`,` @generic-assoc-list @`)`

generic-assoc-list <==
  generic-association (`,` @generic-association)*

generic-association <==
  type-name `:` @assignment-expression /
  {`default`} `:` @assignment-expression

postfix-expression <--
  (postfix-expression-prefix postfix-expression-suffix*) ~> rfoldright

postfix-expression-prefix <--
  (
    type-initializer  /
    primary-expression
  )

type-initializer <==
  `(` type-name `)` `{` initializer-list? `,`? `}`

postfix-expression-suffix <--
  array-subscript /
  argument-expression /
  struct-or-union-member /
  pointer-member /
  post-increment /
  post-decrement

array-subscript <== `[` expression `]`
argument-expression <== `(` argument-expression-list? `)`
struct-or-union-member <== `.` identifier
pointer-member <== `->` identifier
post-increment <== `++`
post-decrement <== `--`

argument-expression-list <==
  assignment-expression (`,` assignment-expression)*

unary-expression <--
  unary-op /
  postfix-expression
unary-op <==
  ({`++`} / {`--`}) @unary-expression /
  ({`sizeof`}) unary-expression /
  ({`&`} / {`+`} / {`-`} / {`~`} / {`!`}) @cast-expression /
  {`*`} cast-expression /
  ({`sizeof`} / {`_Alignof`}) `(` type-name `)`

cast-expression <--
  op-cast /
  unary-expression
op-cast:binary-op <==
  `(` $'cast' type-name `)` cast-expression

multiplicative-expression <--
  (cast-expression op-multiplicative*) ~> foldleft
op-multiplicative:binary-op <==
  ({`/`} / {`%`}) @cast-expression /
  {`*`} cast-expression

additive-expression <--
  (multiplicative-expression op-additive*) ~> foldleft
op-additive:binary-op <==
  ({`+`} / {`-`}) @multiplicative-expression

shift-expression <--
  (additive-expression op-shift*) ~> foldleft
op-shift:binary-op <==
  ({`<<`} / {`>>`}) @additive-expression

relational-expression <--
  (shift-expression op-relational*) ~> foldleft
op-relational:binary-op <==
  ({`<=`} / {`>=`} / {`<`} / {`>`}) @shift-expression

equality-expression <--
  (relational-expression op-equality*) ~> foldleft
op-equality:binary-op <==
  ({`==`} / {`!=`}) @relational-expression

AND-expression <--
  (equality-expression op-AND*) ~> foldleft
op-AND:binary-op <==
  {`&`} @equality-expression

exclusive-OR-expression <--
  (AND-expression op-OR*) ~> foldleft
op-OR:binary-op <==
  {`^`} @AND-expression

inclusive-OR-expression <--
  (exclusive-OR-expression op-inclusive-OR*) ~> foldleft
op-inclusive-OR:binary-op <==
  {`|`} @exclusive-OR-expression

logical-AND-expression <--
  (inclusive-OR-expression op-logical-AND*) ~> foldleft
op-logical-AND:binary-op <==
  {'&&'} SKIP @inclusive-OR-expression

logical-OR-expression <--
  (logical-AND-expression op-logical-OR*) ~> foldleft
op-logical-OR:binary-op <==
  {`||`} @logical-AND-expression

conditional-expression <--
  (logical-OR-expression op-conditional?) ~> foldleft
op-conditional:ternary-op <==
  {`?`} @expression @`:` @conditional-expression

op-assignment:binary-op <==
  unary-expression assignment-operator @assignment-expression
assignment-expression <--
  op-assignment /
  conditional-expression

assignment-operator <--
  {`=`} /
  {`*=`} /
  {`/=`} /
  {`%=`} /
  {`+=`} /
  {`-=`} /
  {`<<=`} /
  {`>>=`} /
  {`&=`} /
  {`^=`} /
  {`|=`}

expression <==
  assignment-expression (`,` @assignment-expression)*

constant-expression <--
  conditional-expression

--------------------------------------------------------------------------------
-- Declarations

declaration <==
  (
    typedef-declaration /
    type-declaration /
    static_assert-declaration
  )
  @`;`

extension-specifiers <==
  extension-specifier+

extension-specifier <==
  attribute / asm / extension / tg-promote

attribute <==
  (`__attribute__` / `__attribute`)
  `(` @`(` attribute-item (`,` attribute-item)* @`)` @`)`

tg-promote <==
  `__tg_promote` @`(` (expression / parameter-varargs) @`)`

attribute-item <==
  identifier (`(` expression (`,` expression)* `)`)?

asm <==
  (`__asm` / `__asm__`)
  (`__volatile__` / `volatile`)?
  `(` asm-argument (`,` asm-argument)* @`)`

asm-argument <-- (
    string-literal /
    {`:`} /
    expression
  )+

extension <==
  `__extension__`

typedef-declaration <==
  `typedef` @declaration-specifiers (typedef-declarator (`,` @typedef-declarator)*)?

type-declaration <==
  declaration-specifiers init-declarator-list?

declaration-specifiers <== (
    storage-class-specifier /
    type-specifier /
    type-qualifier /
    function-specifier /
    alignment-specifier
  )+

init-declarator-list <==
  init-declarator (`,` init-declarator)*

init-declarator <==
  declarator (`=` initializer)?

storage-class-specifier <==
  {`extern`} /
  {`static`} /
  {`_Thread_local`} /
  {`auto`} /
  {`register`} /
  {`__thread`}

type-specifier <==
  {`void`} /
  {`char`} /
  {`short`} /
  {`int`} /
  {`long`} /
  {`float`} /
  {`double`} /
  {`signed`} /
  {`unsigned`} /
  {`_Bool`} /
  {`_Complex`} /
  {`_Imaginary`} /
  atomic-type-specifier /
  struct-or-union-specifier /
  enum-specifier /
  typedef-name /
  typeof

typeof <==
  `__typeof__` @argument-expression

struct-or-union-specifier <==
  struct-or-union extension-specifiers? identifier? (`{` struct-declaration-list `}`)?

struct-or-union <--
  {`struct`} /
  {`union`}

struct-declaration-list <==
  (struct-declaration / static_assert-declaration)*

struct-declaration <==
  specifier-qualifier-list struct-declarator-list? @`;`

specifier-qualifier-list <==
  (type-specifier / type-qualifier)+

struct-declarator-list <==
  struct-declarator (`,` struct-declarator)*

struct-declarator <==
  declarator (`:` @constant-expression)? /
  `:` $false @constant-expression

enum-specifier <==
  `enum` extension-specifiers? (identifier? `{` @enumerator-list `,`? @`}` / @identifier)

enumerator-list <==
  enumerator (`,` enumerator)*

enumerator <==
  enumeration-constant (`=` @constant-expression)?

atomic-type-specifier <==
  `_Atomic` `(` type-name `)`

type-qualifier <==
  {`const`} /
  {`restrict`} / (`__restrict` / `__restrict__`)->'restrict' /
  {`volatile`} /
  {`_Atomic`} /
  extension-specifier

function-specifier <==
  {`inline`} / (`__inline` / `__inline__`)->'inline' /
  {`_Noreturn`}

alignment-specifier <==
  `_Alignas` `(` type-name `)` /
  `_Alignas` `(` constant-expression `)`

declarator <==
  (pointer* direct-declarator) -> foldright
  extension-specifiers?

typedef-declarator:declarator <==
  (pointer* typedef-direct-declarator) -> foldright
  extension-specifiers?

direct-declarator <--
  ((identifier / `(` declarator `)`) direct-declarator-suffix*) ~> foldleft

typedef-direct-declarator <--
  ((typedef-identifier / `(` typedef-declarator `)`) direct-declarator-suffix*) ~> foldleft

direct-declarator-suffix <--
  declarator-subscript /
  declarator-parameters

declarator-subscript <==
  `[` type-qualifier-list? assignment-expression? `]` /
  `[` &`static` storage-class-specifier type-qualifier-list? assignment-expression @`]` /
  `[` type-qualifier-list &`static` storage-class-specifier assignment-expression @`]` /
  `[` type-qualifier-list? pointer @`]`

declarator-parameters <==
  `(` parameter-type-list `)` /
  `(` identifier-list? `)`

pointer <==
  extension-specifiers? `*` type-qualifier-list?

type-qualifier-list <==
  type-qualifier+

parameter-type-list <==
  parameter-list (`,` parameter-varargs)?

parameter-varargs <==
  `...`

parameter-list <--
  parameter-declaration (`,` parameter-declaration)*

parameter-declaration <==
  declaration-specifiers (declarator / abstract-declarator?)

identifier-list <==
  identifier (`,` @identifier)*

type-name <==
  specifier-qualifier-list abstract-declarator?

abstract-declarator:declarator <==
  (
    (pointer+ direct-abstract-declarator?) -> foldright /
    direct-abstract-declarator
  ) extension-specifiers?

direct-abstract-declarator <--
  (
    `(` abstract-declarator `)` direct-declarator-suffix* /
    direct-declarator-suffix+
  ) ~> foldleft

typedef-name <==
  &(identifier => is_typedef) identifier

typedef-identifier <==
  &(identifier => set_typedef) identifier

initializer <==
  assignment-expression /
  `{` initializer-list? `,`? @`}`

initializer-list <==
  initializer-item (`,` initializer-item)*

initializer-item <--
  designation /
  initializer

designation <==
  designator-list `=` @initializer

designator-list <==
  designator+

designator <--
  subscript-designator /
  member-designator

subscript-designator <==
  `[` @constant-expression @`]`

member-designator <==
  `.` @identifier

static_assert-declaration <==
  `_Static_assert` @`(` @constant-expression @`,` @string-literal @`)`

--------------------------------------------------------------------------------
-- Statements

statement <--
  label-statement /
  case-statement /
  default-statement /
  compound-statement /
  expression-statement /
  if-statement /
  switch-statement /
  while-statement /
  do-while-statement /
  for-statement /
  goto-statement /
  continue-statement /
  break-statement /
  return-statement /
  asm-statement /
  `;`

label-statement <==
  identifier `:`

case-statement <==
  `case` @constant-expression @`:` statement?

default-statement <==
  `default` @`:` statement?

compound-statement <==
  `{` (label-statement / declaration / statement)* @`}`

expression-statement <==
  expression @`;`

if-statement <==
  `if` @`(` @expression @`)` @statement (`else` @statement)?

switch-statement <==
  `switch` @`(` @expression @`)` @statement

while-statement <==
  `while` @`(` @expression @`)` @statement

do-while-statement <==
  `do` @statement @`while` @`(` @expression @`)` @`;`

for-statement <==
  `for` @`(` (declaration / expression~? @`;`) expression~? @`;` expression~? @`)` @statement

goto-statement <==
  `goto` constant-expression @`;`

continue-statement <==
  `continue` @`;`

break-statement <==
  `break` @`;`

return-statement <==
  `return` expression? @`;`

asm-statement <==
  asm @`;`

--------------------------------------------------------------------------------
-- External definitions

translation-unit <==
  external-declaration*

external-declaration <--
  function-definition /
  declaration /
  `;`

function-definition <==
  declaration-specifiers declarator declaration-list compound-statement

declaration-list <==
  declaration*

]==]

-- List of syntax errors
local SyntaxErrorLabels = {
  ["UnexpectedSyntax"] = "unexpected syntax",
}

-- Extra builtin types (in GCC/Clang).
local builtin_typedefs = {
  __builtin_va_list = true,
  __auto_type = true,
  __int128 = true,
  _Float32 = true, _Float32x = true,
  _Float64 = true, _Float64x = true,
  _Float128 = true,
}

local ctype_to_nltype = {
  -- void type
  ['void'] = 'void',
  -- integral types
  ['char'] = 'cchar',
  ['signed char'] = 'cschar',
  ['short int'] = 'cshort',
  ['int'] = 'cint',
  ['long int'] = 'clong',
  ['long long int'] = 'clonglong',
  ['unsigned char'] = 'cuchar',
  ['unsigned short int'] = 'cushort',
  ['unsigned int'] = 'cuint',
  ['unsigned long int'] = 'culong',
  ['unsigned long long int'] = 'culonglong',
  ['intptr_t'] = 'isize',    ['__intptr_t'] = 'isize',
  ['uintptr_t'] = 'usize',   ['__uintptr_t'] = 'usize',
  -- float types
  ['long double'] = 'clongdouble',
  ['long double _Complex'] = 'clongcomplex',
  -- fixed integral types
  ['int8_t'] = 'int8',            ['__int8_t'] = 'int8',
  ['int16_t'] = 'int16',          ['__int16_t'] = 'int16',
  ['int32_t'] = 'int32',          ['__int32_t'] = 'int32',
  ['int64_t'] = 'int64',          ['__int64_t'] = 'int64',
  ['int128_t'] = 'int128',        ['__int128_t'] = 'int128',   ['__int128'] = 'int128',
  ['uint8_t'] = 'uint8',          ['__uint8_t'] = 'uint8',
  ['uint16_t'] = 'uint16',        ['__uint16_t'] = 'uint16',
  ['uint32_t'] = 'uint32',        ['__uint32_t'] = 'uint32',
  ['uint64_t'] = 'uint64',        ['__uint64_t'] = 'uint64',
  ['uint128_t'] = 'uint128',      ['__uint128_t'] = 'uint128', ['unsigned __int128'] = 'uint128',
  ['char16_t'] = 'uint16',        ['__char16_t'] = 'uint16',
  ['char32_t'] = 'uint32',        ['__char32_t'] = 'uint32',
  -- fixed float types
  ['float'] = 'float32',      ['_Float32x'] = 'float32',   ['_Float32'] = 'float32',
  ['double'] = 'float64',     ['_Float64x'] = 'float64',   ['_Float64'] = 'float64',
  ['_Float128'] = 'float128', ['__float128'] = 'float128',
  -- complex types
  ['float _Complex'] = 'complex32',   ['_Float32x _Complex'] = 'complex32', ['_Float32 _Complex'] = 'complex32',
  ['double _Complex'] = 'complex64',  ['_Float64x _Complex'] = 'complex64', ['_Float64 _Complex'] = 'complex64',
  ['_Float128 _Complex'] = 'complex128',
  -- boolean types
  ['bool'] = 'boolean', ['_Bool'] = 'boolean',
  -- special typedefs
  ['ptrdiff_t'] = 'cptrdiff',
  ['size_t'] = 'csize',
  ['clock_t'] = 'cclock_t',  ['__clock_t'] = 'cclock_t',
  ['time_t'] = 'ctime_t',    ['__time_t'] = 'ctime_t',
  ['wchar_t'] = 'cwchar_t',  ['__wchar_t'] = 'cwchar_t',        ['__gwchar_t'] = 'cwchar_t',

  -- C va_list support
  ['va_list'] = 'cvalist',   ['__builtin_va_list'] = 'cvalist', ['__gnuc_va_list'] = 'cvalist'
}

-- Execute typedefs using these names, because it's redundant.
local exclude_ctypes = {
  float_t = true,
  double_t = true,
  u_char = true,
  u_short = true,
  u_int = true,
  u_long = true,
  ulong = true,
  ushort = true,
  uint = true,
  u_int8_t = true,
  u_int16_t = true,
  u_int32_t = true,
  u_int64_t = true,
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

-- Parsing typedefs identifiers in C11 requires context information.
local ctypedefs

-- Clear ctypedefs.
local function init_typedefs()
  ctypedefs = {}
  for k in pairs(builtin_typedefs) do
    ctypedefs[k] = true
  end
end

local Defs = {}

-- Checks whether an identifier node is a typedef.
function Defs.is_typedef(_, _, node)
  return ctypedefs[node[1]] == true
end

-- Set an identifier as a typedef.
function Defs.set_typedef(_, _, node)
  ctypedefs[node[1]] = true
  return true
end

-- Compile grammar.
local grammar_patt = lpegrex.compile(Grammar, Defs)

--[[
Parse C11 source code into an AST.
The source code must be already preprocessed (preprocessor directives will be ignored).
]]
local function parse_c11(source, name)
  init_typedefs()
  local ast, errlabel, errpos = grammar_patt:match(source)
  ctypedefs = nil
  if not ast then
    name = name or '<source>'
    local lineno, colno, line = lpegrex.calcline(source, errpos)
    local colhelp = string.rep(' ', colno-1)..'^'
    local errmsg = SyntaxErrorLabels[errlabel] or errlabel
    error('syntax error: '..name..':'..lineno..':'..colno..': '..errmsg..
          '\n'..line..'\n'..colhelp)
  end
  return ast
end

-------------------------------------------------------------------------------
-- Binding context

local BindingContext = {}
local BindingContext_mt = {__index = BindingContext}

function BindingContext.create()
  return setmetatable({
    bindings_ast = {},
    type_by_name = {},
    typedefname_by_type = {},
    included_names = {},
    forward_names = {},
    visitors = {},
    exclude_filters = {
      '^__', -- internal types
    },
    exclude_names = exclude_ctypes
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

function BindingContext:can_include_name(name)
  if self.included_names[name] then -- already included
    return false
  end
  if ctype_to_nltype[name] then -- ignore builtin types
    return
  end
  if self.exclude_names[name] then
    return false
  end
  if reserved_names[name] then
    return false
  end
  for _,patt in ipairs(self.exclude_filters) do
    if name:match(patt) then
      return false
    end
  end
  return true
end

function BindingContext:redefine_type(fullname, typenode)
  -- update typedefs references on forward declared types
  local oldtype = self.type_by_name[fullname]
  if oldtype then
    local typedefname = self.typedefname_by_type[oldtype]
    if typedefname then
      self.type_by_name[typedefname] = typenode
      self.typedefname_by_type[typenode] = typedefname
    end
  end
  self.type_by_name[fullname] = typenode
end

function BindingContext:canonial_type_node(node)
  while node.tag == 'CType' do
    local resolved_type = self.type_by_name[node[1]]
    if resolved_type and resolved_type ~= node then
      node = resolved_type
    else
      break
    end
  end
  return node
end

function BindingContext:resolve_typename(ctypename)
  -- try primitive types first
  local typename = ctype_to_nltype[ctypename]
  if typename then return typename end
  -- check if type is already included
  if self.included_names[ctypename] then
    return ctypename
  end
  -- find the canonical type
  local typenode = self.type_by_name[ctypename]
  if typenode then
    -- try primitive again
    typename = typenode.tag == 'CType' and ctype_to_nltype[typenode[1]]
    if typename then return typename end
    -- otherwise use name of latest typedef
    typename = self.typedefname_by_type[typenode]
    if typename and self.included_names[typename] then return typename end
  end
  return typenode
end

function BindingContext:normalize_param_name(name)
  name = name:gsub('^__', '') -- strip `__` prefix from C lib internal names
  if reserved_names[name] then
    return name:sub(1,1):upper()..name:sub(2)
  end
  return name
end

function BindingContext:generate_typedef_name(name, typenode)
  -- TODO: check typedef name collisions
  local typedefname = name..'_t'
  assert(not self.type_by_name[typedefname], 'typedef already used')
  self.typedefname_by_type[typenode] = name
  self.type_by_name[typedefname] = typenode
  return typedefname
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
  -- TODO: handle more constant expressions
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
    type = {tag='CStructOrUnionType', kind, name}
    if fullname then
      table.insert(context.bindings_ast, {tag='CTypeDecl', type})
      context:redefine_type(fullname, type)
    end
  else
    assert(fullname, 'struct or union must have a name or declaration')
    type = {tag='CType', fullname}
    if not context.type_by_name[fullname] then
      local opaquetype = {tag='COpaqueType', kind, name}
      context.type_by_name[fullname] = opaquetype
      table.insert(context.bindings_ast, {tag='CTypeDecl', opaquetype})
    end
  end
  return type
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
    local lastvalue = -1
    for _,enumfield in ipairs(enumlist) do
      local fieldname = enumfield[1][1]
      local fieldexpr = enumfield[2]
      local fieldvalue
      if fieldexpr then
        fieldvalue = parse_constant_expression(fieldexpr)
      elseif lastvalue then
        fieldvalue = lastvalue + 1
      end
      table.insert(fields, {fieldname, fieldvalue})
      lastvalue = fieldvalue
    end
    -- TODO: enum may be unsigned, consider it
    local cinttype = 'int'
    type = {tag='CEnumType', name, fields, cinttype}
    table.insert(context.bindings_ast, {tag='CTypeDecl', type})
    if fullname then
      context:redefine_type(fullname, type)
    end
  else -- opaque enum
    assert(fullname, 'enum must have a name or declaration')
    type = {tag='CType', fullname}
    if not context.type_by_name[fullname] then
      local opaquetype = {tag='COpaqueType', 'enum', name}
      context.type_by_name[fullname] = opaquetype
      table.insert(context.bindings_ast, {tag='CTypeDecl', opaquetype})
    end
  end
  return type
end

local parse_declarator

-- Retrieves Nelua type and its attr from declaration specifiers node.
local function parse_type(context, node, attr)
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
      elseif typespecifier.tag == 'atomic-type-specifier' then
        attr._Atomic = true
        ctype = parse_declarator(context, typespecifier[1], attr)
      elseif typespecifier.tag == 'typeof' then
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
    if widthprefix then
      fullctype = widthprefix..' '..fullctype
    end
    if signprefix and not (signprefix == 'signed' and ctype ~= 'char') then
      fullctype = signprefix..' '..fullctype
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

function parse_declarator(context, node, firsttype, attr)
  if node.tag == 'identifier' then -- identifier associated with the type
    return firsttype, node[1]
  elseif node.tag == 'typedef-identifier' then -- typedef type
    return firsttype, node[1][1]
  elseif node.tag == 'pointer' then -- pointer type
    local lastnode = node[#node]
    local subnode = lastnode and (lastnode.tag ~= 'type-qualifier-list' and
                                  lastnode.tag ~= 'extension-specifiers') and lastnode
    local qualifiers = find_child_node_by_tag(node, 'type-qualifier-list')
    local extensions = find_child_node_by_tag(node, 'extension-specifiers')
    if qualifiers then
      parse_qualifiers(qualifiers, attr)
    end
    if extensions then
      parse_extensions(extensions, attr)
    end
    if subnode then -- pointer with an identifier
      return parse_declarator(context, subnode, {tag='CPointerType', firsttype}, attr)
    else -- pointer without an identifier (used by function pointers without a name)
      return {tag='CPointerType', firsttype}, nil
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
    local params = {}
    local functypenode = {tag='CFuncType', params, firsttype}
    local type, name = parse_declarator(context, namenode, functypenode, attr)
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
            if firstparamtype.tag == 'CType' and firstparamtype[1] == 'void' then -- stop on first void
              break
            end
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
    return type, name
  elseif node.tag == 'declarator' then
    local extensions = node[2]
    if extensions then
      parse_extensions(extensions, attr)
    end
    return parse_declarator(context, node[1], firsttype, attr)
  elseif node.tag == 'type-name' then
    local specifiers, declarator = node[1], node[2]
    assert(specifiers.tag == 'specifier-qualifier-list')
    firsttype = parse_type(context, specifiers, attr)
    if declarator then
      return parse_declarator(context, declarator, firsttype, attr), nil
    else
      return firsttype, nil
    end
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
      if type.tag == 'CFuncType' then
        table.insert(context.bindings_ast, {tag='CFuncDecl', attr=attr, name, type})
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
    local canonial_type = context:canonial_type_node(type)
    context.type_by_name[name] = canonial_type
    context.typedefname_by_type[type] = name
    context.typedefname_by_type[canonial_type] = name
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

local generate_bindings_visitors = {}

function generate_bindings_visitors.CType(context, node, emitter)
  local resolvedtype = context:resolve_typename(node[1])
  if type(resolvedtype) == 'string' then
    emitter:add(resolvedtype)
  else -- a node
    if resolvedtype ~= node then -- FIXME
      context:traverse_node(resolvedtype, emitter)
    end
  end
end

function generate_bindings_visitors.CPointerType(context, node, emitter)
  local subtypenode = node[1]
  local subcname = subtypenode and subtypenode.tag == 'CType' and subtypenode[1]
  if subcname == 'void' or not subtypenode then
    emitter:add('pointer')
  elseif subcname == 'char' then
    emitter:add('cstring')
  else
    if subtypenode.tag ~= 'CFuncType' then -- nelua function type is already a pointer
      emitter:add('*')
    end
    context:traverse_node(subtypenode, emitter)
  end
end

function generate_bindings_visitors.CArrayType(context, node, emitter, params)
  local argi = params and params.argi
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

function generate_bindings_visitors.CParamDecl(context, node, emitter, params)
  local argi = params and params.argi
  local name, typenode = node[1], node[2]
  if name then
    emitter:add(context:normalize_param_name(name)..': ')
  elseif argi then
    emitter:add('a'..argi..': ')
  end
  context:traverse_node(typenode, emitter, params)
end

function generate_bindings_visitors.CFuncType(context, node, emitter, params)
  local paramnodes, retnode = node[1], node[2]
  local decl = params and params.decl
  if not decl then
    emitter:add('function')
  end
  emitter:add('(')
  for i,paramnode in ipairs(paramnodes) do
    if i > 1 then emitter:add(', ') end
    context:traverse_node(paramnode, emitter, {argi=i})
  end
  emitter:add('): ')
  context:traverse_node(retnode, emitter)
end

function generate_bindings_visitors.CStructOrUnionType(context, node, emitter, params)
  local kind, name, fields = node[1], node[2], node[3]
  kind = kind == 'struct' and 'record' or 'union'
  local typedefname = context.typedefname_by_type[node]
  local importname = typedefname or name
  local decl = params and params.decl
  assert(importname or not decl)
  if not decl and importname then
    emitter:add(importname)
    return
  end
  if importname then
    if not context:can_include_name(importname) then -- filtered out
      return
    end
    context.included_names[importname] = true
  end
  if decl then
    if context.forward_names[importname] then -- already predeclared
      emitter:add(importname.." = @")
    else
      if typedefname then
        emitter:add("global "..importname..": type <cimport,nodecl> = @")
      else
        typedefname = context:generate_typedef_name(name, node)
        emitter:add("global "..importname..": type <cimport'"..typedefname.."',ctypedef,nodecl> = @")
      end
    end
  end
  emitter:add(kind..'{')
  emitter:add('}')
  if decl then
    emitter:add_ln()
  end
end

function generate_bindings_visitors.CEnumType(context, node, emitter, params)
  local name, fields, cintname = node[1], node[2], node[3]
  local typedefname = context.typedefname_by_type[node]
  local importname = typedefname or name
  local intname = ctype_to_nltype[cintname]
  local decl = params and params.decl
  if not decl then
    emitter:add(importname or intname)
    return
  end
  if importname then
    if not context:can_include_name(importname) then -- filtered out
      return
    end
    context.included_names[importname] = true
  end
  -- determine if all fields values are known
  local knowallfields = true
  for _,field in ipairs(fields) do
    local fieldvalue = field[2]
    if not fieldvalue then
      knowallfields = false
      break
    end
  end
  if not importname then -- anonymous enum
    if knowallfields then -- all fields are known
      for _,field in ipairs(fields) do
        local fieldname, fieldvalue = field[1], field[2]
        if context:can_include_name(fieldname) then
          emitter:add_indent_ln("global "..fieldname..': '..intname..' <comptime> = '..fieldvalue)
        end
      end
    else
      -- TODO
    end
  else -- enum has a name
    if knowallfields then -- all fields are known
      if typedefname then
        emitter:add_ln("global "..importname..": type <cimport,nodecl,using>"
                    .." = @enum("..intname.."){")
      else
        typedefname = context:generate_typedef_name(name, node)
        emitter:add_ln("global "..importname..": type <cimport'"..typedefname.."',ctypedef,nodecl,using>"
                    .." = @enum("..intname.."){")
      end
      emitter:inc_indent()
      for i,field in ipairs(fields) do
        local fieldname, fieldvalue = field[1], field[2]
        local sep = i < (#fields) and ',' or ''
        emitter:add_indent_ln(fieldname..' = '..fieldvalue..sep)
      end
      emitter:dec_indent()
      emitter:add_ln('}')
    else -- not all fields are known
      -- TODO
    end
  end
end

function generate_bindings_visitors.CTypedef(context, node, emitter)
  local name, typenode = node[1], node[2]
  if typenode.tag == 'CFuncType' then -- ignore non function pointer
    return
  end
  if not context:can_include_name(name) then -- filtered out
    return
  end
  if context.forward_names[name] then -- already declared
    return
  end
  context.included_names[name] = true
  emitter:add('global '..name..': type <cimport,nodecl> = @')
  context:traverse_node(typenode, emitter)
  emitter:add_ln()
end

function generate_bindings_visitors.COpaqueType(context, node, emitter, params)
  local decl = params and params.decl
  local kind, name = node[1], node[2]
  local fullname = kind..' '..name
  local typenode = context.type_by_name[fullname]
  local typedefname = context.typedefname_by_type[typenode]
  local importname = typedefname or name
  assert(typenode)
  if decl then
    if kind == 'enum' and typenode.tag == 'CEnumType' then -- define the enum early
      context:traverse_node(typenode, emitter, {decl=true})
      return
    end
    if not context:can_include_name(importname) then -- filtered out
      return
    end
    if kind ~= 'enum' then
      if context.forward_names[importname] then -- already forward declared
        return
      end
      context.forward_names[importname] = true
    else
      context.included_names[importname] = true
    end
    local annotations
    if typedefname then
      annotations = {"cimport", 'nodecl'}
    elseif not typedefname then
      typedefname = context:generate_typedef_name(name, typenode)
      annotations = {"cimport'"..typedefname.."'", 'ctypedef', 'nodecl'}
    end
    if kind ~= 'enum' then
      table.insert(annotations, 'forwarddecl')
    end
    emitter:add("global "..importname..": type <"..table.concat(annotations, ',').."> = @")
    if kind == 'enum' then
      emitter:add_ln('cint')
    elseif kind == 'struct' then
      emitter:add_ln('record{}')
    elseif kind == 'union' then
      emitter:add_ln('union{}')
    end
  else
    assert(typedefname)
    emitter:add(typedefname)
  end
end

function generate_bindings_visitors.CTypeDecl(context, node, emitter)
  local typenode = node[1]
  context:traverse_node(typenode, emitter, {decl=true})
end

function generate_bindings_visitors.CFuncDecl(context, node, emitter)
  local name, functypenode = node[1], node[2]
  if not context:can_include_name(name) then -- filtered out
    return
  end
  emitter:add('global function '..name)
  context:traverse_node(functypenode, emitter, {decl=true})
  emitter:add_ln(' <cimport,nodecl> end')
end

function generate_bindings_visitors.CVarDecl(context, node, emitter)
  local name, typenode = node[1], node[2]
  if not context:can_include_name(name) then -- filtered out
    return
  end
  emitter:add('global '..name..': ')
  context:traverse_node(typenode, emitter)
  emitter:add(' <cimport,nodecl>')
  emitter:add_ln()
end

local function generate_nelua_bindings(context)
  local emitter = Emitter()
  context.emitter = emitter
  context.visitors = generate_bindings_visitors
  -- dump(lpegrex.prettyast(context.bindings_ast))
  context:traverse_nodes(context.bindings_ast, emitter)
  return emitter:generate()
end

-------------------------------------------------------------------------------
local nldecl = {}

function nldecl.generate_bindings_from_c_code(ccode)
  local ast = parse_c11(ccode)
  local context = parse_c_bindings(ast)
  return generate_nelua_bindings(context)
end

-------------------------------------------------------------------------------
-- Test

local lester = require 'lester'
local describe, it, expect = lester.describe, lester.it, lester.expect

local function expect_bindings(c_code, expected_nelua_code)
  local nelua_code = nldecl.generate_bindings_from_c_code(c_code)
  if #expected_nelua_code > 0 and expected_nelua_code:sub(-1,-1) ~= '\n' then -- always ends with new line
    expected_nelua_code = expected_nelua_code..'\n'
  end
  expect.equal(nelua_code, expected_nelua_code)
end

describe('c11 parser', function()

it("primitives types", function()
  expect_bindings([[void x;]],
                  [[global x: void <cimport,nodecl>]])
  expect_bindings([[_Bool x;]],
                  [[global x: boolean <cimport,nodecl>]])
  expect_bindings([[char x;]],
                  [[global x: cchar <cimport,nodecl>]])
  expect_bindings([[unsigned char x;]],
                  [[global x: cuchar <cimport,nodecl>]])
  expect_bindings([[signed char x;]],
                  [[global x: cschar <cimport,nodecl>]])
  expect_bindings([[int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[short x;]],
                  [[global x: cshort <cimport,nodecl>]])
  expect_bindings([[long x;]],
                  [[global x: clong <cimport,nodecl>]])
  expect_bindings([[long long x;]],
                  [[global x: clonglong <cimport,nodecl>]])
  expect_bindings([[unsigned long long x;]],
                  [[global x: culonglong <cimport,nodecl>]])
end)

it("float types", function()
  expect_bindings([[float x;]],
                  [[global x: float32 <cimport,nodecl>]])
  expect_bindings([[double x;]],
                  [[global x: float64 <cimport,nodecl>]])
  expect_bindings([[_Float128 x;]],
                  [[global x: float128 <cimport,nodecl>]])
  expect_bindings([[long double x;]],
                  [[global x: clongdouble <cimport,nodecl>]])
end)

it("float complex types", function()
  expect_bindings([[float _Complex x;]],
                  [[global x: complex32 <cimport,nodecl>]])
  expect_bindings([[double _Complex x;]],
                  [[global x: complex64 <cimport,nodecl>]])
  expect_bindings([[_Float128 _Complex x;]],
                  [[global x: complex128 <cimport,nodecl>]])
  expect_bindings([[long double _Complex x;]],
                  [[global x: clongcomplex <cimport,nodecl>]])
end)

it("primitive typedefs", function()
  expect_bindings([[typedef _Bool bool; bool x;]],
                  [[global x: boolean <cimport,nodecl>]])
  expect_bindings([[typedef signed char int8_t; int8_t x;]],
                  [[global x: int8 <cimport,nodecl>]])
  expect_bindings([[typedef signed short int int16_t; int16_t x;]],
                  [[global x: int16 <cimport,nodecl>]])
  expect_bindings([[typedef signed int int32_t; int32_t x;]],
                  [[global x: int32 <cimport,nodecl>]])
  expect_bindings([[typedef signed long long int int64_t; int64_t x;]],
                  [[global x: int64 <cimport,nodecl>]])
  expect_bindings([[typedef signed long long int int64_t; int64_t x;]],
                  [[global x: int64 <cimport,nodecl>]])
  expect_bindings([[typedef signed __int128 int128_t; int128_t x;]],
                  [[global x: int128 <cimport,nodecl>]])
  expect_bindings([[typedef unsigned char uint8_t; uint8_t x;]],
                  [[global x: uint8 <cimport,nodecl>]])
  expect_bindings([[typedef unsigned short int uint16_t; uint16_t x;]],
                  [[global x: uint16 <cimport,nodecl>]])
  expect_bindings([[typedef unsigned int uint32_t; uint32_t x;]],
                  [[global x: uint32 <cimport,nodecl>]])
  expect_bindings([[typedef unsigned long long int uint64_t; uint64_t x;]],
                  [[global x: uint64 <cimport,nodecl>]])
  expect_bindings([[typedef unsigned __int128 uint128_t; uint128_t x;]],
                  [[global x: uint128 <cimport,nodecl>]])
  expect_bindings([[typedef signed long int intptr_t; intptr_t x;]],
                  [[global x: isize <cimport,nodecl>]])
  expect_bindings([[typedef unsigned long int uintptr_t; uintptr_t x;]],
                  [[global x: usize <cimport,nodecl>]])
  expect_bindings([[typedef long int ptrdiff_t; ptrdiff_t x;]],
                  [[global x: cptrdiff <cimport,nodecl>]])
  expect_bindings([[typedef unsigned long int size_t; size_t x;]],
                  [[global x: csize <cimport,nodecl>]])
  expect_bindings([[typedef long int clock_t; clock_t x;]],
                  [[global x: cclock_t <cimport,nodecl>]])
  expect_bindings([[typedef long int time_t; time_t x;]],
                  [[global x: ctime_t <cimport,nodecl>]])
  expect_bindings([[typedef long int wchar_t; wchar_t x;]],
                  [[global x: cwchar_t <cimport,nodecl>]])
end)

it("valist", function()
  expect_bindings([[typedef __builtin_va_list va_list; va_list x;]],
                  [[global x: cvalist <cimport,nodecl>]])
  expect_bindings([[typedef __builtin_va_list va_list; va_list x;]],
                  [[global x: cvalist <cimport,nodecl>]])
end)

it("pointers", function()
  expect_bindings([[void* x;]],
                  [[global x: pointer <cimport,nodecl>]])
  expect_bindings([[char* x;]],
                  [[global x: cstring <cimport,nodecl>]])
  expect_bindings([[int* x;]],
                  [[global x: *cint <cimport,nodecl>]])
  expect_bindings([[int** x;]],
                  [[global x: **cint <cimport,nodecl>]])
  expect_bindings([[int*** x;]],
                  [[global x: ***cint <cimport,nodecl>]])
end)

it("arrays", function()
  expect_bindings([[int x[];]],
                  [[global x: *[0]cint <cimport,nodecl>]])
  expect_bindings([[int x[0];]],
                  [[global x: [0]cint <cimport,nodecl>]])
  expect_bindings([[int x[4];]],
                  [[global x: [4]cint <cimport,nodecl>]])
  expect_bindings([[int x[3][2][1];]],
                  [[global x: [3][2][1]cint <cimport,nodecl>]])
end)

it("typedefs", function()
  expect_bindings([[typedef int Int;]],
                  [[global Int: type <cimport,nodecl> = @cint]])
  -- pointer
  expect_bindings([[typedef int* T;]],
                  [[global T: type <cimport,nodecl> = @*cint]])
  expect_bindings([[typedef int** T;]],
                  [[global T: type <cimport,nodecl> = @**cint]])
  -- array
  expect_bindings([[typedef int T[4];]],
                  [[global T: type <cimport,nodecl> = @[4]cint]])
  expect_bindings([[typedef int T[3][2][1];]],
                  [[global T: type <cimport,nodecl> = @[3][2][1]cint]])
  -- array of pointers
  expect_bindings([[typedef int* T[4];]],
                  [[global T: type <cimport,nodecl> = @[4]*cint]])
  -- multiple typedef
  expect_bindings([[typedef int T1, *T2, T3[4];]], [[
global T1: type <cimport,nodecl> = @cint
global T2: type <cimport,nodecl> = @*cint
global T3: type <cimport,nodecl> = @[4]cint
]])
  -- function pointer
  expect_bindings([[typedef void(*F)(void);]],
                  [[global F: type <cimport,nodecl> = @function(): void]])
  -- ignore
  expect_bindings([[typedef __builtin_va_list myvalist;]],
                  [[global myvalist: type <cimport,nodecl> = @cvalist]])
  expect_bindings([[typedef __builtin_va_list va_list;]], [[]])
  expect_bindings([[typedef int __builtin_va_list;]], [[]])
  expect_bindings([[typedef void F(void);]], [[]])
  expect_bindings([[typedef void F(void); F* f;]],
                  [[global f: *function(): void <cimport,nodecl>]])
end)

it("specifiers and qualifiers", function()
  expect_bindings([[extern int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[static int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[_Thread_local int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[const int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[_Atomic int x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[_Atomic(int) x;]],
                  [[global x: cint <cimport,nodecl>]])
  expect_bindings([[const void* f(volatile int x, const long y, restrict void* z);]],
                  [[global function f(x: cint, y: clong, z: pointer): pointer <cimport,nodecl> end]])
end)

it("function pointers", function()
  expect_bindings([[void (*f)();]],
                  [[global f: function(): void <cimport,nodecl>]])
  expect_bindings([[void (*f)(void);]],
                  [[global f: function(): void <cimport,nodecl>]])
  expect_bindings([[int (*f)(int);]],
                  [[global f: function(a1: cint): cint <cimport,nodecl>]])
  expect_bindings([[int (*f)(int x);]],
                  [[global f: function(x: cint): cint <cimport,nodecl>]])
  expect_bindings([[int (*f)(int x, long y);]],
                  [[global f: function(x: cint, y: clong): cint <cimport,nodecl>]])
  -- with attributes
  expect_bindings([[int (*restrict f)(int x, long y);]],
                  [[global f: function(x: cint, y: clong): cint <cimport,nodecl>]])
  -- pointer return
  expect_bindings([[int* (*f)(int x);]],
                  [[global f: function(x: cint): *cint <cimport,nodecl>]])
  expect_bindings([[int** (*f)(int x);]],
                  [[global f: function(x: cint): **cint <cimport,nodecl>]])
  expect_bindings([[int*** (*f)(int x);]],
                  [[global f: function(x: cint): ***cint <cimport,nodecl>]])
  -- double function pointer
  expect_bindings([[void (**f)();]],
                  [[global f: *function(): void <cimport,nodecl>]])
  -- as arrays
  expect_bindings([[void (*f[2])();]],
                   [[global f: [2]function(): void <cimport,nodecl>]])
  expect_bindings([[void (*f[3][2][1])();]],
                   [[global f: [3][2][1]function(): void <cimport,nodecl>]])
end)

it("function declarations", function()
  expect_bindings([[void f();]],
                  [[global function f(): void <cimport,nodecl> end]])
  expect_bindings([[void f(void);]],
                  [[global function f(): void <cimport,nodecl> end]])
  -- with parameters
  expect_bindings([[int f(int);]],
                  [[global function f(a1: cint): cint <cimport,nodecl> end]])
  expect_bindings([[void f(int x);]],
                  [[global function f(x: cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int, long);]],
                  [[global function f(a1: cint, a2: clong): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x, long y);]],
                  [[global function f(x: cint, y: clong): void <cimport,nodecl> end]])
  -- pointer parameter
  expect_bindings([[void f(int* x);]],
                  [[global function f(x: *cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int** x);]],
                  [[global function f(x: **cint): void <cimport,nodecl> end]])
  -- arrays parameter
  expect_bindings([[void f(int x[]);]],
                  [[global function f(x: *[0]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x[4]);]],
                  [[global function f(x: *[4]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x[3][2][1]);]],
                  [[global function f(x: *[3][2][1]cint): void <cimport,nodecl> end]])
  -- valist parameter
  expect_bindings([[int vsprintf(char*restrict s, const char*restrict format, __builtin_va_list arg);]],
                  [[global function vsprintf(s: cstring, format: cstring, arg: cvalist): cint <cimport,nodecl> end]])
  -- varargs parameter
  expect_bindings([[void f(int x, ...);]],
                  [[global function f(x: cint, ...: cvarargs): void <cimport,nodecl> end]])
  -- callback parameter
  expect_bindings([[void f(void(*)(void));]],
                  [[global function f(a1: function(): void): void <cimport,nodecl> end]])
  expect_bindings([[void f(void(*f)(void));]],
                  [[global function f(f: function(): void): void <cimport,nodecl> end]])
  -- with specifiers
  expect_bindings([[static inline volatile int f();]],
                  [[global function f(): cint <cimport,nodecl> end]])
  expect_bindings([[void f(volatile int x, void* restrict y);]],
                  [[global function f(x: cint, y: pointer): void <cimport,nodecl> end]])
end)

it("enum type", function()
  expect_bindings([[enum MyEnum* e;]], [[
global MyEnum: type <cimport'MyEnum_t',ctypedef,nodecl> = @cint
global e: *MyEnum <cimport,nodecl>
]])
  expect_bindings([[enum MyEnum; enum MyEnum* e;]], [[
global MyEnum: type <cimport'MyEnum_t',ctypedef,nodecl> = @cint
global e: *MyEnum <cimport,nodecl>
]])
  expect_bindings([[typedef enum MyEnum MyEnum; MyEnum* e;]], [[
global MyEnum: type <cimport,nodecl> = @cint
global e: *MyEnum <cimport,nodecl>
]])
  expect_bindings([[enum MyEnum; typedef enum MyEnum MyEnum; MyEnum* e;]],[[
global MyEnum: type <cimport,nodecl> = @cint
global e: *MyEnum <cimport,nodecl>
]])
  expect_bindings([[enum MyEnum{MyEnumA, MyEnumB}; enum MyEnum e;]], [[
global MyEnum: type <cimport'MyEnum_t',ctypedef,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
  expect_bindings([[typedef enum{MyEnumA, MyEnumB} MyEnum; MyEnum e;]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
  expect_bindings([[typedef enum MyEnum{MyEnumA, MyEnumB} MyEnum; MyEnum e;]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
  expect_bindings([[typedef enum MyEnum{MyEnumA, MyEnumB} MyEnum_t; MyEnum_t e;]], [[
global MyEnum_t: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum_t <cimport,nodecl>
]])
  expect_bindings([[typedef enum MyEnum{MyEnumA, MyEnumB}* MyEnum_p; MyEnum_p e;]], [[
global MyEnum: type <cimport'MyEnum_t',ctypedef,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global MyEnum_p: type <cimport,nodecl> = @*MyEnum
global e: MyEnum_p <cimport,nodecl>
]])
  expect_bindings([[
enum MyEnum{MyEnumA, MyEnumB};
typedef enum MyEnum MyEnum;
MyEnum e;
]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
  expect_bindings([[enum {MyEnumA, MyEnumB};]], [[
global MyEnumA: cint <comptime> = 0
global MyEnumB: cint <comptime> = 1
]])
  expect_bindings([[
typedef enum MyEnum MyEnum;
enum MyEnum {MyEnumA, MyEnumB};
enum MyEnum a;
MyEnum b;
]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global a: MyEnum <cimport,nodecl>
global b: MyEnum <cimport,nodecl>
]])
  expect_bindings([[
enum MyEnum;
typedef enum MyEnum MyEnum;
enum MyEnum {MyEnumA, MyEnumB};
MyEnum e;
]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
  expect_bindings([[
typedef enum MyEnum MyEnum;
MyEnum e;
enum MyEnum {MyEnumA, MyEnumB};
]], [[
global MyEnum: type <cimport,nodecl,using> = @enum(cint){
  MyEnumA = 0,
  MyEnumB = 1
}
global e: MyEnum <cimport,nodecl>
]])
end)

it("struct type", function()
  expect_bindings([[struct MyStruct{}; struct MyStruct s;]], [[
global MyStruct: type <cimport'MyStruct_t',ctypedef,nodecl> = @record{}
global s: MyStruct <cimport,nodecl>
]])
  expect_bindings([[typedef struct MyStruct{} MyStruct;]],
                  [[global MyStruct: type <cimport,nodecl> = @record{}]])
  expect_bindings([[struct MyStruct{}; typedef struct MyStruct MyStruct;]],
                  [[global MyStruct: type <cimport,nodecl> = @record{}]])
  -- ignore
  expect_bindings([[typedef struct{} va_list;]], [[]])
  expect_bindings([[struct va_list{};]], [[]])
  expect_bindings([[typedef struct va_list{} va_list;]], [[]])
  expect_bindings([[typedef struct{}* va_list;]], [[]])
end)

it("forward declaration", function()
  expect_bindings([[struct MyStruct; struct MyStruct* s;]], [[
global MyStruct: type <cimport'MyStruct_t',ctypedef,nodecl,forwarddecl> = @record{}
global s: *MyStruct <cimport,nodecl>
]])
  expect_bindings([[struct MyStruct; struct MyStruct* s; struct MyStruct{};]], [[
global MyStruct: type <cimport'MyStruct_t',ctypedef,nodecl,forwarddecl> = @record{}
global s: *MyStruct <cimport,nodecl>
MyStruct = @record{}
]])
  expect_bindings([[typedef struct MyStruct MyStruct; MyStruct* s;]], [[
global MyStruct: type <cimport,nodecl,forwarddecl> = @record{}
global s: *MyStruct <cimport,nodecl>
]])
  expect_bindings([[struct MyStruct; typedef struct MyStruct MyStruct; MyStruct* s;]], [[
global MyStruct: type <cimport,nodecl,forwarddecl> = @record{}
global s: *MyStruct <cimport,nodecl>
]])
end)

it("type resolution", function()
  expect_bindings([[
typedef unsigned long __ulong_t;
__ulong_t x;
]], [[
global x: culong <cimport,nodecl>
]])
  expect_bindings([[
typedef unsigned long ___ulong_t;
typedef ___ulong_t __ulong_t;
__ulong_t x;
]], [[
global x: culong <cimport,nodecl>
]])
  expect_bindings([[
typedef unsigned long __ulong_t;
typedef __ulong_t _ulong_t;
_ulong_t x;
]], [[
global _ulong_t: type <cimport,nodecl> = @culong
global x: _ulong_t <cimport,nodecl>
]])
  expect_bindings([[
typedef unsigned long ulong_t;
ulong_t x;
]], [[
global ulong_t: type <cimport,nodecl> = @culong
global x: ulong_t <cimport,nodecl>
]])

end)

it("big C file", function()
  local c_source = fs.readfile('pt_gcc.c')
  local nelua_source = nldecl.generate_bindings_from_c_code(c_source)
  fs.writefile('pt.nelua', nelua_source)
end)

end)
