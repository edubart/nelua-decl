local gccutils = {}

local function chain_next(node, itnode)
  if itnode == nil then
    return node
  end
  return itnode:chain()
end

function gccutils.chain(node)
  return chain_next, node, nil
end

function gccutils.get_id(node)
  if not node then return nil end
  if node:code() == 'identifier_node' then
    return node:value()
  else
    return gccutils.get_id(node:name())
  end
end

function gccutils.get_inner_id(node)
  if not node then return nil end
  if node:code() == 'identifier_node' then
    return node:value()
  else
    local subnode = node:name()
    if not subnode and node.type then
      subnode = node:type()
    end
    return gccutils.get_inner_id(subnode)
  end
end

function gccutils.has_cvarargs(functype)
  local arg = functype:args()
  if not arg then
    return false
  end
  while true do
    if not arg then
      return true
    elseif arg:value():code() == 'void_type' then
      return false
    end
    arg = arg:chain()
  end
end

local ctype2nltype = {
  ['char'] = 'cchar',
  ['signed char'] = 'cschar',
  ['short int'] = 'cshort',
  ['int'] = 'cint',
  ['long int'] = 'clong',
  ['long long int'] = 'clonglong',
  ['ptrdiff_t'] = 'cptrdiff',
  ['unsigned char'] = 'cuchar',
  ['short unsigned int'] = 'cushort',
  ['unsigned int'] = 'cuint',
  ['long unsigned int'] = 'culong',
  ['long long unsigned int'] = 'culonglong',
  ['size_t'] = 'csize',
  ['long double'] = 'clongdouble',
  ['intptr_t'] = 'isize',
  ['int8_t'] = 'int8',
  ['int16_t'] = 'int16',
  ['int32_t'] = 'int32',
  ['int64_t'] = 'int64',
  ['__int128'] = 'int128',
  ['uintptr_t'] = 'usize',
  ['uint8_t'] = 'uint8',
  ['uint16_t'] = 'uint16',
  ['uint32_t'] = 'uint32',
  ['uint64_t'] = 'uint64',
  -- ['unsigned __int128'] = 'uint128',
  ['__int128 unsigned'] = 'uint128',
  ['float'] = 'float32',
  ['double'] = 'float64',
  ['_Float128'] = 'float128',
  ['bool'] = 'boolean',
  ['void'] = 'void',
}

function gccutils.node_ctype2nltype(node)
  if not node then return end
  local ctype = gccutils.get_id(node)
  local nltype = ctype2nltype[ctype]
  if not nltype then -- try with canonical name
    local canonctype = gccutils.get_id(node:canonical())
    nltype = ctype2nltype[canonctype]

    -- try to detect fixed types using the name
    if nltype and node:code() == 'integer_type' and nltype:match('^c') then
      ctype = ctype:lower()
      if nltype:match('^cu') then
        if ctype:match('int64') then nltype = 'uint64'
        elseif ctype:match('int32') then nltype = 'uint32'
        elseif ctype:match('int16') then nltype = 'uint16'
        elseif ctype:match('int8') then nltype = 'uint8'
        elseif ctype:match('intptr') then nltype = 'usize'
        end
      else
        if ctype:match('int64') then nltype = 'int64'
        elseif ctype:match('int32') then nltype = 'int32'
        elseif ctype:match('int16') then nltype = 'int16'
        elseif ctype:match('int8') then nltype = 'int8'
        elseif ctype:match('intptr') then nltype = 'isize'
        end
      end
    end
  end
  return nltype
end

function gccutils.get_enum_nltype(node)
  local negative
  local large
  for fieldnode in gccutils.chain(node:values()) do
    local fieldvalue = fieldnode:value():value()
    if fieldvalue >= (1<<32)//2 then
      large = true
    elseif fieldvalue < 0 then
      negative = true
    end
  end
  if not negative and large then
    return 'cuint'
  else
    return 'cint'
  end
end

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
}

function gccutils.normalize_name(name)
  if reserved_names[name] then
    return name:sub(1,1):upper()..name:sub(2)
  end
  return name
end

return gccutils
