---@type LazyPluginSpec
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
  event = "LazyFile",
  keys = core.lazy_map({
    n = {
      ["<leader>xt"] = {
        function()
          vim.cmd("TodoTrouble")
        end,
        desc = "TODO: Trouble",
      },
      ["<leader>xT"] = {
        function()
          vim.cmd("TodoTrouble keywords=TODO,FIX,FIXME")
        end,
        desc = "TODO/FIX/FIXME: Trouble",
      },
      ["[t"] = {
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "TODO: Previous comment",
      },
      ["]t"] = {
        function()
          require("todo-comments").jump_next()
        end,
        desc = "TODO: Next comment",
      },
    },
  }),
  opts = {},
}
