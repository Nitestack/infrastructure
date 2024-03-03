local M = {}

local is_inside_work_tree = {}

---@param builtin string
---@param opts? table
function M.builtin(builtin, opts)
  return function()
    pcall(require("telescope.builtin")[builtin], opts)
  end
end

function M.project_files()
  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    M.builtin("git_files", { show_untracked = true })()
  else
    M.builtin("find_files")()
  end
end

return M
