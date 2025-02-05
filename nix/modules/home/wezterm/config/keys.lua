-- ╭─────────────────────────────────────────────────────────╮
-- │ KEYBINDINGS                                             │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable: assign-type-mismatch
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

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
end

return M
