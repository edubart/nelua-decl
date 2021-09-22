package.path = '../../?.lua;'..package.path
local nldecl = require 'nldecl'

nldecl.include_names = {
  '^mu_',
  '^MU_'
}

nldecl.prepend_code = [=[
##[[
cinclude 'microui.h'
if not MICROUI_NO_IMPL then
  cinclude 'microui.c'
end
]]
]=]

nldecl.append_code = [=[
global function mu_button(ctx: *mu_Context, label: cstring): cint
  return mu_button_ex(ctx, label, 0, MU_OPT_ALIGNCENTER)
end
global function mu_textbox(ctx: *mu_Context, buf: cstring, bufsz: cint): cint
  return mu_textbox_ex(ctx, buf, bufsz, 0)
end
global function mu_slider(ctx: *mu_Context, value: *float32, lo: float32, hi: float32): cint
  return mu_slider_ex(ctx, value, lo, hi, 0, "%.2f", MU_OPT_ALIGNCENTER)
end
global function mu_number(ctx: *mu_Context, value: *float32, step: float32): cint
  return mu_number_ex(ctx, value, step, "%.2f", MU_OPT_ALIGNCENTER)
end
global function mu_header(ctx: *mu_Context, label: cstring): cint
  return mu_header_ex(ctx, label, 0)
end
global function mu_begin_treenode(ctx: *mu_Context, label: cstring): cint
  return mu_begin_treenode_ex(ctx, label, 0)
end
global function mu_begin_window(ctx: *mu_Context, title: cstring, rect: mu_Rect): cint
  return mu_begin_window_ex(ctx, title, rect, 0)
end
global function mu_begin_panel(ctx: *mu_Context, name: cstring): void
  mu_begin_panel_ex(ctx, name, 0)
end
]=]
