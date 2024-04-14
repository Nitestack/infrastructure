---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "LiadOz/nvim-dap-repl-highlights",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },
  opts = function(_, opts)
    opts.ensure_installed = vim.list_extend(opts.ensure_installed, { "dap_repl" })
  end,
}
