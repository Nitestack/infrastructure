--------------------------------------------------------------------------------
--  Filetypes
--------------------------------------------------------------------------------

---@type vim.filetype.add.filetypes
local M = {}

M.filename = {
  [".eslintrc.json"] = "jsonc",
}

M.pattern = {
  ["tsconfig*.json"] = "jsonc",
  [".*/%.vscode/.*%.json"] = "jsonc",
}

return M
