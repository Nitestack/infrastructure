--------------------------------------------------------------------------------
--  UTILS
--------------------------------------------------------------------------------
---@class utils
---@field breadcrumbs utils.breadcrumbs
---@field cmds utils.cmds
---@field lazyfile utils.lazyfile
---@field lsp utils.lsp
---@field lualine utils.lualine
---@field mappings utils.mappings
---@field plugin utils.plugin
---@field snippet utils.snippet
---@field telescope utils.telescope
---@field toggle utils.toggle
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

---Load options, mappings, plugins for a filetype
---@param opts { options?: vim.wo, config?: fun(), mappings?: utils.mappings.mappings_spec, mapping_opts?: utils.mappings.mapping_opts }
function M.ft_plugin(opts)
  if opts.options then
    for k, v in pairs(opts.options) do
      vim.wo[k] = v
    end
  end
  if opts.config then
    opts.config()
  end
  if opts.mappings then
    utils.mappings.map(opts.mappings, opts.mapping_opts)
  end
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
---@param str_or_tbl string|string[]
---@return string[]
function M.str_to_tbl(str_or_tbl)
  if type(str_or_tbl) == "string" then
    return { str_or_tbl }
  end
  return str_or_tbl
end

---Checks if the current OS is Windows
function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---Checks if the current OS is Linux
function M.is_linux()
  return vim.uv.os_uname().sysname:find("Linux") ~= nil
end

---Checks if the current OS is macOS
function M.is_mac()
  return vim.uv.os_uname().sysname:find("Darwin") ~= nil
end

---Checks if the current OS is a Unix-like system
function M.is_unix()
  return M.is_linux() or M.is_mac()
end

---Checks if the current OS is WSL (Windows Subsystem for Linux)
function M.is_wsl()
  return os.getenv("WSL_DISTRO_NAME") ~= nil
end

---Checks if the current Neovim GUI is Neovide
function M.is_neovide()
  return vim.g.neovide ~= nil
end

---Checks if the current Neovim version is nightly
function M.is_nightly()
  return vim.version().prerelease ~= nil
end

return M
