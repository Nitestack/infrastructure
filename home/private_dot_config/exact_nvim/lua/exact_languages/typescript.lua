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

return core.load_language({
  lsp = {
    servers = {
      vtsls = {
        settings = {
          typescript = tsserver_settings,
          javascript = tsserver_settings,
        },
      },
      eslint = {},
      ---@type lspconfig.options.tsserver
      tsserver = {
        autostart = false,
      },
      prismals = {},
    },
  },
  mason = {
    "vtsls",
    "eslint_d",
    "eslint-lsp",
    "prettierd",
    "prettier",
    "prisma-language-server",
  },
  treesitter = {
    "javascript",
    "jsdoc",
    "typescript",
    "prisma",
    "tsx",
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
  plugins = {
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
          ["<leader>ns"] = {
            function()
              require("package-info").show({ force = true })
            end,
            "Node.js: Show latest package version",
          },
          ["<leader>nh"] = {
            function()
              require("package-info").hide()
            end,
            "Node.js: Hide package versions",
          },
          ["<leader>nt"] = {
            function()
              require("package-info").toggle()
            end,
            "Node.js: Toggle package versions",
          },
          ["<leader>nu"] = {
            function()
              require("package-info").update()
            end,
            "Node.js: Update dependency",
          },
          ["<leader>nd"] = {
            function()
              require("package-info").delete()
            end,
            "Node.js: Delete dependency",
          },
          ["<leader>ni"] = {
            function()
              require("package-info").install()
            end,
            "Node.js: Install dependency",
          },
          ["<leader>nv"] = {
            function()
              require("package-info").change_version()
            end,
            "Node.js: Change dependency version",
          },
        },
      }, {
        silent = true,
        noremap = true,
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
    {
      "nvim-telescope/telescope.nvim",
      opts = {
        load_extensions = {
          ["package_info"] = true,
        },
      },
    },
    {
      "folke/which-key.nvim",
      opts = {
        defaults = {
          ["<leader>n"] = { name = "+node.js" },
        },
      },
    },
  },
})
