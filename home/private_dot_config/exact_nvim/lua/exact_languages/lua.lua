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
            hover = { expandAlias = false },
            type = {
              castNumberToInteger = true,
            },
            hint = {
              paramName = "All",
              paramType = true,
              arrayIndex = "Disable",
              setType = true,
            },
            diagnostics = {
              unusedLocalExclude = { "_*" },
              disable = {
                "inject-field",
                "missing-fields",
              },
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
  plugins = {
    {
      "folke/lazydev.nvim",
      ---@module "lazydev"
      ---@param opts lazydev.Config
      opts = function(_, opts)
        opts.library = vim.list_extend(opts.library or {}, {
          { path = "wezterm-types", mods = { "wezterm" } },
          { path = "smart-splits.nvim/plugin", words = { "SmartSplitsWeztermConfig" } },
        })
      end,
    },
  },
})
