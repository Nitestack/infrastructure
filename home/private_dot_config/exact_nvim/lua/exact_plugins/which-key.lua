---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  keys = core.lazy_map({
    n = {
      [{ "<leader>\"", "<leader>'", "<leader>`" }] = { false },
    },
  }),
  opts = {
    icons = {
      breadcrumb = core.icons.ui.DoubleChevronRight,
      separator = core.icons.ui.BoldArrowRight,
    },
  },
}
