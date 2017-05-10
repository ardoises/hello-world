#! /usr/bin/env lua

local Setenv = require "posix.stdlib".setenv
for line in io.lines ".environment" do
  local key, value = line:match "^([%w_]+)=(.*)$"
  if key and value then
    Setenv (key, value)
  end
end

local oldprint = print
_G.print = function (...)
  oldprint (...)
  io.stdout:flush ()
end

local Arguments = require "argparse"
local Client    = require "ardoises.client"
local Copas     = require "copas"
local Lustache  = require "lustache"
local Patterns  = require "ardoises.patterns"
local Url       = require "net.url"

local parser = Arguments () {
  name        = "ardoises-helloworld",
  description = "Hello World tool for Ardoises",
}
parser:option "--server" {
  description = "server URL",
  default     = "https://ardoises.ovh:8443",
  convert     = function (x)
    local url = Url.parse (x)
    assert (url.scheme and url.host)
    return url
  end,
}
parser:option "--layer" {
  description = "ardoise (as layer@owner/repository:branch)",
  default     = os.getenv "ARDOISES_LAYER",
  convert     = function (x)
    assert (Patterns.require:match (x), "layer must be in the 'layer@owner/repository:branch' format")
    return x
  end,
}
parser:option "--token" {
  description = "token",
  default     = os.getenv "ARDOISES_TOKEN",
}
local arguments = parser:parse ()

Copas.addthread (function ()
  local client = Client {
    server = Url.build (arguments.server),
    token  = arguments.token,
  }
  print ("Client", client)
  local ardoise = client.ardoises [arguments.layer]
  print ("Ardoise", ardoise)
  if not ardoise then
    error ("Ardoise " .. arguments.layer .. " does not exist or is not readable.")
  end
  local editor = ardoise:edit ()
  print ("Editor", editor)
  if not editor:require (arguments.layer) then
    print (Lustache:render ("Creation of layer {{{layer}}}...", {
      layer = arguments.layer,
    }))
    editor:create (arguments.layer)
  end
  print ("Patching...")
  assert (editor:patch {
    [arguments.layer] = [=[
      return function (Layer, layer, ref)
        local helloworld = Layer.require "formalism@saucisson/ardoises-helloworld:master"
        if not layer [Layer.key.refines] then
          layer [Layer.key.refines] = {}
        end
        local refines = layer [Layer.key.refines]
        refines [#refines+1] = helloworld
      end
    ]=],
  })
  editor:close ()
end)
Copas.loop ()
