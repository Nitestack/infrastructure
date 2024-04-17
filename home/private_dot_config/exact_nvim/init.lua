--------------------------------------------------------------------------------
--  NEOVIM CONFIGURATION
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
---@class utils
_G.utils = require("utils")
---@class core
_G.core = require("core")

_G.core.map = utils.mappings.map
_G.core.single_map = utils.mappings.single_map
_G.core.lazy_map = utils.mappings.lazy_map
_G.core.single_lazy_map = utils.mappings.single_lazy_map
_G.core.auto_cmds = utils.cmds.auto_cmds
_G.core.user_cmds = utils.cmds.user_cmds

--------------------------------------------------------------------------------
--  Settings
--------------------------------------------------------------------------------

-- Options
for option, val in pairs(core.settings.options) do
  vim.opt[option] = val
end

-- Globals
for global, val in pairs(core.settings.globals) do
  vim.g[global] = val
end

-- Providers
for _, provider in ipairs(core.settings.disabled_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- Additional settings to run
core.settings.run()

--------------------------------------------------------------------------------
--  Filetypes
--------------------------------------------------------------------------------
vim.filetype.add(core.filetypes)

--------------------------------------------------------------------------------
--  Commands
--------------------------------------------------------------------------------
local function load_commands()
  core.auto_cmds(core.cmds.auto_cmds, core.cmds.auto_cmd_opts, core.cmds.au_group_opts)
  core.user_cmds(core.cmds.user_cmds, core.cmds.user_cmd_opts)
end

-- Commands can be loaded lazily when not opening a file
local lazy_autocmds = vim.fn.argc(-1) == 0
if not lazy_autocmds then
  load_commands()
end

--------------------------------------------------------------------------------
--  Plugins
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Bootstrap lazy.nvim if it isn't installed
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

-- Add lazy.nvim to runtimepath
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Setup LazyFile event
utils.lazyfile()

-- Initialize lazy.nvim and load plugins
require("lazy").setup({
  spec = {
    { import = "languages" },
    { import = "plugins.lsp" },
    { import = "plugins.dap" },
    { import = "plugins" },
    utils.plugin.get_disabled_plugin_spec(core.config.disabled_plugins),
  },
  defaults = {
    lazy = true,
    version = false,
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
        -- "2html_plugin",
        -- "bugreport",
        -- "compiler",
        -- "ftplugin",
        -- "getscript",
        -- "getscriptPlugin",
        -- "gzip",
        -- "logipat",
        -- "matchit",
        -- "netrw",
        -- "netrwFileHandlers",
        -- "netrwPlugin",
        -- "netrwSettings",
        -- "optwin",
        -- "rplugin",
        -- "rrhelper",
        -- "spellfile_plugin",
        -- "synmenu",
        -- "syntax",
        -- "tar",
        -- "tarPlugin",
        -- "tohtml",
        -- "tutor",
        -- "vimball",
        -- "vimballPlugin",
        -- "zip",
        -- "zipPlugin",
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

core.auto_cmds({
  -- Setup
  {
    "User",
    {
      group = "setup",
      pattern = "VeryLazy",
      callback = function()
        -- Load commands (if not yet)
        if lazy_autocmds then
          load_commands()
        end

        -- Load keymaps
        local keymaps = core.mappings

        core.map(keymaps.mappings, keymaps.mapping_opts)
      end,
    },
  },
  -- Auto load session
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
