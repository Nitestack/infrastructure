return utils.plugin.with_extensions({
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = { enable_autocmd = false },
    },
    keys = core.lazy_map({
      n = {
        ["gcc"] = {
          desc = "Comment: Toggle line",
        },
        ["gbc"] = {
          desc = "Comment: Toggle block",
        },
        ["gcO"] = {
          desc = "Comment: Insert line above",
        },
        ["gco"] = {
          desc = "Comment: Insert line below",
        },
        ["gcA"] = {
          desc = "Comment: Insert line end",
        },
      },
      [{ "n", "x" }] = {
        ["gc"] = {
          desc = "Comment: Toggle line",
        },
        ["gb"] = {
          desc = "Comment: Toggle block",
        },
      },
    }),
    opts = function()
      ---@type CommentConfig
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
}, {
  which_key = {
    ["gc"] = "Comment line",
    ["gb"] = "Comment block",
  },
})
