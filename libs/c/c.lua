local nldecl = require 'nldecl'

nldecl.exclude_names = {
  -- '^_'
}

nldecl.prepend_code = [=[
##[[
cinclude '<assert.h>'
cinclude '<complex.h>'
cinclude '<ctype.h>'
cinclude '<errno.h>'
cinclude '<fenv.h>'
cinclude '<float.h>'
cinclude '<inttypes.h>'
cinclude '<iso646.h>'
cinclude '<limits.h>'
cinclude '<locale.h>'
cinclude '<math.h>'
cinclude '<setjmp.h>'
cinclude '<signal.h>'
cinclude '<stdalign.h>'
cinclude '<stdarg.h>'
cinclude '<stdatomic.h>'
cinclude '<stdbool.h>'
cinclude '<stddef.h>'
cinclude '<stdint.h>'
cinclude '<stdio.h>'
cinclude '<stdlib.h>'
cinclude '<stdnoreturn.h>'
cinclude '<string.h>'
cinclude '<tgmath.h>'
cinclude '<threads.h>'
cinclude '<time.h>'
cinclude '<uchar.h>'
cinclude '<wchar.h>'
cinclude '<wctype.h>'
]]
local va_list <cimport, nodecl> = @record{}
]=]
