-- ╭─────────────────────────────────────────────────────────╮
-- │ Commands                                                │
-- ╰─────────────────────────────────────────────────────────╯

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
  -- Nushell Integration
  {
    "OptionSet",
    {
      pattern = "shell",
      callback = function()
        if utils.shell.is_nushell() then
          utils.shell.setup_nushell()
        else
          utils.shell.setup_posix_shell()
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
      vim.cmd("MasonUpdate")
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
