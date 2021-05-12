echo "#include <$1.h>" > $1.c
cat > $1.lua <<EOF
local nldecl = require 'nldecl'

nldecl.exclude_names = {
  '^__',
}

nldecl.include_macros = {
  cint = {
  },
}

nldecl.prepend_code = [=[
## cinclude '<$1.h>'
]=]
EOF
