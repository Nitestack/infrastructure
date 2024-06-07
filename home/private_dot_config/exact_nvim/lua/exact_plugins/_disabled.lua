return vim.tbl_map(function(plugin_name)
  ---@type LazyPluginSpec
  return {
    plugin_name,
    enabled = false,
  }
end, {
  "akinsho/bufferline.nvim",
  "folke/flash.nvim",
  "folke/tokyonight.nvim",
  "roobert/tailwindcss-colorizer-cmp.nvim",
})
