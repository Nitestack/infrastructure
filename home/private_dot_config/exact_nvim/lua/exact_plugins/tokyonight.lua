---@type LazyPluginSpec
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  enabled = function()
    return core.config.ui.theme == "tokyonight"
  end,
  ---@type Config
  opts = {
    style = "storm",
    transparent = core.config.ui.transparent.enabled,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "dark",
      floats = core.config.ui.transparent.floats and "transparent" or "normal",
    },
    lualine_bold = true,
    on_highlights = function(hl, c)
      hl.MiniIndentscopeSymbol = {
        fg = "#737AA2",
      }
      hl.CursorLineNr = {
        fg = c.orange,
      }
    end,
  },
  config = function(_, opts)
    require("tokyonight").load(opts)
  end,
}
