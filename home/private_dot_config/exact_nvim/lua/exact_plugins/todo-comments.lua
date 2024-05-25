---@type LazyPluginSpec
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
  keys = core.lazy_map({
    n = {
      [{ "<leader>st", "<leader>sT" }] = { false },
    },
  }),
}
