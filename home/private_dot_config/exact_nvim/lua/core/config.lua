--------------------------------------------------------------------------------
--  USER CONFIGURATION
--------------------------------------------------------------------------------

---@class UserConfig
---@field disabled_plugins string[]
---@field lazyvim LazyVimOptions
---@field ui UserConfigUI
---@field plugins UserConfigPlugins

---@class UserConfigUI
---@field theme string
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
local M = {}

--------------------------------------------------------------------------------
--  UI options
--------------------------------------------------------------------------------
M.ui = {
  theme = "catppuccin",
  logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
- Nitestack -
]],
  transparent = {
    enabled = false,
    floats = false,
  },
  width = 0.8,
  height = 0.8,
}

--------------------------------------------------------------------------------
--  LazyVim options
--------------------------------------------------------------------------------
M.lazyvim = {
  colorscheme = M.ui.theme,
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
--  Plugins
--------------------------------------------------------------------------------
M.plugins = {
  mason = { "codespell", "emmet-language-server" },
  treesitter = {
    "diff",
    "query",
    "regex",

    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",

    "ssh_config",
    "ini",
    "tmux",
    "xml",
    "toml",
  },
  linting = {
    linters_by_ft = {
      ["*"] = { "codespell" },
    },
  },
  formatting = {},
}

M.disabled_plugins = {
  "akinsho/bufferline.nvim",
  "echasnovski/mini.indentscope",
  "pmizio/typescript-tools.nvim",
  "echasnovski/mini.pairs",
  "folke/tokyonight.nvim",
  "nvim-neo-tree/neo-tree.nvim",
}

return M
