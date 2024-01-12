return utils.lsp.load_language({
  mason = {
    "css-lsp",
    "cssmodules-language-server",
    "stylelint",
    "prettierd",
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
    { import = "lazyvim.plugins.extras.lang.tailwind" },
  },
})
