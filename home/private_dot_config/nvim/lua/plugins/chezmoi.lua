---@type LazySpec
return {
  {
    "xvzc/chezmoi.nvim",
    cmd = { "ChezmoiEdit", "ChezmoiList" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = core.lazy_map({
      n = {
        ["<leader>cz"] = {
          function()
            require("telescope").extensions.chezmoi.find_files()
          end,
          "Chezmoi: Find Files",
        },
      },
    }),
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      load_extensions = {
        ["chezmoi"] = true,
      },
    },
  },
}
