---@type LazyPluginSpec
return {
  "danymat/neogen",
  keys = core.lazy_map({
    n = {
      ["<leader>cd"] = {
        function()
          require("neogen").generate({})
        end,
        "Docs: Generate annotations",
      },
    },
  }),
  opts = {
    snippet_engine = "luasnip",
  },
}
