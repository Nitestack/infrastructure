--------------------------------------------------------------------------------
--  SNIPPET UTILS
--------------------------------------------------------------------------------
---@class utils.snippet
local M = {}

function M.header_lines()
  local comment = string.format(vim.filetype.get_option(vim.bo.filetype, "commentstring"):gsub(" ", "") or "#%s", "-")
  local col = vim.bo.textwidth ~= 0 and vim.bo.textwidth or 80
  return comment .. string.rep("-", col - #comment)
end

function M.header_title()
  local header_comment, _ = vim.filetype.get_option(vim.bo.filetype, "commentstring"):gsub("%%s", "")
  return header_comment
end

return M
