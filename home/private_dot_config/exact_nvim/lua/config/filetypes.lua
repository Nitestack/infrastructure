--------------------------------------------------------------------------------
--  FILETYPES
--------------------------------------------------------------------------------

---@type vim.filetype.add.filetypes
local M = {}

M.extension = {
  mdx = "markdown",
}

M.filename = {
  [".eslintrc.json"] = "jsonc",
  [".npmignore"] = "ignore",
}

M.pattern = {
  ["tsconfig*.json"] = "jsonc",
  [".*/%.vscode/.*%.json"] = "jsonc",
  ["tsconfig.tsbuildinfo"] = "json",
}

return M
