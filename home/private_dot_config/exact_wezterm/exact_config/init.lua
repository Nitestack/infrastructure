local wezterm = require("wezterm")
local utils = require("utils")

---@class Config
---@field options table
local Config = {}

function Config:init()
  self.__index = self
  local config = setmetatable({ options = wezterm.config_builder() }, self)
  return config
end

function Config:append_module(module)
  for k, v in pairs(require("config." .. module)) do
    if self.options[k] ~= nil then
      wezterm.log_warn("Duplicate config option detected: ", { old = self.options[k], new = module[k] })
    else
      self.options[k] = v
    end
  end
  return self
end

function Config:append_platform()
  if utils.is_win() then
    self:append_module("platforms.windows")
  end

  if utils.is_linux() then
    self:append_module("platforms.linux")
  end

  if utils.is_mac() then
    self:append_module("platforms.macos")
  end

  return self
end

return Config
