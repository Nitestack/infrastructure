---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  keys = core.lazy_map({
    n = {
      [{ "<leader>", "<C-r>", "<C-w>", "\"", "'", "`", "c", "v", "g" }] = {},
    },
  }),
  ---@type Options
  opts = {
    plugins = {
      spelling = true,
    },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "Goto" },
      ["z"] = { name = "Fold" },
      ["]"] = { name = "Next" },
      ["["] = { name = "Previous" },
      ["<leader>c"] = { name = "Code" },
      ["<leader>f"] = { name = "File/Find" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>q"] = { name = "Quit/Session" },
      ["<leader>s"] = { name = "Search" },
      ["<leader>u"] = { name = "UI" },
      ["<leader>w"] = { name = "Windows" },
      ["<leader>x"] = { name = "Diagnostics/Quickfix/Location" },
    },
    icons = {
      breadcrumb = core.icons.ui.DoubleChevronRight,
      separator = "-",
      group = "",
    },
    window = {
      border = core.config.ui.transparent.floats and "rounded" or "none",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
