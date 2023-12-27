--------------------------------------------------------------------------------
--  USER CONFIGURATION
--------------------------------------------------------------------------------

---@class UserConfig
---@field disabled_plugins string[]
---@field lazyvim LazyVimOptions
---@field ui UserConfigUI
---@field plugins UserConfigPlugins

---@class UserConfigUI
---@field logo string Generate ANSI art with: https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow
---@field width number
---@field height number
---@field transparent { enabled: boolean, floats: boolean }

---@class UserConfigPlugins
---@field mason string[]
---@field treesitter string[]
---@field linting LanguageLinterConfig
---@field formatting LanguageFormatterConfig

---@type UserConfig
---@diagnostic disable-next-line: missing-fields
local M = {}

--------------------------------------------------------------------------------
--  LazyVim options
--------------------------------------------------------------------------------
M.lazyvim = {
  colorscheme = "catppuccin",
  news = {
    lazyvim = true,
    neovim = true,
  },
  icons = {
    diagnostics = vim.tbl_map(function(icon)
      return icon .. " "
    end, {
      Error = core.icons.diagnostics.Error,
      Warn = core.icons.diagnostics.Warning,
      Info = core.icons.diagnostics.Information,
      Hint = core.icons.diagnostics.Hint,
    }),
    kinds = vim.tbl_map(function(icon)
      return icon .. " "
    end, core.icons.kind),
  },
}

--------------------------------------------------------------------------------
--  UI options
--------------------------------------------------------------------------------
M.ui = {
  logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
  transparent = {
    enabled = true,
    floats = false,
  },
  width = 0.8,
  height = 0.8,
}

--------------------------------------------------------------------------------
--  Plugins
--------------------------------------------------------------------------------
M.plugins = {
  mason = { "codespell" },
  treesitter = {
    "diff",
    "query",
    "regex",

    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
  },
  linting = {
    linters_by_ft = {
      ["*"] = { "codespell" },
    },
  },
  formatting = {},
}

M.disabled_plugins = {
  "folke/flash.nvim",
  "rcarriga/nvim-notify",
}

return M
