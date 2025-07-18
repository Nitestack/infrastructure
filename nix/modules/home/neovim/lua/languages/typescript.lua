-- ╭─────────────────────────────────────────────────────────╮
-- │ TypeScript                                              │
-- ╰─────────────────────────────────────────────────────────╯

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
      angularls = {},
      vtsls = {
        settings = {
          typescript = tsserver_settings,
          ---@diagnostic disable-next-line: assign-type-mismatch
          javascript = tsserver_settings,
          vtsls = {
            enableMoveToFileCodeAction = true,
          },
        },
      },
    },
    setup = {
      angularls = function()
        LazyVim.lsp.on_attach(function(client)
          --HACK: disable angular renaming capability due to duplicate rename popping up
          client.server_capabilities.renameProvider = false
        end, "angularls")
      end,
    },
  },
  treesitter = {
    "angular",
    "javascript",
    "jsdoc",
  },
  formatter = {
    formatters_by_ft = {
      ["javascript"] = { "prettierd" },
      ["javascriptreact"] = { "prettierd" },
      ["typescript"] = { "prettierd" },
      ["typescriptreact"] = { "prettierd" },
      ["htmlangular"] = { "prettierd" },
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
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.prisma" },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function()
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
          pattern = { "*.component.html", "*.container.html" },
          callback = function()
            vim.treesitter.start(nil, "angular")
          end,
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      opts = function(_, opts)
        LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
          {
            name = "@angular/language-server",
            enableForWorkspaceTypeScriptVersions = true,
          },
        })
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
  }, {
    which_key = {
      { "<leader>n", group = "Node.js" },
    },
  }),
})
