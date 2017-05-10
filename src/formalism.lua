return function (Layer, layer --[[, ref]])
  local meta        = Layer.key.meta
  local interaction = Layer.require "interaction@ardoises/formalisms:dev"
  layer [meta]      = {
    [interaction.gui] = function (parameters)
      -- local editor     = assert (parameters.editor)
      -- local module     = assert (parameters.module)
      local target     = assert (parameters.target)
      local coroutine  = assert (parameters.coroutine)
      local backup     = target.innerHTML
      target.innerHTML = [[
        <iframe width="560" height="315" src="https://www.youtube.com/embed/zecueq-mo4M" frameborder="0" allowfullscreen></iframe>
      ]]
      coroutine.yield ()
      target.innerHTML  = backup
    end,
  }
end
