--------------------------------------------------------------------------------
--  TypeScript
--------------------------------------------------------------------------------

local filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

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
          },
        },
      },
      ---@type lspconfig.options.tsserver
      tsserver = {
        autostart = false,
        mason = false,
      },
      prismals = {},
    },
  },
  mason = {
    "vtsls",
    "eslint_d",
    "prettierd",
    "prettier",
    "prisma-language-server",
  },
  treesitter = {
    "javascript",
    "jsdoc",
    "prisma",
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
      ["javascript"] = { "eslint_d", "eslint" },
      ["javascriptreact"] = { "eslint_d", "eslint" },
      ["typescript"] = { "eslint_d", "eslint" },
      ["typescriptreact"] = { "eslint_d", "eslint" },
    },
  },
  plugins = utils.plugin.with_extensions({
    { import = "lazyvim.plugins.extras.linting.eslint" }, -- Use this as long as eslint_d doesn't work for eslint v9
    { import = "lazyvim.plugins.extras.lang.typescript" },
    {
      "pmizio/typescript-tools.nvim",
      ft = filetypes,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
      },
      opts = {
        settings = {
          tsserver_local = "en",
          complete_function_calls = true,
          include_completions_with_insert_text = true,
          tsserver_max_memory = 3072,
          tsserver_format_options = {
            insertSpaceAfterFunctionKeywordForAnonymousFunctions = false,
            insertSpaceAfterTypeAssertion = true,
            semicolons = "insert",

            indentSize = vim.opt.shiftwidth,
            convertTabsToSpaces = vim.opt.expandtab,
            tabSize = vim.opt.tabstop,
          },
          tsserver_file_preferences = {
            quotePreference = "double",
            importModuleSpecifierPreference = "non-relative",
            generateReturnInDocTemplate = false,
            --
            includeInlayParameterNameHints = "literals",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        {
          "yioneko/nvim-vtsls",
          config = function()
            require("vtsls").config({})
          end,
        },
      },
      opts = function()
        require("lspconfig.configs").vtsls = require("vtsls").lspconfig
      end,
    },
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
            desc = "Node.js: Show latest package version",
          },
          ["h"] = {
            function()
              require("package-info").hide()
            end,
            desc = "Node.js: Hide package versions",
          },
          ["t"] = {
            function()
              require("package-info").toggle()
            end,
            desc = "Node.js: Toggle package versions",
          },
          ["u"] = {
            function()
              require("package-info").update()
            end,
            desc = "Node.js: Update dependency",
          },
          ["d"] = {
            function()
              require("package-info").delete()
            end,
            desc = "Node.js: Delete dependency",
          },
          ["i"] = {
            function()
              require("package-info").install()
            end,
            desc = "Node.js: Install dependency",
          },
          ["v"] = {
            function()
              require("package-info").change_version()
            end,
            desc = "Node.js: Change dependency version",
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
    {
      "dmmulroy/ts-error-translator.nvim",
      ft = filetypes,
      opts = {},
    },
  }, {
    which_key = {
      ["<leader>n"] = "Node.js",
    },
    telescope = {
      extensions = "package_info",
    },
  }),
})
