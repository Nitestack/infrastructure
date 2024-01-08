local wezterm = require("wezterm")

return {
  -- Colors
  color_scheme = "Catppuccin Mocha",

  -- Font
  font = wezterm.font_with_fallback({
    {
      family = "Geist Mono",
      weight = "Bold",
    },
    "Symbols Nerd Font",
  }),
  font_size = 18.0,

  animation_fps = 144,
  max_fps = 144,

  -- Cursor
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 700,

  -- Window
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  window_padding = {
    top = 0,
    bottom = 0,
    left = 4,
    right = 0,
  },

  -- Tab Bar
  show_tab_index_in_tab_bar = false,
  switch_to_last_active_tab_when_closing_tab = true,
  window_frame = {
    font = wezterm.font_with_fallback({
      {
        family = "Geist Mono",
        weight = "Black",
      },
      "Symbols Nerd Font",
    }),
    font_size = 14.0,
  },
}
