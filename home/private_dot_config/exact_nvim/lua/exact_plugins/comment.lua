---@type LazySpec
return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = { enable_autocmd = false },
      },
    },
    keys = {
      { "gcc", desc = "Comment: Toggle Line" },
      { "gbc", desc = "Comment: Toggle Block" },
      { "gc", mode = { "n", "x" } },
      { "gb", mode = { "n", "x" } },
      { "gcO", desc = "Comment: Insert line above" },
      { "gco", desc = "Comment: Insert line below" },
      { "gcA", desc = "Comment: Insert line end" },
    },
    opts = function()
      ---@type CommentConfig
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["gc"] = { name = "+comment line" },
        ["gb"] = { name = "+comment block" },
      },
    },
  },
}
