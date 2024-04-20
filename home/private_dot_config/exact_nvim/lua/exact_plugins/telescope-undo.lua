---@type LazyPluginSpec
return {
  "debugloop/telescope-undo.nvim",
  dependencies = "nvim-telescope/telescope.nvim",
  cmd = "Telescope undo",
  keys = core.lazy_map({
    n = {
      ["<leader>fu"] = {
        function()
          require("telescope").extensions.undo.undo()
        end,
        desc = "Telescope: Undo history",
      },
    },
  }),
  opts = {
    extensions = {
      undo = {
        time_format = "%a, %c",
      },
    },
    load_extensions = {
      ["undo"] = true,
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
  end,
}
