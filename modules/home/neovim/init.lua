-- ╭─────────────────────────────────────────────────────────╮
-- │ Neovim Config                                           │
-- ╰─────────────────────────────────────────────────────────╯

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
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
-- Add lazy to the `runtimepath`, this allows us to `require` it.
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = core.config.lazyvim,
    },
    { import = "languages" },
    { import = "plugins" },
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
  defaults = {
    lazy = true,
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
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin", -- Needed for spell checking files
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
