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
local M = {}

--------------------------------------------------------------------------------
--  Autocommands
--------------------------------------------------------------------------------
M.auto_cmds = {
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
        core.single_map("n", "q", {
          vim.cmd.close,
          "Close",
          opts = {
            buffer = event.buf,
            silent = true,
          },
        })
      end,
    },
  },
  {
    "FileType",
    {
      group = "lazyvim_close_with_q",
      pattern = "*",
      callback = function(event)
        if vim.bo[event.buf].buftype == "nofile" then
          vim.bo[event.buf].buflisted = false
          core.single_map("n", "q", {
            vim.cmd.close,
            "Close",
            opts = {
              buffer = event.buf,
              silent = true,
            },
          })
        end
      end,
    },
  },
  {
    "BufEnter",
    {
      group = "lazyvim_close_with_q",
      pattern = "*",
      callback = function(event)
        if vim.bo[event.buf].buftype == "" then
          vim.bo[event.buf].buflisted = false
          core.single_map("n", "q", {
            vim.cmd.close,
            "Close",
            opts = {
              buffer = event.buf,
              silent = true,
            },
          })
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
