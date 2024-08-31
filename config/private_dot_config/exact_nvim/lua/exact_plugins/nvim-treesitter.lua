return utils.plugin.with_extensions({
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "andymass/vim-matchup",
      "RRethy/nvim-treesitter-endwise",
    },
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      -- disable highlighting in chezmoi templates
      opts.highlight.disable = function(_lang, buf)
        -- check if 'filetype' option includes 'chezmoitmpl'
        if string.find(vim.bo.filetype, "chezmoitmpl") then
          return true
        end

        -- check for file size
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end
      opts.highlight.additional_vim_regex_highlighting = false

      -- Auto-install missing parsers on startup
      opts.auto_install = true

      opts.indent = opts.indent or {}
      -- Disable indent on certain file types
      opts.indent.disable = vim.list_extend(opts.indent.disable or {}, { "yaml" })

      -- configure vim-matchup
      opts.matchup = {
        enable = true,
        disable_virtual_text = true,
      }

      -- configure nvim-treesitter-endwise
      opts.endwise = {
        enable = true,
      }
    end,
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
