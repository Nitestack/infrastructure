local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

local mod = {}

if utils.is_mac() then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
elseif utils.is_win() then
  mod.SUPER = "ALT" -- to not conflict with Windows key shortcuts
  mod.SUPER_REV = "ALT|CTRL"
end

local keys = {
  { key = "c", mods = "CTRL", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },

  -- Tab
  { key = "T", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
  { key = "1", mods = "SHIFT|CTRL", action = act.SpawnTab("DefaultDomain") },
  { key = "2", mods = "SHIFT|CTRL", action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }) },
  { key = "W", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "RightArrow", mods = mod.SUPER_REV, action = act.ActivateTabRelative(1) },
  { key = "LeftArrow", mods = mod.SUPER_REV, action = act.ActivateTabRelative(-1) },

  {
    key = "P",
    mods = "CTRL",
    action = wezterm.action.ActivateCommandPalette,
  },
}

for i = 1, 9, 1 do
  table.insert(keys, { key = tostring(i), mods = mod.SUPER_REV, action = act.ActivateTab(i - 1) })
end

return {
  leader = { key = "a", mods = "CTRL" },
  keys = keys,
  disable_default_key_bindings = true,
}
