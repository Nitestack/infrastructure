--------------------------------------------------------------------------------
--  SETTINGS
--------------------------------------------------------------------------------

---@class SettingsConfig
---@field options vim.opt
---@field globals table
---@field disabled_providers string[]
---@field run fun()

---@type SettingsConfig
---@diagnostic disable-next-line: missing-fields
local M = {}

--------------------------------------------------------------------------------
--  Options
--------------------------------------------------------------------------------
M.options = {
  -- Backup
  swapfile = false,
  backup = false,
  undodir = vim.fn.expand("~/.vim/undodir"),
  undofile = true,

  -- Other
  pumblend = 0, -- fixes icon bug in nvim-cmp
  list = false, -- don't show invisible characters
  guifont = "monospace:h17", -- set font for graphical Neovim apps
}

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
M.globals = {
  mapleader = " ",
  maplocalleader = " ",
}

--------------------------------------------------------------------------------
--  Disabled providers
--------------------------------------------------------------------------------
M.disabled_providers = { "perl", "ruby", "node", "python3" }

--------------------------------------------------------------------------------
--  Additional settings
--------------------------------------------------------------------------------
function M.run()
  -- undercurl
  vim.cmd([[let &t_Cs = "\e[4:3m"]])
  vim.cmd([[let &t_Ce = "\e[4:0m"]])
  -- go to previous/next line with h,l,left arrow and right arrow when cursor reaches end/beginning of line
  vim.opt.whichwrap:append("<>[]hl")
  -- add binaries installed by mason.nvim to path
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (utils.general.is_win() and ";" or ":") .. vim.env.PATH

  -- Windows
  if utils.general.is_win() then
    -- Shell
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag =
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end

  -- Linux
  if utils.general.is_linux() then
    -- WSL Clipboard
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
