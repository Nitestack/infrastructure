---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  event = function()
    return {}
  end,
  keys = core.lazy_map({
    n = {
      [{ "<leader>\"", "<leader>'", "<leader>`" }] = { false },
      [{ "<leader>", "<C-r>", "<C-w>", "\"", "'", "`", "c", "v", "g" }] = {},
    },
  }),
  opts = {
    icons = {
      breadcrumb = core.icons.ui.DoubleChevronRight,
      separator = core.icons.ui.BoldArrowRight,
    },
    window = {
      border = core.config.ui.transparent.floats and "rounded" or "none",
    },
  },
}
