--------------------------------------------------------------------------------
--  USER CONFIGURATION
--------------------------------------------------------------------------------

---@class core.config
---@field performance_mode boolean
---@field ui core.config.ui
---@field plugins core.config.plugins
---@field disabled_plugins string[]
---@field lazyvim LazyVimOptions

---@class core.config.ui
---@field theme "catppuccin"
---@field logo string Generate ANSI art with: https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow
---@field width number
---@field height number
---@field transparent { enabled: boolean, floats: boolean }

---@class core.config.plugins
---@field mason string[]
---@field treesitter string[]
---@field linting utils.plugin.language_config.linter
---@field formatting utils.plugin.language_config.formatter|ConformOpts

---@type core.config
local M = {
  performance_mode = true,
}

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
    enabled = true,
    floats = true,
  },
  width = 0.8,
  height = 0.8,
}

M.lazyvim = {
  colorscheme = M.ui.theme,
  news = {
    lazyvim = true,
    neovim = true,
  },
  icons = {
    diagnostics = vim.tbl_map(function(icon)
      return icon .. " "
    end, core.icons.diagnostics),
    dap = {
      Stopped = {
        core.icons.dap.Stopped .. " ",
        "DapStopped",
        "Visual",
      },
      Breakpoint = {
        core.icons.dap.Breakpoint .. " ",
        "DapBreakpoint",
      },
      BreakpointCondition = {
        core.icons.dap.BreakpointCondition .. " ",
        "DapBreakpointCondition",
      },
      BreakpointRejected = {
        core.icons.dap.BreakpointRejected .. " ",
        "DapBreakpointRejected",
      },
      LogPoint = {
        core.icons.dap.LogPoint .. " ",
        "DapLogPoint",
      },
    },
    git = {
      added = core.icons.git.LineAdded .. " ",
      modified = core.icons.git.LineModified .. " ",
      removed = core.icons.git.LineRemoved .. " ",
    },
    kinds = vim.tbl_map(function(icon)
      return icon .. " "
    end, core.icons.kind),
  },
}

M.plugins = {
  mason = { "codespell", "emmet-language-server" },
  treesitter = {
    "c",
    "python",
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
