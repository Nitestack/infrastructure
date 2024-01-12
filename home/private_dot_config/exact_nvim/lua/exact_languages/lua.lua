return utils.lsp.load_language({
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
            diagnostics = {
              disable = {
                "inject-field",
                "missing-fields",
              },
            },
            hint = {
              enable = true,
              paramName = "All",
              paramType = true,
              arrayIndex = "Disable",
              setType = true,
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
