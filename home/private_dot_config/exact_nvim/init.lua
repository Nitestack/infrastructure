-- ╭─────────────────────────────────────────────────────────╮
-- │ NEOVIM CONFIGURATION                                    │
-- ╰─────────────────────────────────────────────────────────╯

if vim.loader then
  vim.loader.enable()
end

-- Ensure Neovim version is atleast 0.10
if vim.fn.has("nvim-0.10") == 0 then
  vim.api.nvim_echo({
    { "Configuration requires Neovim >= 0.10.0\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- ── Globals ─────────────────────────────────────────────────────────
---@class utils
_G.utils = require("utils")
---@class core
_G.core = require("core")

_G.core.map = utils.mappings.map
_G.core.lazy_map = utils.mappings.lazy_map
_G.core.auto_cmds = utils.cmds.auto_cmds
_G.core.user_cmds = utils.cmds.user_cmds

-- ── Filetypes ───────────────────────────────────────────────────────
vim.filetype.add(core.filetypes)

-- ── Plugins ─────────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = core.config.lazyvim,
    },
    { import = "languages" },
    { import = "plugins.lsp" },
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install
    version = false, -- always use the latest git commit
  },
  install = {
    colorscheme = { core.config.ui.theme, "habamax" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  ui = {
    size = { width = core.config.ui.width, height = core.config.ui.height },
    border = core.config.ui.transparent.floats and "rounded" or "none",
    title = core.config.ui.transparent.floats and "lazy.nvim" or nil,
    icons = {
      loaded = core.icons.ui.PackageInstalled,
      not_loaded = core.icons.ui.PackageUninstalled,
    },
    backdrop = 100,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ── Auto session ────────────────────────────────────────────────────
core.auto_cmds({
  {
    "User",
    {
      group = "persistence",
      pattern = "VeryLazy",
      callback = function()
        require("lazy").load({ plugins = { "persistence.nvim" } })
        local persistence = require("persistence")
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
          -- Close all windows and reopen last session for neovim
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
              vim.api.nvim_win_close(win, false)
            end
          end
          persistence.load()
        else
          persistence.stop()
        end
      end,
      nested = true,
    },
  },
})
