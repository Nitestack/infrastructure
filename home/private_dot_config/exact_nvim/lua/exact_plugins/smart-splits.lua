---@type LazyPluginSpec
return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  keys = core.lazy_map({
    n = {
      ["<C-h>"] = {
        function()
          require("smart-splits").move_cursor_left()
        end,
      },
      ["<C-l>"] = {
        function()
          require("smart-splits").move_cursor_right()
        end,
      },
      ["<C-k>"] = {
        function()
          require("smart-splits").move_cursor_up()
        end,
      },
      ["<C-j>"] = {
        function()
          require("smart-splits").move_cursor_down()
        end,
      },
      ["<C-Up>"] = {
        function()
          require("smart-splits").resize_up()
        end,
      },
      ["<C-Down>"] = {
        function()
          require("smart-splits").resize_down()
        end,
      },
      ["<C-Left>"] = {
        function()
          require("smart-splits").resize_left()
        end,
      },
      ["<C-Right>"] = {
        function()
          require("smart-splits").resize_right()
        end,
      },
    },
  }),
  ---@type SmartSplitsConfig
  opts = {},
}
