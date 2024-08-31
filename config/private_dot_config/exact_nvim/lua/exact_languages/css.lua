-- ╭─────────────────────────────────────────────────────────╮
-- │ CSS                                                     │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  mason = {
    "css-lsp",
    "cssmodules-language-server",
    "prettierd",
    "prettier",
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
      tailwindcss = {
        autostart = false,
      },
    },
  },
  formatter = {
    formatters_by_ft = {
      ["css"] = { "prettierd", "prettier" },
      ["scss"] = { "prettierd", "prettier" },
      ["sass"] = { "prettierd", "prettier" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    {
      "luckasRanarison/tailwind-tools.nvim",
      name = "tailwind-tools",
      build = ":UpdateRemotePlugins",
      dependencies = "nvim-treesitter/nvim-treesitter",
      ft = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "css",
        "scss",
        "html",
      },
      ---@module "tailwind-tools"
      ---@type TailwindTools.Option
      opts = {
        server = {
          settings = {
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
})
