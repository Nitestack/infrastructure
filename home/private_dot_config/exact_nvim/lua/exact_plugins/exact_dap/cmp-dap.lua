---@type LazyPluginSpec
return {
  "rcarriga/cmp-dap",
  dependencies = "hrsh7th/nvim-cmp",
  config = function()
    require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
      sources = {
        { name = "dap" },
      },
    })
  end,
}
