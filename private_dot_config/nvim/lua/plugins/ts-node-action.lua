---@type LazyPluginSpec
return {
  "ckolkey/ts-node-action",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  keys = core.lazy_map({
    n = {
      ["J"] = {
        function()
          require("ts-node-action").node_action()
        end,
        "Trigger Node action",
      },
    },
  }),
  opts = {},
}
