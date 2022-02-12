--TODO: handle defines
--TODO: handle extensions (align, packed, incomplete types)
--TODO: name rewrite rules
--TODO: module mode
--TODO: C defines (generating, binding, both)
--TODO: C includes
--TODO: cache

local lpegrex = require 'nelua.thirdparty.lpegrex'
local tabler = require 'nelua.utils.tabler'
local Emitter = require 'nelua.emitter'
local fs = require 'nelua.utils.fs'
local executor = require 'nelua.utils.executor'

--[[
This grammar is based on the C11 specification.
As seen in https://port70.net/~nsz/c/c11/n1570.html#A.1
Support for parsing some new C2x syntax were also added.
Support for some extensions to use with GCC/Clang were also added.
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

identifier <== identifier-word

identifier-word <--
  !KEYWORD identifier-anyword

identifier-anyword <--
  {identifier-nondigit identifier-suffix?} SKIP

free-identifier:identifier <==
  identifier-word

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
encoding-prefix <-- 'u8' / [uUL]
s-char-sequence <-- s-char+
s-char <- [^"\%cn%cr] / escape-sequence

--------------------------------------------------------------------------------
-- Expressions

primary-expression <--
  string-literal /
  type-name /
  identifier /
  constant /
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
struct-or-union-member <== `.` identifier-word
pointer-member <== `->` identifier-word
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
  `(` type-name `)` $'cast' cast-expression

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
  attribute / asm / tg-promote

attribute <==
  (`__attribute__` / `__attribute`) `(` @`(` attribute-list @`)` @`)` /
  `[` `[` attribute-list @`]` @`]`

attribute-list <--
  attribute-item (`,` attribute-item)*

tg-promote <==
  `__tg_promote` @`(` (expression / parameter-varargs) @`)`

attribute-item <==
  identifier-anyword (`(` expression `)`)?

asm <==
  (`__asm` / `__asm__`)
  (`__volatile__` / `volatile`)~?
  `(` asm-argument (`,` asm-argument)* @`)`

asm-argument <-- (
    string-literal /
    {`:`} /
    {`,`} /
    `[` expression @`]` /
    `(` expression @`)` /
    expression
  )+

typedef-declaration <==
  `typedef` @declaration-specifiers (typedef-declarator (`,` @typedef-declarator)*)?

type-declaration <==
  declaration-specifiers init-declarator-list?

declaration-specifiers <==
  ((type-specifier-width / declaration-specifiers-aux)* type-specifier /
    declaration-specifiers-aux* type-specifier-width
  ) (type-specifier-width / declaration-specifiers-aux)*

declaration-specifiers-aux <--
  storage-class-specifier /
  type-qualifier /
  function-specifier /
  alignment-specifier

init-declarator-list <==
  init-declarator (`,` init-declarator)*

init-declarator <==
  declarator (`=` initializer)?

storage-class-specifier <==
  {`extern`} /
  {`static`} /
  {`auto`} /
  {`register`} /
  (`_Thread_local` / `__thread`)->'_Thread_local'

type-specifier <==
  {`void`} /
  {`char`} /
  {`int`} /
  {`float`} /
  {`double`} /
  {`_Bool`} /
  atomic-type-specifier /
  struct-or-union-specifier /
  enum-specifier /
  typedef-name /
  typeof

type-specifier-width : type-specifier <==
  {`short`} /
  (`signed` / `__signed` / `__signed__`)->'signed' /
  {`unsigned`} /
  (`long` `long`)->'long long' /
  {`long`} /
  {`_Complex`} /
  {`_Imaginary`}

typeof <==
  (`typeof` / `__typeof` / `__typeof__`) @argument-expression

struct-or-union-specifier <==
  struct-or-union extension-specifiers~? identifier-word~? (`{` struct-declaration-list `}`)?

struct-or-union <--
  {`struct`} / {`union`}

struct-declaration-list <==
  (struct-declaration / static_assert-declaration)*

struct-declaration <==
  specifier-qualifier-list struct-declarator-list? @`;`

specifier-qualifier-list <==
  ((type-specifier-width / specifier-qualifier-aux)* type-specifier /
    specifier-qualifier-aux* type-specifier-width
  ) (type-specifier-width / specifier-qualifier-aux)*

specifier-qualifier-aux <--
  type-qualifier /
  alignment-specifier

struct-declarator-list <==
  struct-declarator (`,` struct-declarator)*

struct-declarator <==
  declarator (`:` @constant-expression)? /
  `:` $false @constant-expression

enum-specifier <==
  `enum` extension-specifiers~? (identifier-word~? `{` @enumerator-list `,`? @`}` / @identifier-word)

enumerator-list <==
  enumerator (`,` enumerator)*

enumerator <==
  enumeration-constant (`=` @constant-expression)?

atomic-type-specifier <==
  `_Atomic` `(` type-name `)`

type-qualifier <==
  {`const`} /
  (`restrict` / `__restrict` / `__restrict__`)->'restrict' /
  {`volatile`} /
  {`_Atomic`} !`(` /
  extension-specifier

function-specifier <==
  (`inline` / `__inline` / `__inline__`)->'inline' /
  {`_Noreturn`}

alignment-specifier <==
  `_Alignas` `(` (type-name / constant-expression) `)`

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
  `[` subscript-qualifier-list~? (assignment-expression / pointer)~? @`]`

subscript-qualifier-list <==
  (type-qualifier / &`static` storage-class-specifier)+

declarator-parameters <==
  `(` parameter-type-list `)` /
  `(` identifier-list? `)`

pointer <==
  extension-specifiers~? `*` type-qualifier-list~?

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
  identifier-list-item (`,` @identifier-list-item)*

identifier-list-item <--
  identifier / `(` type-name @`)`

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
  `.` @identifier-word

static_assert-declaration <==
  `_Static_assert` @`(` @constant-expression (`,` @string-literal)? @`)`

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
  attribute /
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
  __int128 = true, __int128_t = true,
  _Float32 = true, _Float32x = true,
  _Float64 = true, _Float64x = true,
  __float128 = true, _Float128 = true,
}

local ctype_to_nltype = {
  -- void type
  ['void'] = 'void',
  -- integral types
  ['char'] = 'cchar',
  ['signed char'] = 'cschar',
  ['short int'] = 'cshort',             ['short'] = 'cshort',
  ['int'] = 'cint',                     ['signed'] = 'cint',
  ['long int'] = 'clong',               ['long'] = 'clong',
  ['long long int'] = 'clonglong',
  ['unsigned char'] = 'cuchar',         ['__u_char'] = 'cuchar',
  ['unsigned short int'] = 'cushort',   ['__u_short'] = 'cushort',
  ['unsigned int'] = 'cuint',           ['__u_int'] = 'cuint',    ['unsigned'] = 'cuint',
  ['unsigned long int'] = 'culong',     ['__u_long'] = 'culong',
  ['unsigned long long int'] = 'culonglong',
  ['intptr_t'] = 'isize',               ['__intptr_t'] = 'isize',
  ['uintptr_t'] = 'usize',              ['__uintptr_t'] = 'usize',
  -- float types
  ['long double'] = 'clongdouble',
  ['long double _Complex'] = 'clongcomplex',
  -- fixed integral types
  ['int8_t'] = 'int8',            ['__int8_t'] = 'int8',
  ['int16_t'] = 'int16',          ['__int16_t'] = 'int16',
  ['int32_t'] = 'int32',          ['__int32_t'] = 'int32',
  ['int64_t'] = 'int64',          ['__int64_t'] = 'int64',
  ['int128_t'] = 'int128',        ['__int128_t'] = 'int128',   ['__int128'] = 'int128',
  ['uint8_t'] = 'uint8',          ['__uint8_t'] = 'uint8',     ['u_int8_t'] = 'uint8',
  ['uint16_t'] = 'uint16',        ['__uint16_t'] = 'uint16',   ['u_int16_t'] = 'uint16',
  ['uint32_t'] = 'uint32',        ['__uint32_t'] = 'uint32',   ['u_int32_t'] = 'uint32',
  ['uint64_t'] = 'uint64',        ['__uint64_t'] = 'uint64',   ['u_int64_t'] = 'uint64',
  ['uint128_t'] = 'uint128',      ['__uint128_t'] = 'uint128', ['unsigned __int128'] = 'uint128',
  ['char16_t'] = 'uint16',        ['__char16_t'] = 'uint16',
  ['char32_t'] = 'uint32',        ['__char32_t'] = 'uint32',
  -- fixed float types
  ['float'] = 'float32',          ['_Float32x'] = 'float32',   ['_Float32'] = 'float32',
  ['double'] = 'float64',         ['_Float64x'] = 'float64',   ['_Float64'] = 'float64',
  ['__float128'] = 'float128',    ['_Float128'] = 'float128',
  -- complex types
  ['float _Complex'] = 'complex32',
  ['_Float32x _Complex'] = 'complex32',   ['_Float32 _Complex'] = 'complex32',
  ['double _Complex'] = 'complex64',      ['_Complex'] = 'complex64',
  ['_Float64x _Complex'] = 'complex64',   ['_Float64 _Complex'] = 'complex64',
  ['__float128 _Complex'] = 'complex128', ['_Float128 _Complex'] = 'complex128',
  -- boolean types
  ['bool'] = 'boolean', ['_Bool'] = 'boolean',
  -- special typedefs
  ['ptrdiff_t'] = 'cptrdiff', ['__ptrdiff_t'] = 'cptrdiff',
  ['size_t'] = 'csize',       ['__size_t'] = 'csize',
  ['clock_t'] = 'cclock_t',   ['__clock_t'] = 'cclock_t',
  ['time_t'] = 'ctime_t',     ['__time_t'] = 'ctime_t',
  ['wchar_t'] = 'cwchar_t',   ['__wchar_t'] = 'cwchar_t',        ['__gwchar_t'] = 'cwchar_t',

  -- C va_list support
  ['va_list'] = 'cvalist',   ['__builtin_va_list'] = 'cvalist', ['__gnuc_va_list'] = 'cvalist'
}

--[[
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
]]

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

-- Execute typedefs using these names, because it's redundant.
local common_exclude_names = {
  float_t = true,
  double_t = true,
  u_char = true,
  u_short = true,
  u_int = true,
  u_long = true,
  ulong = true,
  ushort = true,
  uint = true,
}
tabler.update(common_exclude_names, reserved_names)
tabler.update(common_exclude_names, ctype_to_nltype)

local common_opaque_names = {
  FILE = true, -- FILE struct on GLIBC
}

-- Parsing typedefs identifiers in C requires context information.
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
Parse C source code into an AST.
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

function BindingContext.create(opts)
  opts = opts or {}
  local exclude_names = {
    '^__', -- internal names
    '_compile_time_assert_', '^_dummy_array' -- compile time assert from some libs
  }
  if opts.exclude_names ~= nil then
    exclude_names = opts.exclude_names
  end
  local context = setmetatable({
    types_ast = {},
    vars_ast = {},
    node_by_name = {}, -- symbol list, map of all nodes with an identifier by name
    typedefname_by_node = {}, -- map of all typedefs
    declared_names = {}, -- set of names that has been declared so far
    forward_declared_names = {}, -- set of names that has been forward declared so far
    constants_integers = {},
    visitors = {},
    exclude_names = exclude_names,
    include_names = opts.include_names,
    opaque_names = opts.opaque_names,
  }, BindingContext_mt)
  return context
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
  if common_exclude_names[name] then
    return false
  end
  if self.exclude_names and self.exclude_names[name] then
    return false
  end
  if self.include_names and self.include_names[name] then
    return true
  end
  if self.exclude_names then
    for _,patt in ipairs(self.exclude_names) do
      if name:match(patt) then
        return false
      end
    end
  end
  if self.include_names then
    for _,patt in ipairs(self.include_names) do
      if name:match(patt) then
        return true
      end
    end
    return false
  else
    return true
  end
end

function BindingContext:mark_imports_for_node(node)
  if node.import then return end
  if node.tag == 'CPointerType' then
    node.import = true
    local subtypenode = node[1]
    self:mark_imports_for_node(subtypenode)
  elseif node.tag == 'CType' then
    -- mark itself
    local fullname = node[1]
    local name = fullname:gsub('^[a-z]+#', '') -- remove struct/union/enum prefix
    if common_exclude_names[name] then -- ignore internal names
      return
    end
    node.import = true
    -- mark canonical node
    local canonicalnode = self:get_canonical_node(node)
    if canonicalnode ~= node then
      self:mark_imports_for_node(canonicalnode)
    end
  elseif node.tag == 'CStructOrUnionType' then
    if not node.opaque then
      local fieldnodes = node[3]
      for _,fieldnode in ipairs(fieldnodes) do
        self:mark_imports_for_node(fieldnode[2])
      end
    end
    node.import = true
  elseif node.tag == 'CFuncType' then
    node.import = true
    local paramnodes, retnode = node[1], node[2]
    for _,paramnode in ipairs(paramnodes) do
      local paramtypenode = paramnode.tag == 'CParamDecl' and paramnode[2] or paramnode
      self:mark_imports_for_node(paramtypenode)
    end
    self:mark_imports_for_node(retnode)
  elseif node.tag == 'CEnumField' then
    node.import = true
    local enumtypenode = node[3]
    self:mark_imports_for_node(enumtypenode)
  elseif node.tag == 'CArrayType' then
    local subtypenode = node[1]
    self:mark_imports_for_node(subtypenode)
    node.import = true
  elseif node.tag == 'CVarDecl' or node.tag == 'CFuncDecl' or node.tag == 'CTypeDecl' then
    node.import = true
    local typenode = node[2]
    self:mark_imports_for_node(typenode)
  elseif node.tag == 'CTypedef' then
    local typenode = node[2]
    if typenode.tag == 'CFuncType' then -- ignore non function pointer
      return
    end
    self:mark_imports_for_node(typenode)
    node.import = true
  else
    node.import = true
  end
end

function BindingContext:mark_imports()
  -- transform opaque types
  for name in pairs(common_opaque_names) do
    local node = self.node_by_name[name]
    if node then
      local canonicalnode = self:get_canonical_node(node)
      if canonicalnode.tag == 'CStructOrUnionType' then
        canonicalnode.tag = 'COpaqueType'
        canonicalnode[3] = nil
        if not canonicalnode[2] then
          canonicalnode[2] = name
          local fullname = canonicalnode[1]..'#'..name
          self.node_by_name[fullname] = canonicalnode
        end
      end
    end
  end
  -- mark all nodes
  for fullname,node in pairs(self.node_by_name) do
    local name = fullname:gsub('^[a-z]+#', '') -- remove struct/union/enum prefix
    if self:can_include_name(name) then -- should be imported
      self:mark_imports_for_node(node)
    end
  end
  -- mark all top scope declarations
  for _,node in pairs(self.types_ast) do
    local fullname = node[1]
    if node.tag == 'CTypeDecl' then
      fullname = node[2][2]
      local typenode = node[2]
      -- mark anonymous enums
      if typenode.tag == 'CEnumType' then
        local enumname, fieldnodes = typenode[2], typenode[3]
        if not enumname then
          for _,fieldnode in ipairs(fieldnodes) do
            local fieldname = fieldnode[1]
            if self:can_include_name(fieldname) then
              self:mark_imports_for_node(fieldnode)
            end
          end
        end
      end
    end
    if fullname then
      local name = fullname:gsub('^[a-z]+#', '') -- remove struct/union/enum prefix
      if self:can_include_name(name) then -- should be imported
        self:mark_imports_for_node(node)
      end
    end
  end
  -- mark CTypeDecl
  for _,node in pairs(self.types_ast) do
    if node.tag == 'CTypeDecl' then
      local typenode = node[2]
      if typenode.import then
        self:mark_imports_for_node(node)
      end
    end
  end
  -- unmark uneeded COpaqueType
  for i=1,#self.types_ast-1 do
    local node = self.types_ast[i]
    if node.tag == 'CTypeDecl' then
      local typenode = node[2]
      if typenode.tag == 'COpaqueType' then
        local nextnode = self.types_ast[i+1]
        local nexttypenode = nextnode[2]
        if nextnode.tag == 'CTypeDecl' and
           typenode[1] == nexttypenode[1] and typenode[2] == nexttypenode[2] then
          node.import = nil
        end
      end
    end
  end
  -- mark used CTypedef
  for _,node in pairs(self.types_ast) do
    if node.tag == 'CTypedef' then
      local name, typenode = node[1], node[2]
      if typenode.import then
        if self:can_include_name(name) then
          self:mark_imports_for_node(node)
        end
      end
    end
  end
end

function BindingContext:define_symbol(fullname, node)
  local oldnode = self.node_by_name[fullname]
  if oldnode then -- symbol redefinition, happens on forward declared types
    local typedefname = self.typedefname_by_node[oldnode]
    if typedefname then -- update typedef references for forward declared types
      self.node_by_name[typedefname] = node
      self.typedefname_by_node[node] = typedefname
    end
  end
  self.node_by_name[fullname] = node
end

function BindingContext:get_canonical_node(node)
  while node.tag == 'CType' do
    local typename = node[1]
    if ctype_to_nltype[typename] then
      break
    end
    local resolved_node = self.node_by_name[typename]
    if resolved_node and resolved_node ~= node then
      node = resolved_node
    else
      break
    end
  end
  return node
end

function BindingContext:get_canonical_imported_node(node)
  if node.import then
    return node
  end
  while node.tag == 'CType' do
    local typename = node[1]
    if ctype_to_nltype[typename] then
      break
    end
    local resolved_node = self.node_by_name[typename]
    if resolved_node and not resolved_node.import and resolved_node ~= node then
      node = resolved_node
    else
      break
    end
  end
  return node
end

function BindingContext:resolve_typename(fullname)
  -- try primitive types first
  local typename = ctype_to_nltype[fullname]
  if typename then return typename end
  -- check if type is already included
  if self.declared_names[fullname] then
    return fullname
  end
  return self.node_by_name[fullname]
end

function BindingContext:normalize_param_name(name)
  name = name:gsub('^__', '') -- strip `__` prefix from C lib internal names
  while reserved_names[name] do
    name = name..'_'
  end
  while true do
    local namenode = self.node_by_name[name]
    if not namenode or namenode.tag == 'CVarDecl' or namenode.tag == 'CFuncDecl' then
      break
    end
    name = '_'..name
  end
  return name
end

function BindingContext.normalize_field_name(_, name)
  while reserved_names[name] do
    name = name..'_'
  end
  return name
end

function BindingContext:get_or_generate_import_name(name, node)
  local typedefname = self.typedefname_by_node[node]
  if typedefname then return typedefname, false end
  if not name then return nil, false end
  typedefname = name
  while self.node_by_name[typedefname] do
    typedefname = typedefname..'_t'
  end
  self.typedefname_by_node[node] = typedefname
  self.node_by_name[typedefname] = node
  return typedefname, true
end

-------------------------------------------------------------------------------
-- Binding pass

local parse_declarator
local parse_type

local function parse_extensions(node, attr)
  if node.tag == 'extension-specifiers' then
    for _,extnode in ipairs(node) do
      parse_extensions(extnode, attr)
    end
  elseif node.tag == 'extension-specifier' then
    local extnode = node[1]
    if extnode.tag == 'extension' then
      attr.__extension__ = true
    elseif extnode.tag == 'attribute' then
      for _,attrib in ipairs(extnode) do
        local attrname = attrib[1]
        attr[attrname] = true
        -- TODO: parse arguments
      end
    end
    -- TODO: fill asm attribute?
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

local cintmin, cintmax = -(1<<31), (1<<31)-1

local function parse_constant_expression(context, node)
  --TODO: handle overflow in operations
  if node.tag == 'integer-constant' then
    local value = node[1]
    value = value:lower():gsub('u?l?l?$', '') -- trim suffixes
    if value:find('^0x[0-9a-f]+$') then -- hexadecimal
      return tonumber(value:match('^0x([0-9a-f]+)$'), 16)
    elseif value:find('^0[0-7]+$') then -- octal
      return tonumber(value, 8)
    elseif value:find('^[0-9]+$') then -- decimal
      return tonumber(value, 10)
    end
  elseif node.tag == 'character-constant' then
    local char = node[1]
    return string.byte(char)
  elseif node.tag == 'identifier' then
    local name = node[1]
    return context.constants_integers[name]
  elseif node.tag == 'unary-op' then
    local op, val = node[1], parse_constant_expression(context, node[2])
    if val then
      if op == '-' and val > cintmin then
        return -val
      --TODO: we need actually to wrap around to use binary negation?
      -- elseif op == '~' then
        -- return ~val
      end
    end
  elseif node.tag == 'binary-op' then
    local lhs, op, rhs =
      parse_constant_expression(context, node[1]), node[2], parse_constant_expression(context, node[3])
    if lhs and rhs then
      if op == '<<' and lhs >= 0 and rhs >= 0 and rhs < 32 then
        return lhs << rhs
      elseif op == '>>' and rhs >= 0 and rhs < 32 then
        return lhs >> rhs
      elseif op == '|' then
        return lhs | rhs
      elseif op == '&' then
        return lhs & rhs
      elseif op == '^' then
        return lhs ~ rhs
      elseif op == '+' then
        return lhs + rhs
      elseif op == '-' then
        return lhs - rhs
      elseif op == '*' then
        return lhs * rhs
      elseif op == '/' and lhs >= 0 and rhs > 0 then
        return lhs // rhs
      end
    elseif op == 'cast' and rhs then
      local typenode = parse_type(context, node[1][1], {})
      local canonicalnode = context:get_canonical_node(typenode)
      if canonicalnode and canonicalnode.tag == 'CType' then
        local ctypename = canonicalnode[1]
        -- TODO: handle more types and actually wrap around values
        if ctypename == 'int' and rhs >= cintmin and rhs <= cintmax then
          return rhs
        elseif ctypename == 'uint32_t' and rhs >= 0 and rhs <= 0xffffffff then
          return rhs
        elseif ctypename == 'uint8_t' and rhs >= 0 and rhs <= 0xff then
          return rhs
        end
      end
    end
  elseif node.tag == 'expression' and #node == 1 then
    return parse_constant_expression(context, node[1])
  end
  --TODO: ternary op and comparisons
end

local function parse_struct_or_union(context, node, attr)
  local kind, extensions, name, fielddecllist  = node[1], node[2], node[3], node[4]
  if extensions then
    parse_extensions(extensions, attr)
  end
  local fullname, typenode
  if name then -- has name (not anonymous)
    fullname = kind..'#'..name
  end
  if fielddecllist then -- must declare fields
    local fields = {}
    for _,fieldnode in ipairs(fielddecllist) do
      if fieldnode.tag == 'struct-declaration' then
        local specifiers, structdeclatorlist = fieldnode[1], fieldnode[2]
        local firstattr = {}
        local firsttypenode = parse_type(context, specifiers, firstattr)
        assert(firsttypenode)
        if structdeclatorlist then
          for _,structdeclator in ipairs(structdeclatorlist) do
            local declarator = structdeclator[1]
            local fieldattr = tabler.copy(firstattr)
            local fieldtypenode, fieldname
            if declarator then
              fieldtypenode, fieldname = parse_declarator(context, declarator, firsttypenode, fieldattr)
            else
              fieldtypenode = firsttypenode
              fieldname = '__unnamed'..(#fields+1)
            end
            assert(fieldtypenode and fieldname)
            local field = {tag='CField', attr=fieldattr, fieldname, fieldtypenode}
            table.insert(fields, field)
          end
        else -- field without a name
          local fieldname = '__unnamed'..(#fields+1)
          local field = {tag='CField', attr=firstattr, fieldname, firsttypenode}
          table.insert(fields, field)
        end
      end
    end
    typenode = {tag='CStructOrUnionType', kind, name, fields}
    table.insert(context.types_ast, {tag='CTypeDecl', fullname, typenode})
    if fullname then
      context:define_symbol(fullname, typenode)
    end
  else
    assert(fullname, 'struct or union must have a name or declaration')
    typenode = {tag='CType', fullname}
    if not context.node_by_name[fullname] then -- not defined yet
      local opaquetype = {tag='COpaqueType', kind, name}
      context:define_symbol(fullname, opaquetype)
      table.insert(context.types_ast, {tag='CTypeDecl', fullname, opaquetype})
    end
  end
  return typenode
end

local function parse_enum(context, node, attr)
  local extensions, name, enumlist = node[1], node[2], node[3]
  if extensions then
    parse_extensions(extensions, attr)
  end
  local fullname, typenode
  if name then -- has name (not anonymous)
    fullname = 'enum#'..name
  end
  if enumlist then -- has fields (not opaque)
    local fields = {}
    local inttype = 'int'
    typenode = {tag='CEnumType', inttype, name, fields}
    table.insert(context.types_ast, {tag='CTypeDecl', fullname, typenode})
    if fullname then
      context:define_symbol(fullname, typenode)
    end
    -- fill fields
    local lastvalue = -1
    local minvalue, maxvalue
    for _,enumfield in ipairs(enumlist) do
      local fieldname, fieldexpr = enumfield[1][1], enumfield[2]
      local fieldvalue
      if fieldexpr then
        fieldvalue = parse_constant_expression(context, fieldexpr)
      elseif lastvalue then
        fieldvalue = lastvalue + 1
      end
      if fieldvalue then
        if not maxvalue or fieldvalue > maxvalue then
          maxvalue = fieldvalue
        end
        if not minvalue or fieldvalue < minvalue then
          minvalue = fieldvalue
        end
        context.constants_integers[fieldname] = fieldvalue
      end
      local fieldnode = {tag='CEnumField', fieldname, fieldvalue, typenode}
      table.insert(fields, fieldnode)
      lastvalue = fieldvalue
      context:define_symbol(fieldname, fieldnode)
    end
    if minvalue and maxvalue then
      if minvalue >= 0 and maxvalue > (1<<31)-1 then
        inttype = 'unsigned int'
      end
      typenode[1] = inttype
    end
  else -- opaque enum
    assert(fullname, 'enum must have a name or declaration')
    typenode = {tag='CType', fullname}
    if not context.node_by_name[fullname] then -- not defined yet
      local opaquetype = {tag='COpaqueType', 'enum', name}
      context:define_symbol(fullname, opaquetype)
      table.insert(context.types_ast, {tag='CTypeDecl', fullname, opaquetype})
    end
  end
  return typenode
end

-- Retrieves Nelua type and its attr from declaration specifiers node.
function parse_type(context, node, attr)
  local ctype
  local widthprefix, signprefix, complexsuffix
  for _,specifier in ipairs(node) do
    if specifier.tag == 'type-specifier' then
      local typespecifier = specifier[1]
      if typespecifier == 'long long' or typespecifier == 'long' or typespecifier == 'short' then
        widthprefix = typespecifier
        ctype = ctype or 'int'
      elseif typespecifier == 'unsigned' or typespecifier == 'signed' then
        signprefix = typespecifier
        ctype = ctype or 'int'
      elseif typespecifier == '_Complex' or typespecifier == '_Imaginary' then
        complexsuffix = typespecifier
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
      else
        -- TODO: handle typeof?
        error('unhandled '..typespecifier.tag)
      end
    elseif specifier.tag == 'type-qualifier' or
           specifier.tag == 'storage-class-specifier' or
           specifier.tag == 'function-specifier' then
      parse_qualifiers(specifier, attr)
    elseif specifier.tag == 'alignment-specifier' then
      -- TODO: handle _Alignas?
      attr._Alignas = true
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

function parse_declarator(context, node, firsttypenode, attr)
  if node.tag == 'identifier' then -- identifier associated with the type
    return firsttypenode, node[1]
  elseif node.tag == 'typedef-identifier' then -- typedef type
    return firsttypenode, node[1][1]
  elseif node.tag == 'pointer' then -- pointer type
    local extensions, qualifiers = node[1], node[2]
    local subnode = #node >= 3 and node[#node]
    if qualifiers then
      parse_qualifiers(qualifiers, attr)
    end
    if extensions then
      parse_extensions(extensions, attr)
    end
    if subnode then -- pointer with an identifier
      return parse_declarator(context, subnode, {tag='CPointerType', firsttypenode}, attr)
    else -- pointer without an identifier (used by function pointers without a name)
      return {tag='CPointerType', firsttypenode}, nil
    end
  elseif node.tag == 'declarator-subscript' then -- fixed array type
    local subnode = #node >= 3 and node[1]
    local lennode = node[#node]
    -- TODO: do we need to parse specifiers?
    local subtypenode, name = firsttypenode, nil
    if subnode then
      subtypenode, name = parse_declarator(context, subnode, firsttypenode, attr)
    end
    local len
    if lennode then -- size is available
      len = parse_constant_expression(context, lennode)
    end
    local typenode = {tag='CArrayType', subtypenode, len}
    -- invert len sizes for multidimensional arrays
    local topsubtype = typenode
    while subtypenode.tag == 'CArrayType' do
      subtypenode[2], topsubtype[2] = topsubtype[2], subtypenode[2]
      topsubtype, subtypenode = subtypenode, subtypenode[1]
    end
    return typenode, name
  elseif node.tag == 'declarator-parameters' then -- function typenode
    local namenode, paramlist = node[1], node[2]
    local params = {}
    local functypenode = {tag='CFuncType', params, firsttypenode}
    local typenode, name = parse_declarator(context, namenode, functypenode, attr)
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
    elseif paramlist then
      error('function identifier-list not supported yet')
    end
    return typenode, name
  elseif node.tag == 'declarator' then
    local extensions = node[2]
    if extensions then
      parse_extensions(extensions, attr)
    end
    return parse_declarator(context, node[1], firsttypenode, attr)
  elseif node.tag == 'type-name' then
    local specifiers, declarator = node[1], node[2]
    assert(specifiers.tag == 'specifier-qualifier-list')
    firsttypenode = parse_type(context, specifiers, attr)
    if declarator then
      return parse_declarator(context, declarator, firsttypenode, attr), nil
    else
      return firsttypenode, nil
    end
  else
    error('unhandled '..node.tag)
  end
end

local parse_bindings_visitors = {}

parse_bindings_visitors['type-declaration'] = function(context, node)
  local specifiers, initdeclatorlist = node[1], node[2]
  local firstattr = {}
  local firsttypenode = parse_type(context, specifiers, firstattr)
  if initdeclatorlist then -- variable declaration
    for _,initdeclarator in ipairs(initdeclatorlist) do
      local declarator = initdeclarator[1]
      local attr = tabler.copy(firstattr)
      local typenode, name = parse_declarator(context, declarator, firsttypenode, attr)
      assert(typenode and name)
      local declnode
      if typenode.tag == 'CFuncType' then
        declnode = {tag='CFuncDecl', attr=attr, name, typenode}
      else
        declnode = {tag='CVarDecl', attr=attr, name, typenode}
      end
      table.insert(context.vars_ast, declnode)
      context:define_symbol(name, declnode)
    end
  end
end

parse_bindings_visitors['typedef-declaration'] = function(context, node)
  local specifiers = node[1]
  local firstattr = {}
  local firsttypenode = parse_type(context, specifiers, firstattr)
  for i=2,#node do
    local declarator = node[i]
    local attr = tabler.copy(firstattr)
    local typenode, name = parse_declarator(context, declarator, firsttypenode, attr)
    assert(typenode and name)
    local canonicalnode = context:get_canonical_node(typenode)
    context:define_symbol(name, typenode)
    context.typedefname_by_node[typenode] = name
    local curname = context.typedefname_by_node[canonicalnode]
    if not curname or not context:can_include_name(curname) then
      context.typedefname_by_node[canonicalnode] = name
    end
    table.insert(context.types_ast, {tag='CTypedef', attr=attr, name, typenode})
  end
end

parse_bindings_visitors['function-definition'] = function(context, node)
  local specifiers, declarator, declarationlist = node[1], node[2], node[3]
  assert(#declarationlist == 0, 'declaration list in function definition is not supported yet')
  local attr = {}
  local firsttypenode = parse_type(context, specifiers, attr)
  local typenode, name = parse_declarator(context, declarator, firsttypenode, attr)
  assert(typenode and name)
  assert(typenode.tag == 'CFuncType')
  local declnode = {tag='CFuncDecl', attr=attr, name, typenode}
  table.insert(context.vars_ast, declnode)
  context:define_symbol(name, declnode)
end

parse_bindings_visitors['declaration'] = function(context, node)
  context:traverse_nodes(node)
end

local function parse_c_bindings(context)
  context.visitors = parse_bindings_visitors
  context:traverse_nodes(context.c_ast)
  context:mark_imports()
end

-------------------------------------------------------------------------------
-- Generator

local generate_bindings_visitors = {}

function generate_bindings_visitors.CType(context, node, emitter)
  local canonicalnode = context:get_canonical_imported_node(node)
  if canonicalnode ~= node  then
    context:traverse_node(canonicalnode, emitter)
  else
    local name = node[1]
    local resolvedtype = context:resolve_typename(name)
    if type(resolvedtype) == 'string' then
      emitter:add(resolvedtype)
    else -- a node
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

function generate_bindings_visitors.CArrayType(context, node, emitter)
  local subtypenode, len = node[1], node[2]
  emitter:add('['..(len or 0)..']')
  context:traverse_node(subtypenode, emitter)
end

function generate_bindings_visitors.CVarargsType(_, _, emitter)
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
  local canonicalnode = context:get_canonical_node(typenode)
  if canonicalnode.tag == 'CArrayType' then -- function parameter pass by pointer
    emitter:add('*')
  end
  context:traverse_node(typenode, emitter)
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
  local kind, name, fieldnodes = node[1], node[2], node[3]
  local importname, generated = context:get_or_generate_import_name(name, node)
  local decl = params and params.decl
  if not (importname or not decl) then -- no name or declaration, just ignore it
    return
  end
  if not decl and importname then
    emitter:add(importname)
    return
  end
  if importname then
    if context.declared_names[importname] then return end
    context.declared_names[importname] = true
  end
  if decl then
    if context.forward_declared_names[importname] then -- already predeclared
      emitter:add(importname.." = @")
    else
      local annotations = {"cimport", "nodecl"}
      if generated then
        table.insert(annotations, "ctypedef'"..name.."'")
      end
      emitter:add("global "..importname..": type <"..table.concat(annotations,',').."> = @")
    end
  end
  local typekind = kind == 'struct' and 'record' or 'union'
  emitter:add(typekind)
  if #fieldnodes > 0 then
    emitter:add_ln('{')
    emitter:inc_indent()
    for i,fieldnode in ipairs(fieldnodes) do
      local fieldname, fieldtypenode = fieldnode[1], fieldnode[2]
      fieldname = context:normalize_field_name(fieldname)
      emitter:add_indent(fieldname..': ')
      context:traverse_node(fieldtypenode, emitter)
      if i < #fieldnodes then
        emitter:add(',')
      end
      emitter:add_ln()
    end
    emitter:dec_indent()
    emitter:add_indent('}')
  else
    emitter:add('{}')
  end
  if decl then
    emitter:add_ln()
  end
end

function generate_bindings_visitors.CEnumType(context, node, emitter, params)
  local cintname, name, fields = node[1], node[2], node[3]
  local importname, generated = context:get_or_generate_import_name(name, node)
  local intname = ctype_to_nltype[cintname]
  local decl = params and params.decl
  if not decl then -- not a declaration, just emit enum name
    emitter:add(importname or intname)
    return
  end
  if importname then
    if context.declared_names[importname] then return end
    context.declared_names[importname] = true
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
        if field.import and not context.declared_names[fieldname] then
          context.declared_names[fieldname] = true
          emitter:add_indent_ln("global "..fieldname..': '..intname..' <comptime> = '..fieldvalue)
        end
      end
    else -- has unknown fields
      for _,field in ipairs(fields) do
        local fieldname = field[1]
        if field.import and not context.declared_names[fieldname] then
          context.declared_names[fieldname] = true
          emitter:add_indent_ln("global "..fieldname..': '..intname..' <cimport,nodecl,const>')
        end
      end
    end
  else -- enum has a name
    if knowallfields then -- all fields are known
      local annotations = {"cimport", "nodecl", "using"}
      if generated then
        table.insert(annotations, "ctypedef'"..name.."'")
      end
      emitter:add_ln("global "..importname..": type <"..table.concat(annotations,',')..">"..
                     " = @enum("..intname.."){")
      emitter:inc_indent()
      for i,field in ipairs(fields) do
        local fieldname, fieldvalue = field[1], field[2]
        local sep = i < (#fields) and ',' or ''
        emitter:add_indent_ln(fieldname..' = '..fieldvalue..sep)
      end
      emitter:dec_indent()
      emitter:add_ln('}')
    else -- not all fields are known
      emitter:add_ln("global "..importname..": type = @"..intname)
      for _,field in ipairs(fields) do
        local fieldname = field[1]
        if not context.declared_names[fieldname] then
          context.declared_names[fieldname] = true
          emitter:add_indent_ln("global "..fieldname..': '..intname..' <cimport,nodecl,const>')
        end
      end
    end
  end
end

function generate_bindings_visitors.COpaqueType(context, node, emitter, params)
  local decl = params and params.decl
  local kind, name = node[1], node[2]
  local fullname = kind..'#'..name
  local typenode = context.node_by_name[fullname]
  local importname, generated = context:get_or_generate_import_name(name, typenode)
  if decl then
    if kind == 'enum' and typenode.tag == 'CEnumType' then -- define the enum early
      context:traverse_node(typenode, emitter, {decl=true})
      return
    end
    if kind ~= 'enum' then
      if context.forward_declared_names[importname] then return end -- already forward declared
      context.forward_declared_names[importname] = true
    else
      if context.declared_names[importname] then return end
      context.declared_names[importname] = true
    end
    local annotations = {"cimport", 'nodecl'}
    if generated then
      table.insert(annotations, "ctypedef'"..name.."'")
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
    emitter:add(importname or fullname)
  end
end

function generate_bindings_visitors.CFuncDecl(context, node, emitter)
  if not node.import then return end
  local name, functypenode = node[1], node[2]
  if context.declared_names[name] then return end
  context.declared_names[name] = true
  emitter:add('global function '..name)
  context:traverse_node(functypenode, emitter, {decl=true})
  emitter:add_ln(' <cimport,nodecl> end')
end

function generate_bindings_visitors.CVarDecl(context, node, emitter)
  if not node.import then return end
  local name, typenode = node[1], node[2]
  if context.declared_names[name] then return end
  context.declared_names[name] = true
  emitter:add('global '..name..': ')
  context:traverse_node(typenode, emitter)
  emitter:add(' <cimport,nodecl>')
  emitter:add_ln()
end

function generate_bindings_visitors.CTypeDecl(context, node, emitter)
  if not node.import then return end
  local typenode = node[2]
  context:traverse_node(typenode, emitter, {decl=true})
end

function generate_bindings_visitors.CTypedef(context, node, emitter)
  if not node.import then return end
  local name, typenode = node[1], node[2]
  if context.declared_names[name] or context.forward_declared_names[name] then return end
  context.declared_names[name] = true
  emitter:add('global '..name..': type <cimport,nodecl> = @')
  context:traverse_node(typenode, emitter)
  emitter:add_ln()
end

local function generate_nelua_bindings(context)
  local emitter = Emitter()
  context.emitter = emitter
  context.visitors = generate_bindings_visitors
  context:traverse_nodes(context.types_ast, emitter)
  context:traverse_nodes(context.vars_ast, emitter)
  return emitter:generate()
end

-------------------------------------------------------------------------------
local nldecl = {}

function nldecl.generate_bindings_from_c_code(ccode, opts)
  local context = BindingContext.create(opts)
  context.c_ast = parse_c11(ccode)
  parse_c_bindings(context)
  return generate_nelua_bindings(context)
end

local function gen_c_file(ccode)
  local cfilename = fs.tmpname()
  fs.deletefile(cfilename) -- we have to delete the tmp file
  cfilename = cfilename..'.c'
  assert(fs.writefile(cfilename, ccode))
  return cfilename
end

local function emit_c_includes_code(opts)
  local cemitter = Emitter()
  if opts.parse_defines then
    for _,define in ipairs(opts.parse_defines) do
      cemitter:add_ln('#define ', define)
    end
  end
  for _,include in ipairs(opts.parse_includes) do
    if not include:match('^[<"].*[>"]$') then
      include = '<'..include..'>'
    end
    cemitter:add_ln('#include ', include)
  end
  return cemitter:generate()
end

local function preprocess_c_code(ccode, opts)
  local cfilename = gen_c_file(ccode)
  local cc = opts.cc or 'gcc'
  local ccargs = {
    '-E',
    -- '-P',
    -- '-dD',
    cfilename
  }
  local ok, status, stdout, stderr = executor.execex(cc, ccargs)
  fs.deletefile(cfilename)
  assert(ok and stdout, stderr or 'failed to preprocess C code')
  return stdout
end

local function parse_defines(ccode, opts)
  for line in ccode:gmatch('\n#[^\n]*\n') do
    print(line)
  end
end

function nldecl.generate_bindings_file(opts)
  local ccode = emit_c_includes_code(opts)
  ccode = preprocess_c_code(ccode, opts)
  parse_defines(ccode)
  local neluacode = nldecl.generate_bindings_from_c_code(ccode, opts)
  if opts.output_head then
    neluacode = opts.output_head..neluacode
  end
  if opts.output_foot then
    neluacode = neluacode..opts.output_foot
  end
  assert(fs.makefile(opts.output_file, neluacode))
end

return nldecl
