-- ╭─────────────────────────────────────────────────────────╮
-- │ Command Utils                                           │
-- ╰─────────────────────────────────────────────────────────╯

---@class utils.cmds
local M = {}

---@param opts? vim.api.keyset.create_autocmd
---@param au_group_opts? vim.api.keyset.create_augroup
local function ensure_au_group_defined(opts, au_group_opts)
  opts = opts or {}
  if type(opts.group) == "string" and opts.group ~= "" then
    local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
    if not exists then
      vim.api.nvim_create_augroup(opts.group, au_group_opts or {})
    end
  end
end

---@class utils.cmds.auto_cmd
---@field [1] string|string[]
---@field [2]? vim.api.keyset.create_autocmd

---@param auto_cmds utils.cmds.auto_cmd[]
---@param auto_cmd_opts? vim.api.keyset.create_autocmd
---@param au_group_opts? vim.api.keyset.create_augroup
function M.auto_cmds(auto_cmds, auto_cmd_opts, au_group_opts)
  for _, auto_cmd in ipairs(auto_cmds) do
    local opts =
      vim.tbl_deep_extend("force", auto_cmd_opts or {}, auto_cmd[2] --[[@as vim.api.keyset.create_autocmd]] or {})
    ensure_au_group_defined(opts, au_group_opts)
    vim.api.nvim_create_autocmd(auto_cmd[1], opts)
  end
end

---@class utils.cmds.user_cmd
---@field [1] string
---@field [2] any
---@field [3]? vim.api.keyset.user_command

---@param user_cmds utils.cmds.user_cmd[]
---@param user_cmd_opts? vim.api.keyset.user_command
function M.user_cmds(user_cmds, user_cmd_opts)
  for _, user_cmd in ipairs(user_cmds) do
    local opts =
      vim.tbl_deep_extend("force", user_cmd_opts or {}, user_cmd[3] --[[@as vim.api.keyset.user_command]] or {})
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], opts)
  end
end

return M
