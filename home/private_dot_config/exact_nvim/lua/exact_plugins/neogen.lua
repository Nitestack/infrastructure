---@type LazySpec
return {
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
          "Annotation: Function",
        },
        ["F"] = {
          function()
            require("neogen").generate({ type = "file" })
          end,
          "Annotation: File",
        },
        ["c"] = {
          function()
            require("neogen").generate({ type = "class" })
          end,
          "Annotation: Class",
        },
        ["t"] = {
          function()
            require("neogen").generate({ type = "type" })
          end,
          "Annotation: Type",
        },
      },
    }, {
      prefix = "<leader>a",
    }),
    opts = {
      snippet_engine = "luasnip",
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>a"] = { name = "+annotations" },
      },
    },
  },
}
