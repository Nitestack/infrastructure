---@type LazyPluginSpec
return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    opts = vim.tbl_deep_extend("force", opts or {}, core.config.plugins.linting)

    opts.events = { "BufWritePost", "BufReadPost" }

    if not core.config.performance_mode then
      table.insert(opts.events, "InsertLeave")
    end
  end,
}
