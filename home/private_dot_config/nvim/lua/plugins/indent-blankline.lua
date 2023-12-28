---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  ---@type ibl.config
  opts = {
    indent = {
      char = core.icons.ui.LineLeft,
      tab_char = core.icons.ui.LineLeft,
    },
  },
}
