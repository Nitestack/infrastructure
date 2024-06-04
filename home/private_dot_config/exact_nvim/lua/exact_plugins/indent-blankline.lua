---@module "lazy"
---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "indent_blankline"
  ---@type ibl.config.full
  opts = {
    indent = {
      char = core.icons.ui.LineLeft,
      tab_char = core.icons.ui.LineLeft,
    },
  },
}
