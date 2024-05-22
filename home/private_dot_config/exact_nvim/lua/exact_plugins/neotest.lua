return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.test.core" },
}, {
  which_key = {
    ["<leader>t"] = "Test",
  },
})
