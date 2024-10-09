-- ╭─────────────────────────────────────────────────────────╮
-- │ KEYBINDINGS                                             │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable: assign-type-mismatch
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")
local mod = {}

if utils.is_win() then
  mod.SUPER = "ALT" -- to not conflict with Windows key shortcuts
  mod.SUPER_REV = "ALT|CTRL"
elseif utils.is_linux() then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "ALT|CTRL"
else
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
end

local M = {}

-- ── Tmux bindings ───────────────────────────────────────────────────
---@param config Config
local function add_tmux_bindings(config)
  ---@type Key[]
  local tmux_bindings = {
    -- horizontal and vertical splits
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- windows
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

    { key = ">", mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },
    { key = "<", mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },

    { key = "l", mods = mod.SUPER_REV, action = act.ActivateTabRelative(1) },
    { key = "h", mods = mod.SUPER_REV, action = act.ActivateTabRelative(-1) },

    -- panes
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

    { key = "LeftArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 8 }) },
    { key = "DownArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 4 }) },
    { key = "UpArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 4 }) },
    { key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 8 }) },
  }

  for _, binding in ipairs(tmux_bindings) do
    table.insert(config.keys, binding)
  end

  config.leader = { key = "a", mods = "CTRL" }
end

-- ── Regular bindings ────────────────────────────────────────────────
---@param config Config
function M.setup(config)
  config.disable_default_key_bindings = true

  config.keys = {
    { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    {
      key = "P",
      mods = "CTRL",
      action = act.ActivateCommandPalette,
    },
    { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
    { key = "F", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
  }

  -- Windows
  if utils.is_win() then
    local tab_keys = {
      { key = "T", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
      { key = "phys:1", mods = "SHIFT|CTRL", action = act.SpawnTab("DefaultDomain") },
      { key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
      { key = "RightArrow", mods = mod.SUPER_REV, action = act.ActivateTabRelative(1) },
      { key = "LeftArrow", mods = mod.SUPER_REV, action = act.ActivateTabRelative(-1) },
      {
        key = "R",
        mods = "CTRL|SHIFT",
        action = act.PromptInputLine({
          description = "Enter new name for tab",
          ---@diagnostic disable-next-line: param-type-mismatch, missing-parameter
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
    }
    for i = 1, 9, 1 do
      table.insert(config.keys, { key = tostring(i), mods = mod.SUPER_REV, action = act.ActivateTab(i - 1) })
    end
    for _, binding in ipairs(tab_keys) do
      table.insert(config.keys, binding)
    end

    add_tmux_bindings(config)
  end
end

return M
