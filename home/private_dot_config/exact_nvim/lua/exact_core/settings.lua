--------------------------------------------------------------------------------
--  SETTINGS
--------------------------------------------------------------------------------

---@class core.settings
---@field options vim.wo
---@field globals table<string, any>|vim.var_accessor
---@field disabled_providers string[]
---@field run fun()

---@type core.settings
local M = {}

--------------------------------------------------------------------------------
--  Options
--------------------------------------------------------------------------------
M.options = {
  autowrite = true, -- Writes modified files on certain commands and navigation to other files
  completeopt = "menu,menuone,noselect", -- Set completion options for popup menu
  conceallevel = 2, -- Hide * markup for bold and italic, but not markers with substitutions
  confirm = true, -- Confirm to save changes before exiting modified buffer
  cursorline = true, -- Enable highlighting of the current line
  fillchars = { -- Characters to fill the statuslines, vertical separators and special lines in the window
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
  },
  formatoptions = "jqlnt", -- Formatting options
  helplang = "de", -- Set the language for the help messages
  inccommand = "nosplit", -- Preview incremental substitute
  laststatus = 3, -- Always show statusline
  mouse = "a", -- Enable mouse usage
  pumheight = 10, -- Maximum number of items in the popup menu
  sessionoptions = { -- Save options for sessions
    "buffers",
    "curdir",
    "tabpages",
    "winsize",
    "help",
    "globals",
    "skiprtp",
    "folds",
  },
  showmode = false, -- Dont show mode since we have a statusline
  signcolumn = "yes", -- Always draw the sign column, avoiding layout shifts
  smoothscroll = true, -- Enables smooth scrolling with screen lines.
  spelllang = { "en" }, -- When the 'spell' option is on spellchecking will be done for these languages
  termguicolors = true, -- Enable 24-bit RGB colors in the TUI
  virtualedit = "block", -- Allow cursor to move where there is no text in visual block mode
  winminwidth = 5, -- Minimum window width

  -- Backup
  backup = false, -- Disable backup files
  swapfile = false, -- Disable swap file
  undodir = vim.fn.expand("~/.vim/undodir"), -- Directory for undo files
  undofile = true, -- Enable persistent undo
  undolevels = 10000, -- Maximum number of changes that can be undone

  -- GUI settings
  guifont = "{{ .fonts.mono }},{{ .fonts.icons }}:h14", -- Set font for graphical Neovim apps
  linespace = 6, -- Set a line height of `1.2`

  -- Indentation
  expandtab = true, -- Use spaces instead of tabs
  shiftround = true, -- Round indent to multiple of 'shiftwidth'
  shiftwidth = 2, -- Number of spaces for each step of (auto)indent
  smartindent = true, -- Do smart autoindenting when starting a new line
  softtabstop = 2, -- Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>
  tabstop = 2, -- Number of spaces that a <Tab> in the file counts for

  -- Format for grep
  grepformat = "%f:%l:%c:%m", -- Format for grep
  grepprg = "rg --vimgrep", -- Set the grep program for :grep

  -- Search
  ignorecase = true, -- Ignore case in search patterns
  smartcase = true, -- Override 'ignorecase' if the search pattern contains uppercase characters

  -- Line Numbers
  number = true, -- Show line numbers
  relativenumber = true, -- Show line numbers relative to the current line

  -- Scroll off
  scrolloff = 4, -- Number of screen lines to keep above and below the cursor
  sidescrolloff = 8, -- Number of screen columns to keep to the left and right of the cursor

  -- Split Windows
  splitbelow = true, -- Put new windows below current
  splitright = true, -- Put new windows right of the current one
  splitkeep = "screen", -- Keep splits open even if they are empty

  -- Timing
  timeoutlen = 300, -- Time to wait for a mapped sequence to complete (in milliseconds)
  updatetime = 200, -- Number of milliseconds to wait for the next typed character in insert mode

  -- File Management
  wildignore = { -- Patterns to ignore during file navigation
    -- "**/node_modules/**",
    -- "**/.git/**",
    -- "**/dist/**",
    -- "**/build/**",
    -- "**/.next/**",
    -- "**/.cache/**",
    -- "**/coverage/**",
    -- "**/target/**",
    -- "**/dist/**",
  },

  -- Wrap
  breakindent = true, -- Indent wrapped lines visually
  linebreak = true, -- Break line at convenient point
  showbreak = core.icons.ui.Tab .. " ", -- Character displayed for the break
  wrap = true, -- Wrap lines
}

--------------------------------------------------------------------------------
--  Globals
--------------------------------------------------------------------------------
M.globals = {
  mapleader = " ",
  maplocalleader = "\\", -- <LocalLeader> is to be used for mappings which are local to a buffer.
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
  -- Set language
  vim.cmd.language("en_US.UTF-8")

  -- Neovide settings
  if utils.is_neovide() then
    vim.g.neovide_hide_mouse_when_typing = true
  end

  -- Only set clipboard if not in ssh, to make sure the OSC 52 integration works automatically
  if not vim.env.SSH_TTY then
    vim.opt.clipboard = "unnamedplus"
  end

  -- Enable undercurl
  vim.cmd([[let &t_Cs = "\e[4:3m"]])
  vim.cmd([[let &t_Ce = "\e[4:0m"]])
  -- Go to previous/next line with h/l/left arrow/right arrow when cursor reaches end/beginning of line
  vim.opt.whichwrap:append("<>[]hl")
  -- Add binaries installed by `mason.nvim` to path
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (utils.is_win() and ";" or ":") .. vim.env.PATH

  -- For Tailwind CSS wraps
  vim.opt.breakat:remove({ ":", "/", "-" })

  -- Modify shortmess
  vim.opt.shortmess:append({
    a = true, -- append `l`, `m`, `r`, `w` abbreviations
    W = true, -- don't give "written" or "[w]" when writing a file
    A = true, -- don't give the "ATTENTION" message when an existing swap file is found
    I = true, -- don't give the intro message when starting Vim, see |:intro|
    c = true, -- don't give |ins-completion-menu| messages; for example, "-- XXX completion (YYY)", "match 1 of 2", "The only match", "Pattern not found", "Back at original", etc.
  })

  -- Setup Windows shell
  if utils.is_win() then
    -- Use PowerShell Core instead of Windows CMD
    vim.o.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
    vim.o.shellcmdflag =
      "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
    vim.o.shellredir = "2>&1 | %{ \"$_\" } | Out-File %s; exit $LastExitCode"
    vim.o.shellpipe = "2>&1 | %{ \"$_\" } | Tee-Object %s; exit $LastExitCode"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  end

  -- Setup WSL clipboard
  if utils.is_wsl() then
    -- Sync WSL clipboard with Windows clipboard
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
