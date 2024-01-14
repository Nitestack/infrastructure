local Config = require("config")

return Config:init()
  :append_module("general")
  :append_module("appearance")
  :append_module("keys")
  :append_platform().options
