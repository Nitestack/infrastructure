-- ╭─────────────────────────────────────────────────────────╮
-- │ Disabled Plugins                                        │
-- ╰─────────────────────────────────────────────────────────╯

return vim.tbl_map(function(plugin_name)
  ---@type LazyPluginSpec
  return {
    plugin_name,
    enabled = false,
  }
end, {
  "akinsho/bufferline.nvim",
  "folke/tokyonight.nvim",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "jay-babu/mason-nvim-dap.nvim",
})
