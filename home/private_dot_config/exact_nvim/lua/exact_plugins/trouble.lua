---@type LazyPluginSpec
return {
  "folke/trouble.nvim",
  branch = "dev",
  cmd = { "TroubleToggle", "Trouble" },
  ---@type trouble.Config
  opts = {
    auto_close = true,
    focus = true,
  },
  keys = core.lazy_map({
    n = {
      ["x"] = {
        function()
          require("trouble").toggle({ mode = "diagnostics" })
        end,
        desc = "Trouble: Workspace Diagnostics",
      },
      ["X"] = {
        function()
          require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
        end,
        desc = "Trouble: Buffer Diagnostics",
      },
      ["L"] = {
        function()
          require("trouble").toggle({ mode = "loclist" })
        end,
        desc = "Trouble: Location List",
      },
      ["Q"] = {
        function()
          require("trouble").toggle({ mode = "quickfix" })
        end,
        desc = "Trouble: Quickfix List",
      },
    },
  }, {
    prefix = "<leader>x",
  }),
}
