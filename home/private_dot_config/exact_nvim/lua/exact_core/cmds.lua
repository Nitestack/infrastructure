--------------------------------------------------------------------------------
--  COMMANDS
--------------------------------------------------------------------------------

---@class core.cmds
---@field auto_cmds utils.cmds.auto_cmd[]
---@field auto_cmd_opts vim.api.keyset.create_autocmd
---@field user_cmds utils.cmds.user_cmd[]
---@field user_cmd_opts vim.api.keyset.user_command
---@field au_group_opts vim.api.keyset.create_augroup

---@type core.cmds
local M = {}

--------------------------------------------------------------------------------
--  Autocommands
--------------------------------------------------------------------------------
M.auto_cmds = {
  -- Setup terminal mappings
  {
    "TermOpen",
    {
      pattern = "term://*",
      callback = function(args)
        if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
          core.map({
            t = type(core.mappings.terminal_mappings) == "function" and core.mappings.terminal_mappings(args)
              or vim.deepcopy(core.mappings.terminal_mappings --[[@as core.mappings.terminal_mappings]]),
          }, { silent = false, buffer = args.buf })
        end
      end,
    },
  },
  -- Check if we need to reload the file when it changed
  {
    { "FocusGained", "TermClose", "TermLeave" },
    {
      group = "checktime",
      callback = function()
        if vim.o.buftype ~= "nofile" then
          vim.cmd("checktime")
        end
      end,
    },
  },
  -- Highlight on yank
  {
    "TextYankPost",
    {
      group = "highlight_yank",
      callback = function()
        vim.highlight.on_yank()
      end,
    },
  },
  -- resize splits if window got resized
  {
    "VimResized",
    {
      group = "resize_splits",
      callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
      end,
    },
  },
  -- go to last loc when opening a buffer
  {
    "BufReadPost",
    {
      group = "last_loc",
      callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
          return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, "\"")
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    },
  },
  -- Close some filetypes with <q>
  {
    "FileType",
    {
      group = "close_with_q",
      pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
        "toggleterm",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", vim.cmd.close, { desc = "Close", buffer = event.buf, silent = true })
      end,
    },
  },
  {
    "FileType",
    {
      group = "close_with_q",
      pattern = "*",
      callback = function(event)
        if vim.bo[event.buf].buftype == "nofile" then
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", vim.cmd.close, { desc = "Close", buffer = event.buf, silent = true })
        end
      end,
    },
  },
  -- wrap and check for spell in text filetypes
  {
    "FileType",
    {
      group = "wrap_spell",
      pattern = { "gitcommit", "markdown" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
    },
  },
  -- auto create dir when saving a file, in case some intermediate directory does not exist
  {
    "BufWritePre",
    {
      group = "auto_create_dir",
      callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
          return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
      end,
    },
  },
  -- Remove any trailing whitespace on save
  {
    "BufWritePre",
    {
      group = "remove_trailing_whitespace",
      pattern = "*",
      command = [[%s/\s\+$//e]],
    },
  },
  -- Disable inserting comments on new line
  {
    "BufWinEnter",
    {
      callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
      end,
    },
  },
  -- Disable diagnostics in `node_modules`
  {
    { "BufReadPre", "BufNewFile" },
    {
      group = "disable_diagnostics",
      pattern = "*/node_modules/*",
      callback = function()
        vim.diagnostic.disable(0)
      end,
    },
  },
  -- Enable breadcrumbs
  {
    {
      "WinResized",
      "BufWinEnter",
      "BufModifiedSet",
    },
    {
      group = "breadcrumbs",
      callback = function()
        vim.api.nvim_set_hl(0, "BreadcrumbsPath", { fg = "#7f849c" })
        vim.api.nvim_set_hl(0, "BreadcrumbsFile", { fg = "#cdd6f4", bold = true })
        vim.api.nvim_set_hl(0, "BreadcrumbsModified", { fg = "#fab387" })

        local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
        if not status_ok then
          utils.breadcrumbs.get_winbar()
        end
      end,
    },
  },
}

M.auto_cmd_opts = {}

--------------------------------------------------------------------------------
--  User commands
--------------------------------------------------------------------------------
M.user_cmds = {
  {
    "ClearRegisters",
    function()
      local regs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"
      for r in regs:gmatch(".") do
        vim.fn.setreg(r, {})
      end
      vim.notify("Registers cleared!", vim.log.levels.INFO, { title = "Editor" })
    end,
  },
  {
    "UpdateAll",
    function()
      vim.cmd("TSUpdate")
      vim.cmd("MasonToolsUpdate")
      vim.cmd("Lazy! sync")
    end,
  },
}

M.user_cmd_opts = {}

M.au_group_opts = {
  clear = true,
}

return M
