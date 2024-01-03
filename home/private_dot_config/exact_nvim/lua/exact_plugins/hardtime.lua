---@type LazyPluginSpec
return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  event = "LazyFile",
  opts = {
    max_count = 10,
    restricted_keys = {
      ["h"] = { "n" },
      ["j"] = { "n" },
      ["k"] = { "n" },
      ["l"] = { "n" },
    },
    disabled_keys = {
      ["<Up>"] = { "n", "i" },
      ["<Down>"] = { "n", "i" },
      ["<Left>"] = { "n", "i" },
      ["<Right>"] = { "n", "i" },
    },
    disable_mouse = vim.opt.mouse:get() == "",
  },
}
