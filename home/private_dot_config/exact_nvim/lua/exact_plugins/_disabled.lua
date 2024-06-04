return vim.tbl_map(function(plugin_name)
  ---@module "lazy"
  ---@type LazyPluginSpec
  return {
    plugin_name,
    enabled = false,
  }
end, {
  "akinsho/bufferline.nvim",
  "folke/flash.nvim",
  "nvim-neo-tree/neo-tree.nvim",
  "folke/tokyonight.nvim",
  "roobert/tailwindcss-colorizer-cmp.nvim",
})
