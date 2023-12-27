---@type LazyPluginSpec
return {
  "folke/zen-mode.nvim",
  dependencies = {
    "folke/twilight.nvim",
  },
  keys = core.lazy_map({
    n = {
      ["<leader>z"] = {
        function()
          require("zen-mode").toggle()
        end,
        "Toggle Zen Mode",
      },
    },
  }),
  ---@type ZenOptions
  opts = {},
}
