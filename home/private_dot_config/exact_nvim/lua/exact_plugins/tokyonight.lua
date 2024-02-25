---@type LazyPluginSpec
return {
  "folke/tokyonight.nvim",
  lazy = not core.config.ui.theme == "tokyonight",
  priority = 1000,
  enabled = function()
    return core.config.ui.theme == "tokyonight"
  end,
  ---@type Config
  opts = {
    style = "storm",
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "normal",
      floats = core.config.ui.transparent.floats and "transparent" or "dark",
    },
    lualine_bold = true,
    on_highlights = function(hl)
      hl.MiniIndentscopeSymbol = {
        fg = "#737AA2",
      }
    end,
  },
  config = function(_, opts)
    require("tokyonight").load(opts)
  end,
}
