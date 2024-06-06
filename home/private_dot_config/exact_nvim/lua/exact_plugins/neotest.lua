---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.test.core" },
  {
    "nvim-neotest/neotest",
    keys = core.lazy_map({
      n = {
        ["<leader>t"] = "Test",
      },
    }),
  },
}
