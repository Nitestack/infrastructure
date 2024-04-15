--------------------------------------------------------------------------------
--  SNIPPET UTILS
--------------------------------------------------------------------------------
---@class utils.snippet
local M = {}

function M.header_lines()
  local comment = string.format(vim.bo.commentstring:gsub(" ", "") or "#%s", "-")
  local col = vim.bo.textwidth ~= 0 and vim.bo.textwidth or 80
  return comment .. string.rep("-", col - #comment)
end

function M.header_title()
  return vim.bo.commentstring:gsub("%%s", "")
end

return M
