---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = core.icons.ui.LineLeft,
      tab_char = core.icons.ui.LineLeft,
    },
  },
}
