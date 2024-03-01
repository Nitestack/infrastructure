--------------------------------------------------------------------------------
--  SETTINGS
--------------------------------------------------------------------------------

---@class SettingsConfig
---@field options vim.opt
---@field globals table
---@field disabled_providers string[]
---@field run fun()

---@type SettingsConfig
local M = {}

--------------------------------------------------------------------------------
--  Options
--------------------------------------------------------------------------------
M.options = {
  -- Clipboard
  autowrite = true,
  clipboard = "unnamedplus",
  completeopt = "menu,menuone,noselect",
  conceallevel = 2,
  confirm = true,
  cursorline = true,
  expandtab = true,
  formatoptions = "jqlnt",
  grepformat = "%f:%l:%c:%m",
  grepprg = "rg --vimgrep",
  helplang = "de",
  ignorecase = true,
  inccommand = "nosplit",
  laststatus = 3,
  mouse = "a",
  pumheight = 10,
  scrolloff = 4,
  shiftround = true,
  shiftwidth = 2,
  showmode = false,
  sidescrolloff = 8,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  smoothscroll = true,
  spelllang = { "en", "de" },
  splitbelow = true,
  splitkeep = "screen",
  splitright = true,
  tabstop = 2,
  termguicolors = true,
  timeoutlen = 300,
  updatetime = 200,
  fillchars = {
    foldopen = "",
    foldclose = "",
    -- fold = "⸱",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
  },

  -- Number
  number = true,
  relativenumber = true,

  -- Session
  sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },

  -- Backup
  swapfile = false,
  backup = false,
  undodir = vim.fn.expand("~/.vim/undodir"),
  undofile = true,
  undolevels = 10000,

  -- Wrap
  wrap = true,
  linebreak = true,
  breakindent = true,
  showbreak = core.icons.ui.Tab .. " ",

  -- GUI settings
  guifont = "MonoLisa,Symbols Nerd Font:h18", -- set font for graphical Neovim apps
  linespace = 6,
}

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
M.globals = {
  mapleader = " ",
  maplocalleader = "\\",
  markdown_recommended_style = 0,
  skip_ts_context_commentstring_module = true,
}

--------------------------------------------------------------------------------
--  Disabled providers
--------------------------------------------------------------------------------
M.disabled_providers = { "perl", "ruby", "node", "python3" }

--------------------------------------------------------------------------------
--  Additional settings
--------------------------------------------------------------------------------
function M.run()
  -- Neovide
  if core.is_neovide() then
    vim.g.neovide_hide_mouse_when_typing = true
  end

  -- undercurl
  vim.cmd([[let &t_Cs = "\e[4:3m"]])
  vim.cmd([[let &t_Ce = "\e[4:0m"]])
  -- go to previous/next line with h,l,left arrow and right arrow when cursor reaches end/beginning of line
  vim.opt.whichwrap:append("<>[]hl")
  -- add binaries installed by mason.nvim to path
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (core.is_win() and ";" or ":") .. vim.env.PATH

  -- TailwindCSS wraps
  vim.opt.breakat:remove({ ":", "/", "-" })

  vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

  -- Windows
  if core.is_win() then
    -- Use PowerShell Core instead of Windows CMD
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag =
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end

  -- WSL
  if core.is_wsl() then
    -- Sync clipboard with Windows clipboard
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
      },
      paste = {
        ["+"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))",
        ["*"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))",
      },
      cache_enabled = 0,
    }
  end
end

return M
