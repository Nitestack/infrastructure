--------------------------------------------------------------------------------
--  CSS
--------------------------------------------------------------------------------
return core.load_language({
  mason = {
    "css-lsp",
    "cssmodules-language-server",
    "stylelint",
    "prettierd",
    "tailwindcss-language-server",
  },
  treesitter = {
    "css",
    "scss",
  },
  lsp = {
    servers = {
      ---@type lspconfig.options.cssls
      cssls = {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      cssmodules_ls = {},
      ---@type lspconfig.options.tailwindcss
      tailwindcss = {
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "class.*", ".*Class.*", ".*Class", ".*Style.*" },
            emmetCompletions = true,
            experimental = {
              classRegex = {
                { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                "(?:enter|leave)(?:From|To)?=\\s*(?:\"|')([^(?:\"|')]*)",
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
            lint = {
              cssConflict = "error",
            },
          },
        },
      },
    },
  },
  linter = {
    linters_by_ft = {
      ["css"] = { "stylelint" },
      ["scss"] = { "stylelint" },
      ["sass"] = { "stylelint" },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["css"] = { "prettierd" },
      ["scss"] = { "prettierd" },
      ["sass"] = { "prettierd" },
    },
  },
  plugins = {
    {
      "luckasRanarison/tailwind-tools.nvim",
      ft = function()
        return require("lspconfig.server_configurations.tailwindcss").default_config.filetypes
      end,
      ---@type TailwindTools.Option
      opts = {},
    },
  },
})
