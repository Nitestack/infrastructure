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
        "Session: Restore",
      },
      ["l"] = {
        function()
          require("persistence").load({ last = true })
        end,
        "Session: Restore Last",
      },
      ["d"] = {
        function()
          require("persistence").stop()
        end,
        "Session: Don't save current",
      },
    },
  }, {
    prefix = "<leader>q",
  }),
}
