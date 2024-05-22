return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.editor.refactoring" },
  {
    "ThePrimeagen/refactoring.nvim",
    event = function()
      return {}
    end,
    ---@type ConfigOpts
    opts = {},
  },
}, {
  which_key = {
    ["<leader>r"] = "Refactoring",
  },
})
