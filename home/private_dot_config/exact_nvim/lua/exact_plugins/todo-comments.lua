---@type LazyPluginSpec
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = "LazyFile",
  keys = core.lazy_map({
    n = {
      ["<leader>xt"] = {
        function()
          vim.cmd("TodoTrouble")
        end,
        "TODO: Trouble",
      },
      ["<leader>xT"] = {
        function()
          vim.cmd("TodoTrouble keywords=TODO,FIX,FIXME")
        end,
        "TODO/FIX/FIXME: Trouble",
      },
      ["[t"] = {
        function()
          require("todo-comments").jump_prev()
        end,
        "TODO: Previous comment",
      },
      ["]t"] = {
        function()
          require("todo-comments").jump_next()
        end,
        "TODO: Next comment",
      },
    },
  }),
  opts = {},
}
