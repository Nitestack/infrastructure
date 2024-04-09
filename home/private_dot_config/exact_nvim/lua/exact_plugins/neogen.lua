---@type LazyPluginSpec
return {
  "danymat/neogen",
  dependencies = { "L3MON4D3/LuaSnip" },
  keys = core.lazy_map({
    n = {
      ["<leader>cdf"] = {
        function()
          require("neogen").generate({ type = "func" })
        end,
        "Docs: Function annotation",
      },
      ["<leader>cdc"] = {
        function()
          require("neogen").generate({ type = "class" })
        end,
        "Docs: Class annotations",
      },
      ["<leader>cdt"] = {
        function()
          require("neogen").generate({ type = "type" })
        end,
        "Docs: Type annotations",
      },
    },
  }),
  opts = {
    snippet_engine = "luasnip",
  },
}
