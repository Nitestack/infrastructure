return vim.tbl_map(function(plugin_name)
  ---@type LazyPluginSpec
  return {
    plugin_name,
    enabled = false,
  }
end, {
  "akinsho/bufferline.nvim",
  "folke/flash.nvim",
  "nvim-neo-tree/neo-tree.nvim",
})
