---@type LazyPluginSpec
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    options = vim.opt.sessionoptions:get(),
  },
  keys = core.lazy_map({
    n = {
      ["<leader>qs"] = {
        function()
          require("persistence").load()
        end,
        "Restore Session",
      },
      ["<leader>ql"] = {
        function()
          require("persistence").load({ last = true })
        end,
        "Restore Last Session",
      },
      ["<leader>qd"] = {
        function()
          require("persistence").stop()
        end,
        "Don't Save Current Session",
      },
    },
  }),
}
