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
        "Session: Restore",
      },
      ["<leader>ql"] = {
        function()
          require("persistence").load({ last = true })
        end,
        "Session: Restore Last",
      },
      ["<leader>qd"] = {
        function()
          require("persistence").stop()
        end,
        "Session: Don't save current",
      },
    },
  }),
}
