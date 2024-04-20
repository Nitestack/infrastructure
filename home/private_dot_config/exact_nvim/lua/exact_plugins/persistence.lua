---@type LazyPluginSpec
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    options = vim.opt.sessionoptions:get(),
  },
  keys = core.lazy_map({
    n = {
      ["s"] = {
        function()
          require("persistence").load()
        end,
        desc = "Session: Restore",
      },
      ["l"] = {
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Session: Restore Last",
      },
      ["d"] = {
        function()
          require("persistence").stop()
        end,
        desc = "Session: Don't save current",
      },
    },
  }, {
    prefix = "<leader>q",
  }),
}
