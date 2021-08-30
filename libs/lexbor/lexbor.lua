local nldecl = require 'nldecl'

nldecl.include_names = {
  '^lexbor',
  '^lxb',
  FILE = true,
}

nldecl.prepend_code = [=[
##[[
cinclude '<lexbor/core/core.h>'
cinclude '<lexbor/html/html.h>'
cinclude '<lexbor/dom/dom.h>'
cinclude '<lexbor/css/css.h>'
cinclude '<lexbor/encoding/encoding.h>'
cinclude '<lexbor/selectors/selectors.h>'
cinclude '<lexbor/tag/tag.h>'
cinclude '<lexbor/ns/ns.h>'
cinclude '<lexbor/utils/utils.h>'
linklib 'lexbor'
]]
]=]
