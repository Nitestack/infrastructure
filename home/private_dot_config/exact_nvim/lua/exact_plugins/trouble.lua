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
      ["<leader>xx"] = {
        function()
          require("trouble").toggle({ mode = "diagnostics" })
        end,
        "Trouble: Workspace Diagnostics",
      },
      ["<leader>xX"] = {
        function()
          require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
        end,
        "Trouble: Buffer Diagnostics",
      },
      ["<leader>xL"] = {
        function()
          require("trouble").toggle({ mode = "loclist" })
        end,
        "Trouble: Location List",
      },
      ["<leader>xQ"] = {
        function()
          require("trouble").toggle({ mode = "quickfix" })
        end,
        "Trouble: Quickfix List",
      },
    },
  }),
}
