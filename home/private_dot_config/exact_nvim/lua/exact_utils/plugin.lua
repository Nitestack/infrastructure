--------------------------------------------------------------------------------
--  PLUGIN UTILS
--------------------------------------------------------------------------------
---@class utils.plugin
local M = {}

---Returns a spec of disabled plugins
---@param plugins string[]
---@return LazyPluginSpec[]
function M.get_disabled_plugin_spec(plugins)
  return vim.tbl_map(function(plugin_name)
    return {
      plugin_name,
      enabled = false,
    }
  end, plugins)
end

---@class utils.plugin.language_config
---@field mason? string|string[]
---@field treesitter? string|string[]
---@field lsp? utils.plugin.language_config.lsp
---@field formatter? utils.plugin.language_config.formatter
---@field linter? utils.plugin.language_config.linter
---@field dap? utils.plugin.language_config.dap
---@field test? utils.plugin.language_config.test
---@field plugins? LazyPluginSpec[]

---@class utils.plugin.language_config.lsp
---@field servers? table<string, table>
---@field setup? table<string, fun(server:string, opts:_.lspconfig.options):boolean?>

---@class utils.plugin.language_config.formatter
---@field formatters_by_ft? table<string, conform.FormatterUnit[]>
---@field formatters? table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>

---@class utils.plugin.language_config.linter
---@field linters_by_ft? table<string, string[]>
---@field linters? table<string,table>

---@class utils.plugin.language_config.dap
---@field adapters? table<string, Adapter|fun():Adapter>
---@field configurations? { [1]:(Configuration|fun():Configuration)[], langs?:string|string[] }[]

---@alias utils.plugin.language_config.test.adapters table<string, any>

---@class utils.plugin.language_config.test
---@field dependencies? string|string[]|LazyPluginSpec[]
---@field adapters? utils.plugin.language_config.test.adapters

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
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, utils.str_to_tbl(config.treesitter))
      end,
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
        local dap = require("dap")

        -- Setup adapters
        for adapter_name, _ in pairs(config.dap.adapters or {}) do
          if not dap.adapters[adapter_name] then
            local adapter = config.dap.adapters[adapter_name]
            require("dap").adapters[adapter_name] = type(adapter) == "function" and adapter() or adapter
          end
        end

        -- Setup configurations
        for _, configuration in ipairs(config.dap.configurations or {}) do
          for _, lang in ipairs(utils.str_to_tbl(configuration.langs or {})) do
            if not dap.configurations[lang] then
              require("dap").configurations[lang] = vim.tbl_map(function(c)
                return type(c) == "function" and c() or c
              end, configuration[1])
            end
          end
        end
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

return M
