--------------------------------------------------------------------------------
--  COMMANDS
--------------------------------------------------------------------------------

---@class CommandConfiguration
---@field auto_cmds AutoCommand[]
---@field auto_cmd_opts vim.api.keyset.create_autocmd
---@field user_cmds UserCommand[]
---@field user_cmd_opts vim.api.keyset.user_command
---@field au_group_opts vim.api.keyset.create_augroup

---@type CommandConfiguration
---@diagnostic disable-next-line: missing-fields
local M = {}

--------------------------------------------------------------------------------
--  Autocommands
--------------------------------------------------------------------------------
M.auto_cmds = {
  -- show cursor line only in active window
  {
    { "InsertLeave", "WinEnter" },
    {
      callback = function()
        local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
        if ok and cl then
          vim.wo.cursorline = true
          vim.api.nvim_win_del_var(0, "auto-cursorline")
        end
      end,
    },
  },
  {
    { "InsertEnter", "WinLeave" },
    {
      callback = function()
        local cl = vim.wo.cursorline
        if cl then
          vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
          vim.wo.cursorline = false
        end
      end,
    },
  },
  -- Close some filetypes with <q>
  {
    "FileType",
    {
      group = "lazyvim_close_with_q",
      pattern = {
        "toggleterm",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        core.map({
          n = {
            ["q"] = {
              vim.cmd.close,
              "Close",
              opts = {
                buffer = event.buf,
                silent = true,
              },
            },
          },
        })
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
    end,
  },
  {
    "UpdateAll",
    function()
      vim.cmd("TSUpdateSync")
      vim.cmd("MasonUpdate")
      vim.cmd("Lazy sync")
    end,
  },
}

M.user_cmd_opts = {}

--------------------------------------------------------------------------------
--  Autocommand groups
--------------------------------------------------------------------------------
M.au_group_opts = {
  clear = true,
}

return M
