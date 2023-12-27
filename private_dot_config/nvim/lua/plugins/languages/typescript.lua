return utils.lsp.load_language({
  lsp = {
    servers = {
      -- Disable tsserver because typescript-tools.nvim is used
      tsserver = {
        autostart = false,
        mason = false,
      },
    },
  },
  mason = {
    "typescript-language-server",
    "eslint_d",
    "prettierd",
  },
  treesitter = {
    "javascript",
    "typescript",
    "prisma",
    "tsx",
  },
  formatter = {
    formatters = {
      prettierd = {
        env = {
          PRETTIERD_DEFAULT_CONFIG = utils.general.resolve_path({
            vim.fn.stdpath("config") --[[@as string]],
            "tools",
            "formatters",
            ".prettierrc.json",
          }),
        },
      },
    },
    formatters_by_ft = {
      ["javascript"] = { "prettierd" },
      ["javascriptreact"] = { "prettierd" },
      ["typescript"] = { "prettierd" },
      ["typescriptreact"] = { "prettierd" },
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
  plugins = {
    { import = "lazyvim.plugins.extras.lang.typescript" },
    {
      "pmizio/typescript-tools.nvim",
      event = {
        "BufReadPre *.*ts,*.tsx,*.*js,*.jsx",
        "BufNewFile *.*ts,*.tsx,*.*js,*.jsx",
      },
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
          ["<leader>n"] = {
            name = "+node.js",
          },
        },
      },
    },
  },
})
