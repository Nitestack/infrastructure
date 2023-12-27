---@type LazyPluginSpec
return {
  "mfussenegger/nvim-lint",
  keys = core.lazy_map({
    n = {
      ["<leader>cl"] = {
        function()
          require("lint").try_lint()
        end,
        "Lint",
      },
    },
  }),
  opts = core.config.plugins.linting,
}
