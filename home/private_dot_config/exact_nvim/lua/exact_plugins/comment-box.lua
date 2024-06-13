---@diagnostic disable: missing-parameter
---@type LazyPluginSpec
return {
  "Nitestack/comment-box.nvim",
  dependencies = "folke/ts-comments.nvim",
  keys = core.lazy_map({
    [{ "n", "v" }] = {
      [""] = "Headers",
      ["b"] = {
        function()
          require("comment-box").llbox()
        end,
        desc = "Box Title",
      },
      ["t"] = {
        function()
          require("comment-box").llline()
        end,
        desc = "Titled Line",
      },
      ["d"] = {
        function()
          require("comment-box").dbox()
        end,
        desc = "Remove a box",
      },
    },
    n = {
      ["l"] = {
        function()
          require("comment-box").line()
        end,
        desc = "Simple Line",
      },
    },
  }, {
    prefix = "<leader>h",
  }),
  opts = {},
}
