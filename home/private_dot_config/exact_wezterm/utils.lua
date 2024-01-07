local wezterm = require("wezterm")

local function str_includes(str, pattern)
  return string.find(str, pattern) ~= nil
end

local M = {}

M.is_win = function()
  return str_includes(wezterm.target_triple, "windows")
end

M.is_linux = function()
  return str_includes(wezterm.target_triple, "linux")
end

M.is_mac = function()
  return str_includes(wezterm.target_triple, "apple")
end

return M
