--------------------------------------------------------------------------------
--  GlOBALS
--------------------------------------------------------------------------------
---@class utils.globals
local M = {}

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

---Remove duplicates from a table
---@param tbl string[]
---@return string[]
function M.remove_duplicates(tbl)
  ---@type table<string, boolean>
  local seen = {}
  return vim.tbl_filter(function(item)
    if not seen[item] then
      seen[item] = true
      return true
    else
      return false
    end
  end, tbl)
end

---Convert a string or table to a table
---@param str_or_tbl string|table
function M.str_to_tbl(str_or_tbl)
  if type(str_or_tbl) == "string" then
    return { str_or_tbl }
  end
  return str_or_tbl
end

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

function M.is_linux()
  return vim.uv.os_uname().sysname:find("Linux") ~= nil
end

function M.is_nightly()
  return vim.version().prerelease ~= nil
end

function M.is_wsl()
  return os.getenv("WSL_DISTRO_NAME") ~= nil
end

function M.is_neovide()
  return vim.g.neovide ~= nil
end

---@param config { options?: vim.opt, config?: fun(), mappings?: Mappings, mapping_opts?: KeymapOpts }
function M.ft_plugin(config)
  if config.options then
    for k, v in pairs(config.options) do
      vim.wo[k] = v
    end
  end
  if config.config then
    config.config()
  end
  if config.mappings then
    require("utils.mappings").map(config.mappings, config.mapping_opts)
  end
end

M.map = require("utils.mappings").map
M.single_map = require("utils.mappings").single_map
M.lazy_map = require("utils.mappings").lazy_map
M.single_lazy_map = require("utils.mappings").single_lazy_map
M.auto_cmds = require("utils.cmds").auto_cmds
M.user_cmds = require("utils.cmds").user_cmds

return M
