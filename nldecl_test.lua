local nldecl = require 'nldecl2'
local lester = require 'lester'
local describe, it, expect = lester.describe, lester.it, lester.expect

local function expect_bindings(c_code, expected_nelua_code, opts)
  local nelua_code = nldecl.generate_bindings_from_c_code(c_code, opts)
  if #expected_nelua_code > 0 and expected_nelua_code:sub(-1,-1) ~= '\n' then -- always ends with new line
    expected_nelua_code = expected_nelua_code..'\n'
  end
  expect.equal(nelua_code, expected_nelua_code)
end

describe('nldecl', function()

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
                  [[global x: [0]cint <cimport,nodecl>]])
  expect_bindings([[int x[0];]],
                  [[global x: [0]cint <cimport,nodecl>]])
  expect_bindings([[int x[4];]],
                  [[global x: [4]cint <cimport,nodecl>]])
  expect_bindings([[int x[3][2][1];]],
                  [[global x: [3][2][1]cint <cimport,nodecl>]])
  expect_bindings([[int x[sizeof(int)];]], [[global x: [0]cint <cimport,nodecl>]])
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
  expect_bindings([[_Atomic(int*) x;]],
                  [[global x: *cint <cimport,nodecl>]])
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
  expect_bindings([[void f(int[]);]],
                  [[global function f(a1: *[0]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x[]);]],
                  [[global function f(x: *[0]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int[4]);]],
                  [[global function f(a1: *[4]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x[4]);]],
                  [[global function f(x: *[4]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int[3][2][1]);]],
                  [[global function f(a1: *[3][2][1]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int x[3][2][1]);]],
                  [[global function f(x: *[3][2][1]cint): void <cimport,nodecl> end]])
  expect_bindings([[void f(int[sizeof(int)]);]],
                  [[global function f(a1: *[0]cint): void <cimport,nodecl> end]])
  -- valist parameter
  expect_bindings([[int vsprintf(char*restrict s, const char*restrict format, __builtin_va_list arg);]],
                  [[global function vsprintf(s: cstring, format: cstring, arg: cvalist): cint <cimport,nodecl> end]])
  -- varargs parameter
  expect_bindings([[void f(int, ...);]],
                  [[global function f(a1: cint, ...: cvarargs): void <cimport,nodecl> end]])
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

it("function definitions", function()
  expect_bindings([[void f(){}]],
                  [[global function f(): void <cimport,nodecl> end]])
  expect_bindings([[void f(void){}]],
                  [[global function f(): void <cimport,nodecl> end]])
  expect_bindings([[int f(int){}]],
                  [[global function f(a1: cint): cint <cimport,nodecl> end]])
  expect_bindings([[int f(int x){}]],
                  [[global function f(x: cint): cint <cimport,nodecl> end]])
end)

it("enum type", function()
  expect_bindings([[enum E* e;]], [[
global E: type <cimport,nodecl,ctypedef'E'> = @cint
global e: *E <cimport,nodecl>
]])
  expect_bindings([[enum E; enum E* e;]], [[
global E: type <cimport,nodecl,ctypedef'E'> = @cint
global e: *E <cimport,nodecl>
]])
  expect_bindings([[typedef enum E E; E* e;]], [[
global E: type <cimport,nodecl> = @cint
global e: *E <cimport,nodecl>
]])
  expect_bindings([[enum E; typedef enum E E; E* e;]],[[
global E: type <cimport,nodecl> = @cint
global e: *E <cimport,nodecl>
]])
  expect_bindings([[enum E{EA, EB}; enum E e;]], [[
global E: type <cimport,nodecl,using,ctypedef'E'> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[typedef enum{EA, EB} E; E e;]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[typedef enum E{EA, EB} E; E e;]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[typedef enum E{EA, EB} E_t; E_t e;]], [[
global E_t: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E_t <cimport,nodecl>
]])
  expect_bindings([[typedef enum E{EA, EB}* E_p; E_p e;]], [[
global E: type <cimport,nodecl,using,ctypedef'E'> = @enum(cint){
  EA = 0,
  EB = 1
}
global E_p: type <cimport,nodecl> = @*E
global e: E_p <cimport,nodecl>
]])
  expect_bindings([[
enum E{EA, EB};
typedef enum E E;
E e;
]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[enum {EA, EB};]], [[
global EA: cint <comptime> = 0
global EB: cint <comptime> = 1
]])
  expect_bindings([[
typedef enum E E;
enum E {EA, EB};
enum E a;
E b;
]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global a: E <cimport,nodecl>
global b: E <cimport,nodecl>
]])
  expect_bindings([[
enum E;
typedef enum E E;
enum E {EA, EB};
E e;
]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[
typedef enum E E;
E e;
enum E {EA, EB};
]], [[
global E: type <cimport,nodecl,using> = @enum(cint){
  EA = 0,
  EB = 1
}
global e: E <cimport,nodecl>
]])
  expect_bindings([[enum {A = 1, B = sizeof(int)};]], [[
global A: cint <cimport,nodecl,const>
global B: cint <cimport,nodecl,const>
]])
  expect_bindings([[
typedef enum __myenum {A = 0, B = sizeof(int)} __myenum_t;
int f(__myenum_t e);
]], [[
global __myenum_t: type = @cint
global A: cint <cimport,nodecl,const>
global B: cint <cimport,nodecl,const>
global function f(e: __myenum_t): cint <cimport,nodecl> end
]])
  expect_bindings([[
typedef enum E {A = 0, B = 0x80000000u, C=0xffffffffu} E;
]], [[
global E: type <cimport,nodecl,using> = @enum(cuint){
  A = 0,
  B = 2147483648,
  C = 4294967295
}
]])
  expect_bindings([[
typedef enum {
  ZERO,
  LAST = ZERO,
  ONE,
  FORCE_UINT32 = 0xFFFFFFFF
} E;
]], [[
global E: type <cimport,nodecl,using> = @enum(cuint){
  ZERO = 0,
  LAST = 0,
  ONE = 1,
  FORCE_UINT32 = 4294967295
}
]])
end)

it("struct type", function()
  expect_bindings([[struct{} s;]], [[global s: record{} <cimport,nodecl>]])
  expect_bindings([[struct S{}; struct S s;]], [[
global S: type <cimport,nodecl,ctypedef'S'> = @record{}
global s: S <cimport,nodecl>
]])
  expect_bindings([[typedef struct S{} S;]],
                  [[global S: type <cimport,nodecl> = @record{}]])
  expect_bindings([[struct S{}; typedef struct S S;]],
                  [[global S: type <cimport,nodecl> = @record{}]])
  expect_bindings([[typedef struct{} S;]],
                  [[global S: type <cimport,nodecl> = @record{}]])
  expect_bindings([[struct S; struct S{};]],
                  [[global S: type <cimport,nodecl,ctypedef'S'> = @record{}]])
  -- ignore
  expect_bindings([[typedef struct{} va_list;]], [[]])
  expect_bindings([[struct va_list{};]], [[]])
  expect_bindings([[typedef struct va_list{} va_list;]], [[]])
  expect_bindings([[typedef struct{}* va_list;]], [[]])
end)

it("struct fields", function()
  expect_bindings([[typedef struct S{int;} S;]], [[
global S: type <cimport,nodecl> = @record{
  __unnamed1: cint
}]])
  expect_bindings([[typedef struct S{int x;} S;]], [[
global S: type <cimport,nodecl> = @record{
  x: cint
}]])
  expect_bindings([[typedef struct S{int x, y;} S;]], [[
global S: type <cimport,nodecl> = @record{
  x: cint,
  y: cint
}]])
  expect_bindings([[typedef struct S{int end;} S;]], [[
global S: type <cimport,nodecl> = @record{
  end_: cint
}]])
end)

it("struct bit fields", function()
  expect_bindings([[typedef struct S{int x:32;} S;]], [[
global S: type <cimport,nodecl> = @record{
  x: cint
}]])
  expect_bindings([[typedef struct S{int :32;} S;]], [[
global S: type <cimport,nodecl> = @record{
  __unnamed1: cint
}]])
end)

it("constant expressions", function()
  expect_bindings([[
typedef unsigned char uint8_t;
typedef unsigned int uint32_t;
enum {
  constant_add = 3 + 2,
  constant_sub = 3 - 2,
  constant_mul = 3 * 2,
  constant_idiv = 3 / 2,
  constant_unm = -1,
  constant_shl = 3 << 2,
  constant_shr = 3 >> 1,
  constant_bor = 1 | 2,
  constant_band = 3 & 2,
  constant_bxor = 3 ^ 1,
  constant_expr = (1),
  constant_hexa = 0xffff,
  constant_octa = 07777,
  constant_char = 'A',
  constant_cast_int = (int)1,
  constant_cast_u8 = (uint8_t)1,
  constant_cast_u32 = (uint32_t)1,
  constant_first = constant_add,
};
]], [[
global constant_add: cint <comptime> = 5
global constant_sub: cint <comptime> = 1
global constant_mul: cint <comptime> = 6
global constant_idiv: cint <comptime> = 1
global constant_unm: cint <comptime> = -1
global constant_shl: cint <comptime> = 12
global constant_shr: cint <comptime> = 1
global constant_bor: cint <comptime> = 3
global constant_band: cint <comptime> = 2
global constant_bxor: cint <comptime> = 2
global constant_expr: cint <comptime> = 1
global constant_hexa: cint <comptime> = 65535
global constant_octa: cint <comptime> = 4095
global constant_char: cint <comptime> = 65
global constant_cast_int: cint <comptime> = 1
global constant_cast_u8: cint <comptime> = 1
global constant_cast_u32: cint <comptime> = 1
global constant_first: cint <comptime> = 5
]])
  expect_bindings([[
enum {
  intmax = 0x7fffffff,
  intmin = -0x7fffffff - 1
};
enum {
  uintmax = 0xffffffffu,
};
]], [[
global intmax: cint <comptime> = 2147483647
global intmin: cint <comptime> = -2147483648
global uintmax: cuint <comptime> = 4294967295
]])
end)

it("forward declaration", function()
  expect_bindings([[struct S; struct S* s;]], [[
global S: type <cimport,nodecl,ctypedef'S',forwarddecl> = @record{}
global s: *S <cimport,nodecl>
]])
  expect_bindings([[struct S; struct S* s; struct S{};]], [[
global S: type <cimport,nodecl,ctypedef'S'> = @record{}
global s: *S <cimport,nodecl>
]])
  expect_bindings([[typedef struct S S; S* s;]], [[
global S: type <cimport,nodecl,forwarddecl> = @record{}
global s: *S <cimport,nodecl>
]])
  expect_bindings([[struct S; typedef struct S S; S* s;]], [[
global S: type <cimport,nodecl,forwarddecl> = @record{}
global s: *S <cimport,nodecl>
]])
  expect_bindings([[union U; union U* u;]], [[
global U: type <cimport,nodecl,ctypedef'U',forwarddecl> = @union{}
global u: *U <cimport,nodecl>
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
  expect_bindings([[
typedef struct _G_fpos64_t{} __fpos64_t;
typedef __fpos64_t fpos_t;
]], [[
global fpos_t: type <cimport,nodecl> = @record{}
]])
end)

it("force include excluded dependent types", function()
  expect_bindings([[
struct __locale_struct{};
typedef struct __locale_struct locale_t;
]], [[
global locale_t: type <cimport,nodecl> = @record{}
]])
  expect_bindings([[
struct __locale_struct{};
typedef struct __locale_struct __locale_t;
typedef __locale_t locale_t;
]], [[
global locale_t: type <cimport,nodecl> = @record{}
]])
  expect_bindings([[
struct __locale_struct{};
typedef struct __locale_struct* __locale_t;
typedef __locale_t locale_t;
]], [[
global __locale_struct: type <cimport,nodecl,ctypedef'__locale_struct'> = @record{}
global locale_t: type <cimport,nodecl> = @*__locale_struct
]])
  expect_bindings([[
typedef struct{} __my_struct;
int f(__my_struct s);
]], [[
global __my_struct: type <cimport,nodecl> = @record{}
global function f(s: __my_struct): cint <cimport,nodecl> end
]])
end)

it("import name collision", function()
  expect_bindings([[
long int timezone;
struct timezone{int tz_minuteswest; int tz_dsttime;};
int settimeofday(void* tv, struct timezone *tz);
]], [[
global timezone_t: type <cimport,nodecl,ctypedef'timezone'> = @record{
  tz_minuteswest: cint,
  tz_dsttime: cint
}
global timezone: clong <cimport,nodecl>
global function settimeofday(tv: pointer, tz: *timezone_t): cint <cimport,nodecl> end
]])
  expect_bindings([[int S; struct S; struct S* s;]], [[
global S_t: type <cimport,nodecl,ctypedef'S',forwarddecl> = @record{}
global S: cint <cimport,nodecl>
global s: *S_t <cimport,nodecl>
]])
  expect_bindings([[int S; int S_t; struct S; struct S* s;]], [[
global S_t_t: type <cimport,nodecl,ctypedef'S',forwarddecl> = @record{}
global S: cint <cimport,nodecl>
global S_t: cint <cimport,nodecl>
global s: *S_t_t <cimport,nodecl>
]])
end)

it("reserved names", function()
  expect_bindings([[typedef void(*function)(void); function f;]],
                  [[global f: function(): void <cimport,nodecl>]])
  expect_bindings([[void f(void* function);]],
                  [[global function f(function_: pointer): void <cimport,nodecl> end]])
  expect_bindings([[typedef unsigned int uint; uint x;]],
                  [[global x: cuint <cimport,nodecl>]])
  expect_bindings([[typedef unsigned int uint; void f(uint uint);]],
                  [[global function f(_uint: cuint): void <cimport,nodecl> end]])

end)

it("excluded names", function()
  expect_bindings([[typedef float float_t;]], [[]])
  expect_bindings([[float float_t;]], [[]])
  expect_bindings([[float myvar; float MY_var;]], [[]], {exclude_names={'^MY_',myvar=true}})
  expect_bindings([[float MY_var;]], [[global MY_var: float32 <cimport,nodecl>]],
    {exclude_names={'^MY_'},include_names={MY_var=true}})
  expect_bindings([[float MY_var1, MY_var2, my_var;]], [[global MY_var2: float32 <cimport,nodecl>]],
    {exclude_names={MY_var1=true},include_names={'^MY_'}})
end)

it("opaque names", function()
  expect_bindings([[
typedef struct S S;
struct S s;
struct S {int x;};
]], [[
global S: type <cimport,nodecl,forwarddecl> = @record{}
S = @record{
  x: cint
}
global s: S <cimport,nodecl>
]])
  expect_bindings([[
typedef struct {
  int x;
} FILE;
FILE* stdout;
]], [[
global FILE: type <cimport,nodecl,cincomplete> = @record{}
global stdout: *FILE <cimport,nodecl>
]])
  expect_bindings([[
struct _IO_FILE;
typedef struct _IO_FILE __FILE;
typedef struct _IO_FILE FILE;
struct _IO_FILE{};
FILE* stdout;
]], [[
global FILE: type <cimport,nodecl,cincomplete> = @record{}
global stdout: *FILE <cimport,nodecl>
]], {exclude_names = {'^_'}})
end)

it("define constants", function()
  expect_bindings([[#define MYDEF 1]], [[global MYDEF: cint <comptime> = 1]])
  expect_bindings([[
#define v_ull 1ull
#define v_llu 1ull
#define v_ul 1ul
#define v_lu 1lu
#define v_u 1u
#define v_ll 1ll
#define v_l 1l
#define v_f 1.0f
#define v_lf 1.0l
#define v_qf 1.0q
#define v_c 'A'
#define v_cfa '\xfa'
#define v_c7f '\x7f'
#define v_c80 '\x80'
#define v_cff '\xff'
#define v_cs "hello\nworld"
#define v_inf 1.0f/0.0f
#define v_ninf -1.0/0.0
]], [[
global v_ull: culonglong <comptime> = 1
global v_llu: culonglong <comptime> = 1
global v_ul: culong <comptime> = 1
global v_lu: culong <comptime> = 1
global v_u: cuint <comptime> = 1
global v_ll: clonglong <comptime> = 1
global v_l: clong <comptime> = 1
global v_f: float32 <comptime> = 1.0
global v_lf: clongdouble <cimport,nodecl,const>
global v_qf: float128 <cimport,nodecl,const>
global v_c: cchar <comptime> = 65
global v_cfa: cchar <comptime> = -6
global v_c7f: cchar <comptime> = 127
global v_c80: cchar <comptime> = -128
global v_cff: cchar <comptime> = -1
global v_cs: cstring <comptime> = "hello\nworld"
global v_inf: float32 <cimport,nodecl,const>
global v_ninf: float64 <cimport,nodecl,const>
]])
  expect_bindings([[
#define v_ll7f 0x7fffffffffffffffLL
#define v_ll80 0x8000000000000000LL
#define v_ull7f 0x7fffffffffffffffULL
#define v_ullff 0xffffffffffffffffULL
#define v_7f 0x7fffffffffffffff
#define v_ff 0xffffffffffffffff
#define v_huge 1e5000
#define v_huge2 (1e300* 1e300)
]], [[
global v_ll7f: clonglong <comptime> = 9223372036854775807
global v_ll80: clonglong <cimport,nodecl,const>
global v_ull7f: culonglong <comptime> = 9223372036854775807
global v_ullff: culonglong <cimport,nodecl,const>
global v_7f: clonglong <comptime> = 9223372036854775807
global v_ff: culonglong <cimport,nodecl,const>
global v_huge: float64 <cimport,nodecl,const>
global v_huge2: float64 <cimport,nodecl,const>
]])
  expect_bindings([[
#define v_i ((int)(-1 + 2))
#define v_if ((int)(0xffffffff))
#define v_ni ~1
#define v_80 0x80000000
#define v_subu 0U - 10U
]], [[
global v_i: cint <comptime> = 1
global v_if: cint <cimport,nodecl,const>
global v_ni: cint <cimport,nodecl,const>
global v_80: cuint <comptime> = 2147483648
global v_subu: cuint <cimport,nodecl,const>
]])
  expect_bindings([[
#define A 1
#undef A
]], [[]])
  expect_bindings([[
#define A 1
#define A 2
]], [[
global A: cint <comptime> = 2
]])
end)

it("define aliases", function()
  expect_bindings([[
void f();
int a;
typedef struct S{} S;
#define F f
#define A a
#define SS1 struct S
#define SS2 S
]], [[
global S: type <cimport,nodecl> = @record{}
global function f(): void <cimport,nodecl> end
global a: cint <cimport,nodecl>
global function F(): void <cimport,nodecl> end
global A: cint <cimport,nodecl>
global SS1: type = S
global SS2: type = S
]])
end)

it("define references", function()
  expect_bindings([[
int* __errno_location();
#define errno (*__errno_location ())
]], [[
global errno: cint <cimport,nodecl>
]])
  expect_bindings([[
int a;
#define pa (&a)
#define p ((void*)&a)
]], [[
global a: cint <cimport,nodecl>
global pa: *cint <cimport,nodecl,const>
global p: pointer <cimport,nodecl,const>
]])
end)

it("exclude defines", function()
  expect_bindings([[
#define HAVE_SOMETHING 1
#define SOMETHING_H 1
#define and int
]], [[]])
end)

it("parse errors", function()
  expect.fail(function()
    nldecl.generate_bindings_from_c_code([[struct S{}]])
  end, 'syntax error')
  expect.fail(function()
    nldecl.generate_bindings_from_c_code([[int x; typeof(x) y;]])
  end, 'unhandled typeof')
  expect.fail(function()
    nldecl.generate_bindings_from_c_code([[int add(x, y) int x; int y; {return x + y;}]])
  end, 'not supported yet')
end)

it("high level API", function()
  nldecl.generate_bindings_file{
    output_file = 'sdl2.nelua',
    parse_includes = {
      '<stddef.h>',
      '<stdbool.h>',
      '<stdint.h>',
      '<assert.h>',
      '<ctype.h>',
      '<errno.h>',
      '<fenv.h>',
      '<float.h>',
      '<inttypes.h>',
      '<limits.h>',
      '<locale.h>',
      '<math.h>',
      '<setjmp.h>',
      '<signal.h>',
      '<stdalign.h>',
      '<stdarg.h>',
      '<stdio.h>',
      '<stdlib.h>',
      '<stdnoreturn.h>',
      '<string.h>',
      '<time.h>',
      '<uchar.h>',
      '<wchar.h>',
      '<wctype.h>',
  },
    parse_defines = {'_GNU_SOURCE'},
    cc = 'gcc',
    opaque_names = {
      FILE=true,
    },
    output_head = [====[
## cinclude '<stdio.h>'
]====]
  }
end)

it("big C file", function()
  local fs = require 'nelua.utils.fs'
  local ppflags = '-E -dD' -- -dD --C
  -- os.execute("gcc      "..ppflags.." libs/blend2d/blend2d.c > t.h")
  -- os.execute("gcc  `pkg-config --cflags libadwaita-1`   "..ppflags.." t2.c > t.h")
  -- os.execute("gcc     -DCAPI -DPOSIX -DGLIBC -DLIBS "..ppflags.." t.c > t.h")
  -- os.execute("clang    -DCAPI -DPOSIX -DGLIBC -DLIBS "..ppflags.." t.c > t.h")
  -- os.execute("tcc      -DCAPI -DPOSIX -DGLIBC -DLIBS "..ppflags.." t.c > t.h")
  -- os.execute("musl-gcc -DCAPI -DMUSLC -I/usr/lib/zig/libc/include/any-linux-any "..ppflags.." t.c > t.h")
  -- os.execute("c2m      -DCAPI -DPOSIX -DGLIBC -DLIBS -E t.c > t.h")
  -- os.execute("emcc -DCAPI "..ppflags.." t.c > t.h")
  os.execute("x86_64-w64-mingw32-gcc -DCAPI -DWINDOWS "..ppflags.." t.c > t.h")
  local c_source = fs.readfile('t.h')
  local nelua_source = nldecl.generate_bindings_from_c_code(c_source)
--   nelua_source = [===[
-- ## cinclude 't.c'
-- ## cflags '-DCAPI -DPOSIX -DGLIBC `pkg-config --cflags --libs libadwaita-1`'
-- ]===]..nelua_source
  fs.writefile('t.nelua', nelua_source)
  os.execute('nelua -tV t.nelua')
end)

--[[
cbindings {

}
]]

end)
