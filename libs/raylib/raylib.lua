local nldecl = require 'nldecl'

nldecl.include_names = {
  '^[A-Z]',
  '^r[A-Z]',
  float3 = true,
  float16 = true,
}

nldecl.exclude_names = {
  '^FP_', -- remove variables capture from math.h
}

nldecl.include_macros = {
  cint = {
    MAX_TOUCH_POINTS = true,
  },
  float32 = {
    PI = true,
    DEG2RAD = true,
    RAD2DEG = true,
  },
  Color = {
    LIGHTGRAY = true,
    GRAY = true,
    DARKGRAY = true,
    YELLOW = true,
    GOLD = true,
    ORANGE = true,
    PINK = true,
    RED = true,
    MAROON = true,
    GREEN = true,
    LIME = true,
    DARKGREEN = true,
    SKYBLUE = true,
    BLUE = true,
    DARKBLUE = true,
    PURPLE = true,
    VIOLET = true,
    DARKPURPL = true,
    BEIGE = true,
    BROWN = true,
    DARKBROWN = true,
    WHITE = true,
    BLACK = true,
    BLANK = true,
    MAGENTA = true,
    RAYWHITE = true,
  }
}

nldecl.prepend_code = [=[
##[[
cinclude '<raylib.h>'
cinclude '<raymath.h>'
linklib 'raylib'
]]
]=]

-- Allow math operations for vector, matrix and quaternion
nldecl.append_code = [=[
function Vector2.__add(v1: Vector2, v2: Vector2): Vector2 <cimport'Vector2Add', nodecl> end
function Vector2.__sub(v1: Vector2, v2: Vector2): Vector2 <cimport'Vector2Subtract', nodecl> end
function Vector2.__len(v: Vector2): float32 <cimport'Vector2Length', nodecl> end
function Vector2.__unm(v: Vector2): Vector2 <cimport'Vector2Negate', nodecl> end
function Vector2.__div(v: Vector2, divisor: overload(Vector2, number)): Vector2
  ## if divisor.type.nickname == 'Vector2' then
    return Vector2Divide(v, divisor)
  ## else
    return Vector2Divide(v, 1.0/divisor)
  ## end
end
function Vector2.__mul(v: Vector2, multiplier: overload(Vector2, number)): Vector2
  ## if multiplier.type.nickname == 'Vector2' then
    return Vector2Multiply(v, multiplier)
  ## else
    return Vector2Scale(v, multiplier)
  ## end
end
function Vector3.__add(v1: Vector3, v2: Vector3): Vector3 <cimport'Vector3Add', nodecl> end
function Vector3.__sub(v1: Vector3, v2: Vector3): Vector3 <cimport'Vector3Subtract', nodecl> end
function Vector3.__len(v: Vector3): float32 <cimport'Vector3Length', nodecl> end
function Vector3.__unm(v: Vector3): Vector3 <cimport'Vector3Negate', nodecl> end
function Vector3.__mul(v: Vector3, multiplier: overload(Vector3, number)): Vector3
  ## if multiplier.type.nickname == 'Vector3' then
    return Vector3Multiply(v, multiplier)
  ## else
    return Vector3Scale(v, multiplier)
  ## end
end
function Vector3.__div(v: Vector3, divisor: overload(Vector3, number)): Vector3
   ## if divisor.type.nickname == 'Vector3' then
    return Vector3Divide(v, divisor)
  ## else
    return Vector3Scale(v, 1.0/divisor)
  ## end
end
function Matrix.__add(left: Matrix, right: Matrix): Matrix <cimport'MatrixAdd', nodecl> end
function Matrix.__sub(left: Matrix, right: Matrix): Matrix <cimport'MatrixSubtract', nodecl> end
function Matrix.__mul(left: Matrix, right: Matrix): Matrix <cimport'MatrixMultiply', nodecl> end
function Quaternion.__len(q: Quaternion): float32 <cimport'QuaternionLength', nodecl> end
function Quaternion.__mul(q1: Quaternion, q2: Quaternion): Quaternion <cimport'QuaternionMultiply', nodecl> end
]=]
