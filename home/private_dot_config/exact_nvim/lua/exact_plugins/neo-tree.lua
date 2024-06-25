return utils.plugin.with_extensions({
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = core.lazy_map({
      n = {
        [{ "<leader>e", "<leader>E", "<leader>be", "<leader>ge" }] = { false },
      },
    }),
    opts = function(_, opts)
      opts.hide_root_node = true
      opts.retain_hidden_root_indent = true

      -- Window
      opts.window = opts.window or {}
      opts.window.position = "float"
      ---@module "nui/popup"
      ---@type nui_popup_options
      opts.window.popup = opts.window.popup or {}
      opts.window.popup.position = "50%"
      opts.window.popup.border = opts.window.popup.border or {}
      opts.window.popup.border.style = core.config.ui.transparent.floats and "rounded" or "none"
      opts.window.popup.border.padding = core.config.ui.transparent.floats and { 0, 0 } or { 1, 1 }
      opts.window.popup.size = opts.window.popup.size or {}
      opts.window.popup.size.width = core.config.ui.width
      opts.window.popup.size.height = core.config.ui.height

      -- Show hidden files
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
      opts.filesystem.filtered_items.show_hidden_count = false
      opts.filesystem.filtered_items.hide_dotfiles = false
      opts.filesystem.filtered_items.hide_gitignored = false
      opts.filesystem.filtered_items.hide_hidden = false
      opts.filesystem.filtered_items.never_show = {
        ".DS_Store",
      }

      -- Default component configs
      opts.default_component_configs = opts.default_component_configs or {}

      opts.default_component_configs.name = opts.default_component_configs.name or {}
      opts.default_component_configs.name.highlight_opened_files = true

      opts.default_component_configs.icon = opts.default_component_configs.icon or {}
      opts.default_component_configs.icon.folder_closed = core.icons.ui.FolderClosed
      opts.default_component_configs.icon.folder_open = core.icons.ui.FolderOpen
      opts.default_component_configs.icon.folder_empty = core.icons.ui.EmptyFolder
      opts.default_component_configs.icon.folder_empty_open = core.icons.ui.EmptyFolderOpen

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
