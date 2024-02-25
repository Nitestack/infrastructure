--------------------------------------------------------------------------------
--  USER CONFIGURATION
--------------------------------------------------------------------------------

---@class UserConfig
---@field performance_mode boolean
---@field ui UserConfigUI
---@field plugins UserConfigPlugins
---@field disabled_plugins string[]

---@class UserConfigUI
---@field theme "tokyonight"|"catppuccin"
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
local M = {
  performance_mode = true,
}

M.ui = {
  theme = "tokyonight",
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
    linters = {},
  },
  formatting = {
    formatters_by_ft = {},
    formatters = {},
  },
}

M.disabled_plugins = {
  "pmizio/typescript-tools.nvim",
}

return M
