-- ╭─────────────────────────────────────────────────────────╮
-- │ TypeScript                                              │
-- ╰─────────────────────────────────────────────────────────╯

local filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

-- ── tsserver settings ───────────────────────────────────────────────
---@type _.lspconfig.settings.vtsls.Typescript
local tsserver_settings = {
  locale = "en",
  format = {
    insertSpaceAfterFunctionKeywordForAnonymousFunctions = false,
    insertSpaceAfterTypeAssertion = true,
    semicolons = "insert",

    indentSize = vim.opt.shiftwidth,
    convertTabsToSpaces = vim.opt.expandtab,
    tabSize = vim.opt.tabstop,
  },
  preferences = {
    quoteStyle = "double",
    importModuleSpecifier = "non-relative",
  },
  suggest = {
    completeFunctionCalls = true,
    jsdoc = {
      generateReturns = false,
    },
  },
  inlayHints = {
    parameterNames = { enabled = "literals" },
    functionParameterTypes = { enabled = true },
    variableTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    enumMemberValues = { enabled = true },
  },
  updateImportsOnFileMove = { enabled = "always" },
}

return utils.plugin.get_language_spec({
  lsp = {
    servers = {
      ---@type lspconfig.options.vtsls
      vtsls = {
        settings = {
          typescript = tsserver_settings,
          ---@diagnostic disable-next-line: assign-type-mismatch
          javascript = tsserver_settings,
          vtsls = {
            autoUseWorkspaceTsdk = true,
            enableMoveToFileCodeAction = true,
          },
        },
      },
      eslint = {
        autostart = false,
        mason = false,
      },
    },
  },
  mason = {
    "eslint_d",
    "prettierd",
    "prettier",
  },
  treesitter = {
    "javascript",
    "jsdoc",
  },
  formatter = {
    formatters_by_ft = {
      ["javascript"] = { "prettierd", "prettier" },
      ["javascriptreact"] = { "prettierd", "prettier" },
      ["typescript"] = { "prettierd", "prettier" },
      ["typescriptreact"] = { "prettierd", "prettier" },
    },
  },
  linter = {
    linters_by_ft = {
      ["javascript"] = { "eslint_d" },
      ["javascriptreact"] = { "eslint_d" },
      ["typescript"] = { "eslint_d" },
      ["typescriptreact"] = { "eslint_d" },
    },
  },
  plugins = utils.plugin.with_extensions({
    { import = "lazyvim.plugins.extras.linting.eslint" }, -- Use this as long as eslint_d doesn't work for eslint v9
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.prisma" },
    {
      "vuki656/package-info.nvim",
      dependencies = {
        "MunifTanjim/nui.nvim",
      },
      event = {
        "BufReadPre package.json",
        "BufNewFile package.json",
      },
      keys = core.lazy_map({
        n = {
          ["s"] = {
            function()
              require("package-info").show({ force = true })
            end,
            desc = "Show latest package version",
          },
          ["h"] = {
            function()
              require("package-info").hide()
            end,
            desc = "Hide package versions",
          },
          ["t"] = {
            function()
              require("package-info").toggle()
            end,
            desc = "Toggle package versions",
          },
          ["u"] = {
            function()
              require("package-info").update()
            end,
            desc = "Update dependency",
          },
          ["d"] = {
            function()
              require("package-info").delete()
            end,
            desc = "Delete dependency",
          },
          ["i"] = {
            function()
              require("package-info").install()
            end,
            desc = "Install dependency",
          },
          ["v"] = {
            function()
              require("package-info").change_version()
            end,
            desc = "Change dependency version",
          },
        },
      }, {
        silent = true,
        noremap = true,
        prefix = "<leader>n",
      }),
      opts = {
        package_manager = "pnpm",
      },
    },
    {
      "axelvc/template-string.nvim",
      ft = filetypes,
      opts = {},
    },
  }, {
    telescope = {
      extensions = "package_info",
    },
    which_key = {
      { "<leader>n", group = "Node.js" },
    },
  }),
})
