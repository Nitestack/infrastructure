-- ╭─────────────────────────────────────────────────────────╮
-- │ Appearance Config                                       │
-- ╰─────────────────────────────────────────────────────────╯

---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")

local M = {}

---@param config Config
function M.setup(config)
  -- ── Font ────────────────────────────────────────────────────────────
  config.font = wezterm.font_with_fallback({
    "CommitMono Nerd Font",
    "Iosevka Nerd Font",
    "Symbols Nerd Font",
    "Noto Color Emoji",
  })
  config.font_size = 14
  config.command_palette_font_size = 14
  config.line_height = 1.5
  config.font_rules = {
    {
      italic = true,
      font = wezterm.font({
        family = "VictorMono NF",
        style = "Italic",
        weight = "DemiBold",
      }),
    },
  }

  -- ── Colors ──────────────────────────────────────────────────────────
  local colors = {
    base = "#1E1E2E",
    surface0 = "#313244",
    crust = "#11111b",
    text = "#cdd6f4",
  }

  config.color_scheme = "Catppuccin Mocha"
  config.window_background_gradient = {
    colors = { colors.base, colors.surface0, colors.crust },
    orientation = "Vertical",
    interpolation = "Linear",
  }
  config.command_palette_bg_color = colors.surface0
  config.command_palette_fg_color = colors.text

  -- ── Rendering ───────────────────────────────────────────────────────
  config.animation_fps = 144
  config.max_fps = 144

  config.underline_thickness = 3
  config.cursor_thickness = 4
  config.underline_position = -6

  -- -- ── Window ──────────────────────────────────────────────────────────
  config.window_padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  }
  config.enable_scroll_bar = false
end

return M
