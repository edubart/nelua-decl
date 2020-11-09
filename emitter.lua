local Emitter = {}
Emitter.__index = Emitter

function Emitter.create()
  return setmetatable({depth=0}, Emitter)
end

function Emitter:add(s)
  table.insert(self, s)
end

function Emitter:add_ln(s)
  if s then
    table.insert(self, s)
  end
  table.insert(self, '\n')
end

function Emitter:generate()
  return table.concat(self)
end

function Emitter:add_indent(s)
  table.insert(self, string.rep('  ', self.depth))
  if s then
    table.insert(self, s)
  end
end

function Emitter:inc_indent()
  self.depth = self.depth + 1
end

function Emitter:dec_indent()
  self.depth = self.depth - 1
end

setmetatable(Emitter, {__call = function(_, ...) return Emitter.create(...) end})

return Emitter
