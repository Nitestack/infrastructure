-- ╭─────────────────────────────────────────────────────────╮
-- │ Utils                                                   │
-- ╰─────────────────────────────────────────────────────────╯

---@class utils
---@field cmds utils.cmds
---@field mappings utils.mappings
---@field plugin utils.plugin
---@field shell utils.shell
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

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

---Convert a string or table to a table
---@param str_or_tbl string|string[]
---@return string[]
function M.str_to_tbl(str_or_tbl)
  if type(str_or_tbl) == "string" then
    return { str_or_tbl }
  end
  return str_or_tbl
end

---Checks if the current OS is Linux
function M.is_linux()
  return vim.uv.os_uname().sysname:find("Linux") ~= nil
end

---Checks if the current OS is macOS
function M.is_mac()
  return vim.uv.os_uname().sysname:find("Darwin") ~= nil
end

---Checks if the current OS is WSL (Windows Subsystem for Linux)
function M.is_wsl()
  return os.getenv("WSL_DISTRO_NAME") ~= nil
end

return M
