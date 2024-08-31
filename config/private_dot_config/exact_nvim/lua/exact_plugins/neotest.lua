return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.test.core" },
}, {
  catppuccin = {
    neotest = true,
  },
  which_key = {
    {
      "<leader>t",
      group = "Neotest",
    },
  },
})
