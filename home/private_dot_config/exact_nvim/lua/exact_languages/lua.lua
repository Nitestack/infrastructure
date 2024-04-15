--------------------------------------------------------------------------------
--  Lua
--------------------------------------------------------------------------------
return utils.plugin.get_language_spec({
  treesitter = {
    "lua",
    "luadoc",
    "luap",
  },
  lsp = {
    servers = {
      ---@type lspconfig.options.lua_ls
      lua_ls = {
        settings = {
          Lua = {
            telemetry = {
              enable = false,
            },
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
            hint = {
              enable = false,
              paramName = "All",
              paramType = true,
              arrayIndex = "Disable",
              setType = true,
            },
            diagnostics = {
              unusedLocalExclude = { "_*" },
            },
          },
        },
      },
    },
  },
  mason = {
    "lua-language-server",
    "stylua",
    "selene",
  },
  formatter = {
    formatters_by_ft = {
      ["lua"] = { "stylua" },
    },
  },
  linter = {
    linters_by_ft = {
      ["lua"] = { "selene" },
    },
  },
})
