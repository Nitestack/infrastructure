return utils.plugin.with_extensions({
  {
    "danymat/neogen",
    dependencies = "L3MON4D3/LuaSnip",
    cmd = "Neogen",
    keys = core.lazy_map({
      n = {
        ["f"] = {
          function()
            require("neogen").generate({ type = "func" })
          end,
          desc = "Function",
        },
        ["F"] = {
          function()
            require("neogen").generate({ type = "file" })
          end,
          desc = "File",
        },
        ["c"] = {
          function()
            require("neogen").generate({ type = "class" })
          end,
          desc = "Class",
        },
        ["t"] = {
          function()
            require("neogen").generate({ type = "type" })
          end,
          desc = "Type",
        },
      },
    }, {
      prefix = "<leader>a",
    }),
    opts = {
      snippet_engine = "luasnip",
    },
  },
}, {
  which_key = {
    { "<leader>a", group = "Annotations" },
  },
})
