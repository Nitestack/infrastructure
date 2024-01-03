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
_G.core = {}

_G.core.ft_plugin = require("utils.loaders").load_ftplugin

_G.core.map = require("utils.mappings").map
_G.core.single_map = require("utils.mappings").single_map
_G.core.lazy_map = require("utils.mappings").lazy_map
_G.core.single_lazy_map = require("utils.mappings").single_lazy_map
_G.core.auto_cmds = require("utils.cmds").auto_cmds
_G.core.user_cmds = require("utils.cmds").user_cmds

_G.core.icons = require("core.icons")
_G.core.config = require("core.config")

_G.utils = {}
_G.utils.general = require("utils.general")
_G.utils.lsp = require("utils.lsp")

--------------------------------------------------------------------------------
--  Plugins
--------------------------------------------------------------------------------
require("utils.loaders").load_plugins(require("core.lazy"))
