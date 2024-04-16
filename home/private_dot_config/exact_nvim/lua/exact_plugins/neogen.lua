---@type LazyPluginSpec
return {
  "danymat/neogen",
  dependencies = { "L3MON4D3/LuaSnip" },
  keys = core.lazy_map({
    n = {
      ["f"] = {
        function()
          require("neogen").generate({ type = "func" })
        end,
        "Docs: Function annotation",
      },
      ["c"] = {
        function()
          require("neogen").generate({ type = "class" })
        end,
        "Docs: Class annotations",
      },
      ["t"] = {
        function()
          require("neogen").generate({ type = "type" })
        end,
        "Docs: Type annotations",
      },
    },
  }, {
    prefix = "<leader>cd",
  }),
  opts = {
    snippet_engine = "luasnip",
  },
}
