local M = {}

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg string
---@param f async fun(...):...
---@param ... any
---@return boolean, any
---@overload fun(f: async fun(...):..., ...): boolean, any
function M.pcall(msg, f, ...)
  local args = { ... }
  if type(msg) == "function" then
    local arg = f --[[@as any]]
    ---@diagnostic disable-next-line: cast-local-type
    args, f, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(f, function(err)
    msg = debug.traceback(msg and string.format("%s:\n%s\n%s", msg, vim.inspect(args), err) or err)
    vim.schedule(function()
      vim.notify(msg, vim.log.levels.ERROR, { title = "ERROR" })
    end)
  end, unpack(args))
end

---@generic T:table
---@param callback fun(item: T, key: any)
---@param list table<any, T>
function M.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function M.falsy(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == "boolean" then
    return not item
  end
  if item_type == "string" then
    return item == ""
  end
  if item_type == "number" then
    return item <= 0
  end
  if item_type == "table" then
    return vim.tbl_isempty(item)
  end
  return item ~= nil
end

---Convert a string or table to a table
---@param str_or_tbl string|table
function M.str_to_tbl(str_or_tbl)
  if type(str_or_tbl) == "string" then
    return { str_or_tbl }
  end
  return str_or_tbl
end

M.ft_plugin = require("utils.loaders").load_ftplugin
M.map = require("utils.mappings").map
M.single_map = require("utils.mappings").single_map
M.lazy_map = require("utils.mappings").lazy_map
M.single_lazy_map = require("utils.mappings").single_lazy_map
M.disable_mapping = require("utils.mappings").disable_mapping
M.auto_cmds = require("utils.cmds").auto_cmds
M.user_cmds = require("utils.cmds").user_cmds

return M
