return utils.plugin.with_extensions({
  {
    "debugloop/telescope-undo.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
    cmd = "Telescope undo",
    keys = core.lazy_map({
      n = {
        ["<leader>fu"] = {
          function()
            require("telescope").extensions.undo.undo()
          end,
          desc = "Undo History",
        },
      },
    }),
  },
}, {
  telescope = {
    extensions = "undo",
    opts = {
      undo = {
        time_format = "%a, %c",
      },
    },
  },
})
