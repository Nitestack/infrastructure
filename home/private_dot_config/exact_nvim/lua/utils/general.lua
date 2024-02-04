--------------------------------------------------------------------------------
--  GENERAL UTILS
--------------------------------------------------------------------------------
local M = {}

---@param plugins string[]
---@return LazyPluginSpec[]
function M.disabled_plugins(plugins)
  local spec = {}

  for _, plugin in ipairs(plugins) do
    table.insert(spec, {
      plugin,
      enabled = false,
    })
  end

  return spec
end

function M.is_win()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

function M.is_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

function M.is_nightly()
  local version = vim.version()

  if version.prerelease then
    return true
  else
    return false
  end
end

function M.is_wsl()
  return os.getenv("WSL_DISTRO_NAME") ~= nil
end

---@param paths string|string[]
function M.resolve_path(paths)
  return vim.fn.expand(type(paths) == "string" and paths or vim.fn.join(paths, "/"))
end

return M
