--------------------------------------------------------------------------------
--  NEOVIM CONFIGURATION
--------------------------------------------------------------------------------
if vim.env.VSCODE then
  vim.g.vscode = true
end

if vim.loader then
  vim.loader.enable()
end

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
_G.core = require("utils.globals")

_G.core.icons = require("core.icons")
_G.core.config = require("core.config")

_G.utils = {}
_G.utils.general = require("utils.general")
_G.utils.lsp = require("utils.lsp")

--------------------------------------------------------------------------------
--  Plugins
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup(require("core.lazy"))
