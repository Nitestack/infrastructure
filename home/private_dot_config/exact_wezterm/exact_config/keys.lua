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

local options = {
  disable_default_key_bindings = true,
}

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
    action = act.ActivateCommandPalette,
  },
  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, _, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
  { key = "F", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
}

for i = 1, 9, 1 do
  table.insert(keys, { key = tostring(i), mods = mod.SUPER_REV, action = act.ActivateTab(i - 1) })
end

if utils.is_win() then
  local tmux_bindings = {
    -- horizontal and vertical splits
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- windows
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

    { key = "l", mods = mod.SUPER_REV, action = act.ActivateTabRelative(1) },
    { key = "h", mods = mod.SUPER_REV, action = act.ActivateTabRelative(-1) },

    { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

    -- panes
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

    { key = "LeftArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 8 }) },
    { key = "DownArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 4 }) },
    { key = "UpArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 4 }) },
    { key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 8 }) },
  }

  for _, binding in ipairs(tmux_bindings) do
    table.insert(keys, binding)
  end

  -- Set leader key (tmux default is Ctrl + b)
  options.leader = { key = "a", mods = "CTRL" }
end

options.keys = keys

return options
