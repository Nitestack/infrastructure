return utils.plugin.with_extensions({
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "andymass/vim-matchup",
      "RRethy/nvim-treesitter-endwise",
    },
    opts = {
      -- configure vim-matchup
      matchup = {
        enable = true,
        disable_virtual_text = true,
      },
      -- configure nvim-treesitter-endwise
      endwise = {
        enable = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = core.config.plugins.treesitter,
    },
  },
  { import = "lazyvim.plugins.extras.ui.treesitter-context" },
}, {
  catppuccin = {
    treesitter_context = true,
    treesitter = true,
  },
})
