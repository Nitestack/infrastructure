---@type LazyPluginSpec
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
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
  config = function(_, opts)
    local lint = require("lint")
    for name, linter in pairs(opts.linters) do
      if type(linter) == "table" and type(lint.linters[name]) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
      else
        lint.linters[name] = linter
      end
    end
    lint.linters_by_ft = opts.linters_by_ft

    core.auto_cmds({
      {
        { "BufWritePost", "BufReadPost", "InsertLeave" },
        {
          group = "nvim-lint",
          callback = function()
            require("lint").try_lint()
          end,
        },
      },
    })
  end,
}
