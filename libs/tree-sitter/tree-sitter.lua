local nldecl = require 'nldecl'

nldecl.include_names = {
  '^TS',
  '^ts_',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cinclude 'tree_sitter/api.h'
cinclude 'tree_sitter/parser.h'
linklib 'tree-sitter'
]]
]=]
