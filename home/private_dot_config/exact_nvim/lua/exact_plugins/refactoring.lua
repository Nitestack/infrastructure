---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.editor.refactoring" },
  {
    "ThePrimeagen/refactoring.nvim",
    event = function()
      return {}
    end,
    keys = core.lazy_map({
      [{ "n", "v" }] = {
        ["<leader>r"] = "Refactoring",
      },
    }),
    ---@module "refactoring"
    ---@type ConfigOpts
    opts = {},
  },
}
