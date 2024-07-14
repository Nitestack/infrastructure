return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.editor.refactoring" },
}, {
  which_key = {
    { "<leader>r", group = "Refactoring", mode = { "n", "v" } },
  },
})
