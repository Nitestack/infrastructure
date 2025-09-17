return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.test.core" },
}, {
  catppuccin = {
    neotest = true,
  },
})
