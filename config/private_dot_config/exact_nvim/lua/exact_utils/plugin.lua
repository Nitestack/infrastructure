-- ╭─────────────────────────────────────────────────────────╮
-- │ PLUGIN UTILS                                            │
-- ╰─────────────────────────────────────────────────────────╯

---@class utils.plugin
local M = {}

---@module "dap"

---@class utils.plugin.language_config
---@field mason? string|string[]
---@field treesitter? string|string[]
---@field lsp? utils.plugin.language_config.lsp
---@field formatter? utils.plugin.language_config.formatter
---@field linter? utils.plugin.language_config.linter
---@field dap? fun(add_dap_adapter:fun(name:string, adapter:dap.Adapter), add_dap_configuration:fun(configurations:dap.Configuration[], filetypes:string|string[]))
---@field test? utils.plugin.language_config.test
---@field plugins? LazyPluginSpec[]

---@class utils.plugin.language_config.lsp
---@field servers? table<string, table>
---@field setup? table<string, fun(server:string, opts:_.lspconfig.options):boolean?>

---@module "conform"

---@class utils.plugin.language_config.formatter
---@field formatters_by_ft? table<string, conform.FiletypeFormatter>
---@field formatters? table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>

---@class utils.plugin.language_config.linter
---@field linters_by_ft? table<string, string[]>
---@field linters? table<string,table>

---@alias utils.plugin.language_config.test.adapters table<string, any>

---@class utils.plugin.language_config.test
---@field dependencies? string|string[]|LazyPluginSpec[]
---@field adapters? utils.plugin.language_config.test.adapters

---@param name string
---@param adapter dap.Adapter
local function add_dap_adapter(name, adapter)
  local dap = require("dap")
  if not dap.adapters[name] then
    dap.adapters[name] = adapter
  end
end
---@param configurations dap.Configuration[]
---@param filetypes string|string[]
local function add_dap_configuration(configurations, filetypes)
  local dap = require("dap")
  for _, lang in ipairs(utils.str_to_tbl(filetypes or {})) do
    if not dap.configurations[lang] then
      dap.configurations[lang] = configurations
    end
  end
end

---A helper function to get a plugin spec configuring a language
---@param config utils.plugin.language_config
function M.get_language_spec(config)
  ---@type LazyPluginSpec[]
  local spec = {}

  if config.mason then
    table.insert(spec, {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, utils.str_to_tbl(config.mason))
      end,
    })
  end

  if config.treesitter then
    table.insert(spec, {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = utils.str_to_tbl(config.treesitter),
      },
    })
  end

  if config.lsp then
    table.insert(spec, {
      "neovim/nvim-lspconfig",
      opts = {
        setup = config.lsp.setup or {},
        servers = config.lsp.servers or {},
      },
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

  if config.dap then
    table.insert(spec, {
      "mfussenegger/nvim-dap",
      opts = function()
        config.dap(add_dap_adapter, add_dap_configuration)
      end,
    })
  end

  if config.test then
    table.insert(spec, {
      "nvim-neotest/neotest",
      dependencies = config.test.dependencies or {},
      opts = {
        adapters = config.test.adapters or {},
      },
    })
  end

  if config.plugins then
    vim.list_extend(spec, config.plugins)
  end

  return spec
end

---@module "which-key"

---@class utils.plugin.extension_config
---@field lualine? string|string[]
---@field catppuccin? table<string, boolean|table>
---@field which_key? wk.Spec

---@param plugins LazyPluginSpec[]
---@param extensions utils.plugin.extension_config
---@return LazyPluginSpec[]
function M.with_extensions(plugins, extensions)
  if extensions.lualine then
    table.insert(plugins, {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        opts.extensions = vim.list_extend(opts.extensions or {}, utils.str_to_tbl(extensions.lualine))
      end,
    })
  end
  if extensions.catppuccin then
    table.insert(plugins, {
      "catppuccin/nvim",
      opts = {
        extensions = extensions.catppuccin,
      },
    })
  end
  if extensions.which_key then
    table.insert(plugins, {
      "folke/which-key.nvim",
      opts = {
        spec = extensions.which_key,
      },
    })
  end
  return plugins
end

return M
