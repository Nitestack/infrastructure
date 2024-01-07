local Config = require("config")

return Config:init()
  :append_module("general")
  :append_module("appearance")
  :append_platform()
  .options
