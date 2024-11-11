return utils.plugin.with_extensions({
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = core.lazy_map({
      n = {
        [{ "<leader>e", "<leader>E" }] = { false },
      },
    }),
    opts = function(_, opts)
      -- Show hidden files
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
      opts.filesystem.filtered_items.show_hidden_count = false
      opts.filesystem.filtered_items.hide_dotfiles = false
      opts.filesystem.filtered_items.hide_gitignored = false
      opts.filesystem.filtered_items.hide_hidden = false

      -- Default component configs
      opts.default_component_configs = opts.default_component_configs or {}

      opts.default_component_configs.name = opts.default_component_configs.name or {}
      opts.default_component_configs.name.highlight_opened_files = true

      opts.default_component_configs.git_status = opts.default_component_configs.git_status or {}
      opts.default_component_configs.git_status.symbols = opts.default_component_configs.git_status.symbols or {}
      opts.default_component_configs.git_status.symbols.added = core.icons.git.LineAdded
      opts.default_component_configs.git_status.symbols.deleted = core.icons.git.LineRemoved
      opts.default_component_configs.git_status.symbols.modified = core.icons.git.LineRemoved
      opts.default_component_configs.git_status.symbols.renamed = core.icons.git.FileRenamed
      opts.default_component_configs.git_status.symbols.untracked = core.icons.git.FileUntracked
      opts.default_component_configs.git_status.symbols.unstaged = core.icons.git.FileUnstaged
      opts.default_component_configs.git_status.symbols.staged = core.icons.git.FileStaged
      opts.default_component_configs.git_status.symbols.ignored = core.icons.git.FileIgnored
      opts.default_component_configs.git_status.symbols.conflict = core.icons.git.FileUnmerged
    end,
  },
}, {
  lualine = "neo-tree",
  catppuccin = {
    neotree = true,
  },
})
