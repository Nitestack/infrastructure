--------------------------------------------------------------------------------
--  GlOBALS
--------------------------------------------------------------------------------
local M = {}

---@param plugins string[]
---@return LazyPluginSpec[]
function M.disabled_plugins(plugins)
  local spec = {}

  for _, plugin in ipairs(plugins) do
    table.insert(spec, {
      plugin,
      enabled = false,
    })
  end

  return spec
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function M.falsy(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == "boolean" then
    return not item
  end
  if item_type == "string" then
    return item == ""
  end
  if item_type == "number" then
    return item <= 0
  end
  if item_type == "table" then
    return vim.tbl_isempty(item)
  end
  return item ~= nil
end

---Convert a string or table to a table
---@param str_or_tbl string|table
function M.str_to_tbl(str_or_tbl)
  if type(str_or_tbl) == "string" then
    return { str_or_tbl }
  end
  return str_or_tbl
end

---@alias StringOrArray string|string[]

---@class LanguageConfig
---@field lsp? LanguageLspConfig
---@field mason? StringOrArray
---@field treesitter? StringOrArray
---@field formatter? LanguageFormatterConfig
---@field linter? LanguageLinterConfig
---@field plugins? LazyPluginSpec[]

---@class LanguageLspConfig
---@field servers? table<string, table>
---@field setup? table<string, fun(server:string, opts:_.lspconfig.options):boolean?>

---@class LanguageFormatterConfig
---@field formatters_by_ft? table<string, conform.FormatterUnit[]>
---@field formatters? table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>

---@class LanguageLinterConfig
---@field linters_by_ft? table<string, string[]>
---@field linters? table<string,table>

---@param config LanguageConfig
function M.load_language(config)
  ---@type LazyPluginSpec[]
  local spec = {}

  if config.lsp then
    table.insert(spec, {
      "neovim/nvim-lspconfig",
      opts = {
        setup = config.lsp.setup or {},
        servers = config.lsp.servers or {},
      },
    })
  end

  if config.mason then
    table.insert(spec, {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, core.str_to_tbl(config.mason))
      end,
    })
  end

  if config.treesitter then
    table.insert(spec, {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, core.str_to_tbl(config.treesitter))
      end,
    })
  end

  if config.formatter then
    table.insert(spec, {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = config.formatter.formatters_by_ft or {},
        formatters = config.formatter.formatters or {},
      },
    })
  end

  if config.linter then
    table.insert(spec, {
      "mfussenegger/nvim-lint",
      opts = {
        linters_by_ft = config.linter.linters_by_ft or {},
        linters = config.linter.linters or {},
      },
    })
  end

  if config.plugins then
    vim.list_extend(spec, config.plugins)
  end

  return spec
end

function M.is_win()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

function M.is_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

function M.is_nightly()
  local version = vim.version()

  if version.prerelease then
    return true
  else
    return false
  end
end

function M.is_wsl()
  return os.getenv("WSL_DISTRO_NAME") ~= nil
end

function M.is_neovide()
  return vim.g.neovide
end

---@param config { options?: vim.opt, config?: fun(), mappings?: Mappings, mapping_opts?: KeymapOpts }
function M.ft_plugin(config)
  if config.options then
    for k, v in pairs(config.options) do
      vim.wo[k] = v
    end
  end
  if config.config then
    config.config()
  end
  if config.mappings then
    require("utils.mappings").map(config.mappings, config.mapping_opts)
  end
end

M.map = require("utils.mappings").map
M.single_map = require("utils.mappings").single_map
M.lazy_map = require("utils.mappings").lazy_map
M.single_lazy_map = require("utils.mappings").single_lazy_map
M.disable_mapping = require("utils.mappings").disable_mapping
M.auto_cmds = require("utils.commands").auto_cmds
M.user_cmds = require("utils.commands").user_cmds

return M
