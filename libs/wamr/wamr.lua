local nldecl = require 'nldecl'

nldecl.include_names = {
  mem_alloc_type_t = true,
  MemAllocOption = true,
  RuntimeInitArgs = true,
  NativeSymbol = true,
  '^WASM',
  '^wasm',
}

nldecl.prepend_code = [=[
##[[
if not os.getenv('WAMR_SDK_PATH') then
  static_error 'Please define WAMR_SDK_PATH path'
end
cincdir(os.getenv('WAMR_SDK_PATH')..'/runtime-sdk/include')
linkdir(os.getenv('WAMR_SDK_PATH')..'/runtime-sdk/lib')
cinclude 'wasm_c_api.h'
cinclude 'wasm_export.h'
linklib 'vmlib'
if ccinfo.is_linux then
  cflags '-pthread'
end
]]
]=]
