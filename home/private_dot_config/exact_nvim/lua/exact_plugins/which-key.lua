---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  keys = core.lazy_map({
    n = {
      [{ "<leader>\"", "<leader>'", "<leader>`" }] = { false },
      [{ "<leader>", "<C-r>", "<C-w>", "\"", "'", "`", "c", "v", "g" }] = {},
    },
  }),
  opts = {
    plugins = {
      spelling = true,
    },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["gs"] = { name = "+surround" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader><tab>"] = { name = "+tabs" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>f"] = { name = "+file/find" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>gh"] = { name = "+hunks" },
      ["<leader>q"] = { name = "+quit/session" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>u"] = { name = "+ui" },
      ["<leader>w"] = { name = "+windows" },
      ["<leader>x"] = { name = "+diagnostics/quickfix" },
    },
    icons = {
      breadcrumb = core.icons.ui.DoubleChevronRight,
      separator = core.icons.ui.BoldArrowRight,
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
