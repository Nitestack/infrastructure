--------------------------------------------------------------------------------
--  JSON
--------------------------------------------------------------------------------
return core.load_language({
  treesitter = {
    "json",
    "json5",
    "jsonc",
  },
  mason = {
    "prettierd",
    "jsonlint",
    "json-lsp",
  },
  lsp = {
    servers = {
      ---@type lspconfig.options.jsonls
      jsonls = {
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
        end,
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      },
    },
  },
  linter = {
    linters_by_ft = {
      ["json"] = { "jsonlint" },
      ["jsonc"] = { "jsonlint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["json"] = { "prettierd" },
      ["jsonc"] = { "prettierd" },
    },
  },
  plugins = {
    {
      "b0o/SchemaStore.nvim",
      version = false, -- last release was May 27, 2023 -> just use latest version
    },
  },
})
