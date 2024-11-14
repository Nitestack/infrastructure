-- ╭─────────────────────────────────────────────────────────╮
-- │ USER CONFIGURATION                                      │
-- ╰─────────────────────────────────────────────────────────╯

---@class core.config
---@field performance_mode boolean
---@field ui core.config.ui
---@field plugins core.config.plugins
---@field lazyvim LazyVimOptions

---@class core.config.ui
---@field theme "catppuccin"
---@field logo string Generate ANSI art with: https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow

---@module "conform"

---@class core.config.plugins
---@field mason string[]
---@field treesitter string[]
---@field linting utils.plugin.language_config.linter
---@field formatting conform.setupOpts

---@type core.config
local M = {
  performance_mode = utils.is_win(),
}

M.ui = {
  theme = "catppuccin",
  -- stylua: ignore
  logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
- Nitestack -
]],
}

M.lazyvim = {
  colorscheme = M.ui.theme,
  icons = {
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
    kinds = vim.tbl_map(function(icon)
      return icon .. " "
    end, core.icons.kind),
  },
}

M.plugins = {
  mason = {},
  treesitter = {
    "asm",
    "c",
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
  },
  linting = {
    linters_by_ft = {},
    linters = {},
  },
  formatting = {
    formatters_by_ft = {},
    formatters = {},
  },
}

return M
