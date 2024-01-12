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
require("utils.loaders").load_plugins(require("core.lazy"))
