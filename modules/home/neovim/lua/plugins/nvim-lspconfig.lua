---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  ---@param opts PluginLspOpts
  opts = function(_, opts)
    -- Modify LSP mappings
    opts.servers["*"].keys = vim.list_extend(opts.servers["*"].keys or {}, {
      { "<F2>", "<leader>cr", desc = "Rename", has = "rename", remap = true },
    })
  end,
}
