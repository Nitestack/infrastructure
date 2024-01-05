---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "andymass/vim-matchup",
  },
  event = function()
    return {
      "LazyFile",
    }
  end,
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, core.config.plugins.treesitter)
    end

    -- Auto-install missing parsers on startup
    opts.auto_install = true

    -- Disable indent on certain file types
    opts.indent = opts.indent or {}
    opts.indent.disable = {
      "yaml",
    }

    -- configure vim-matchup
    opts.matchup = {
      enable = true,
      disable_virtual_text = true,
    }
  end,
}
